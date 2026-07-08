#!/system/bin/sh

MODDIR=${0%/*}

wait_boot() {
  until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
  done
  sleep 10
}

module_loaded() {
  local name="$1"
  lsmod 2>/dev/null | awk -v n="$name" '$1 == n { found=1 } END { exit !found }'
}

append_item() {
  local var="$1"
  local item="$2"
  local current=""

  eval "current=\${$var}"
  if [ -n "$current" ]; then
    current="$current、$item"
  else
    current="$item"
  fi
  eval "$var=\$current"
}

append_desc_line() {
  local line="$1"
  if [ -n "$load_status_msg" ]; then
    load_status_msg="$load_status_msg\n$line"
  else
    load_status_msg="$line"
  fi
}

append_loaded_desc_lines() {
  local list="$1"
  local item=""

  while [ -n "$list" ]; do
    item="${list%%、*}"
    append_desc_line "${item}已载入😋"
    [ "$list" = "$item" ] && break
    list="${list#*、}"
  done
}

build_load_status_msg() {
  load_status_msg=""
  [ -n "$reloaded_list" ] && append_desc_line "${reloaded_list}已重新载入😋"
  [ -n "$loaded_list" ] && append_loaded_desc_lines "$loaded_list"
  [ -n "$unload_failed_list" ] && append_desc_line "${unload_failed_list}卸载失败，保留现有模块⚠️"
  [ -n "$reload_failed_list" ] && append_desc_line "${reload_failed_list}重新载入失败⚠️"
  [ -n "$load_failed_list" ] && append_desc_line "${load_failed_list}载入失败⚠️"
  [ -n "$missing_list" ] && append_desc_line "${missing_list}文件不存在⚠️"
}

load_ko() {
  local ko="$1"
  local name="$2"
  local existed=0

  if module_loaded "$name"; then
    existed=1
    rmmod "$name" >/dev/null 2>&1
    sleep 1
  fi

  if module_loaded "$name"; then
    append_item unload_failed_list "$name.ko"
    return 1
  fi

  if [ ! -f "$ko" ]; then
    append_item missing_list "$name.ko"
    return 1
  fi

  insmod "$ko" >/dev/null 2>&1
  sleep 1

  if module_loaded "$name"; then
    if [ "$existed" = "1" ]; then
      append_item reloaded_list "$name.ko"
    else
      append_item loaded_list "$name.ko"
    fi
  else
    if [ "$existed" = "1" ]; then
      append_item reload_failed_list "$name.ko"
    else
      append_item load_failed_list "$name.ko"
    fi
    return 1
  fi
}

apply_ntsync_env() {
  if [ -e /dev/ntsync ]; then
    chmod 0666 /dev/ntsync >/dev/null 2>&1
    chcon u:object_r:ntsync_device:s0 /dev/ntsync >/dev/null 2>&1
  fi
}

apply_system_opt() {
  kernel_vm_param=/proc/sys/vm
  sda_iosched=/sys/block/sda/queue/iosched
  f2fs_sysfs=/dev/sys/fs/by-name/userdata
  memsize=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 2>/dev/null)

  if [ -n "$memsize" ] && [ "$memsize" -gt 12288 ]; then
    [ -w "$kernel_vm_param/extfrag_threshold" ] && echo 800 > "$kernel_vm_param/extfrag_threshold"
    [ -w "$kernel_vm_param/compact_unevictable_allowed" ] && echo 0 > "$kernel_vm_param/compact_unevictable_allowed"
  fi

  [ -w "$kernel_vm_param/oom_dump_tasks" ] && echo 0 > "$kernel_vm_param/oom_dump_tasks"

  [ -w "$sda_iosched/read_expire" ] && echo 4 > "$sda_iosched/read_expire"
  [ -w "$sda_iosched/write_expire" ] && echo 8 > "$sda_iosched/write_expire"
  [ -w "$sda_iosched/async_depth" ] && echo 126 > "$sda_iosched/async_depth"
  [ -w "$sda_iosched/prio_aging_expire" ] && echo 200 > "$sda_iosched/prio_aging_expire"
  [ -w "$sda_iosched/io_threshold" ] && echo 256 > "$sda_iosched/io_threshold"

  [ -w "$f2fs_sysfs/ckpt_thread_ioprio" ] && echo "rt,3" > "$f2fs_sysfs/ckpt_thread_ioprio"
}

kill_hyperos_log() {
  tags="RecentsTaskLoader AurogonImmobulusMode ViewRootImplStubImpl RefreshRateSelector DynamicIslandEventCoordinator MiuiWallpaperSurfaceAnimation ActivityManagerWrapper MiuiDecorationDot MiuiDecorationBottom MiuiDecorationBase MIUIInput RenderEngine InsetsSource HwcComposer PassBlur TRUETONE NTKernel"
  for tag in $tags; do
    setprop log.tag.$tag S
  done
}


update_module_description() {
  build_load_status_msg
  loaded_msg="$load_status_msg"
  log_msg=""

  log_ok=1
  tags="RecentsTaskLoader AurogonImmobulusMode ViewRootImplStubImpl RefreshRateSelector DynamicIslandEventCoordinator MiuiWallpaperSurfaceAnimation ActivityManagerWrapper MiuiDecorationDot MiuiDecorationBottom MiuiDecorationBase MIUIInput RenderEngine InsetsSource HwcComposer PassBlur TRUETONE NTKernel"
  for tag in $tags; do
    [ "$(getprop log.tag.$tag)" = "S" ] || log_ok=0
  done
  [ "$log_ok" = "1" ] && log_msg="Xiaomi调试日志已关闭✅"

  desc="$loaded_msg"
  if [ -n "$log_msg" ]; then
    if [ -n "$desc" ]; then
      desc="$desc\n$log_msg"
    else
      desc="$log_msg"
    fi
  fi

  if [ -n "$desc" ] && [ -f "$MODDIR/module.prop" ]; then
    safe_desc=$(printf '%s' "$desc" | sed 's/[\\&]/\\&/g')
    sed -i "s/^description=.*/description=$safe_desc/" "$MODDIR/module.prop"
  fi
}
main() {
  load_status_msg=""
  loaded_list=""
  reloaded_list=""
  unload_failed_list=""
  load_failed_list=""
  reload_failed_list=""
  missing_list=""

  wait_boot

  load_ko "$MODDIR/modules/ntsync.ko" "ntsync"
  load_ko "$MODDIR/modules/kshrink_slabd.ko" "kshrink_slabd"
  load_ko "$MODDIR/modules/mi_rmap_efficiency.ko" "mi_rmap_efficiency"
  load_ko "$MODDIR/modules/binder_prio.ko" "binder_prio"
  load_ko "$MODDIR/modules/mi_async_reclaim.ko" "mi_async_reclaim"

  apply_ntsync_env
  apply_system_opt
  kill_hyperos_log
  update_module_description
}

main &
