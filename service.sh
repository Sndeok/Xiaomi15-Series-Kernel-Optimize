#!/system/bin/sh

MODDIR=${0%/*}

wait_boot() {
  until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
  done
  sleep 10
}

load_ko() {
  local ko="$1"
  local name="$2"
  if lsmod 2>/dev/null | grep -q "^$name\b"; then
    return 0
  fi
  [ -f "$ko" ] && insmod "$ko" >/dev/null 2>&1
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
  loaded_msg=""
  log_msg=""
  loaded_list=""

  loaded_modules=$(lsmod 2>/dev/null | grep -E "binder_prio|kshrink_slabd|mi_rmap_efficiency|mi_async_reclaim")
  for name in binder_prio kshrink_slabd mi_rmap_efficiency mi_async_reclaim; do
    if echo "$loaded_modules" | grep -q "^$name\b"; then
      if [ -n "$loaded_list" ]; then
        loaded_list="$loaded_list、$name.ko"
      else
        loaded_list="$name.ko"
      fi
    fi
  done
  [ -n "$loaded_list" ] && loaded_msg="${loaded_list}已载入😋"

  log_ok=1
  tags="RecentsTaskLoader AurogonImmobulusMode ViewRootImplStubImpl RefreshRateSelector DynamicIslandEventCoordinator MiuiWallpaperSurfaceAnimation ActivityManagerWrapper MiuiDecorationDot MiuiDecorationBottom MiuiDecorationBase MIUIInput RenderEngine InsetsSource HwcComposer PassBlur TRUETONE NTKernel"
  for tag in $tags; do
    [ "$(getprop log.tag.$tag)" = "S" ] || log_ok=0
  done
  [ "$log_ok" = "1" ] && log_msg="日志缓冲区写入已禁用😋"

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
  wait_boot

  rmmod binder_prio >/dev/null 2>&1
  rmmod kshrink_slabd >/dev/null 2>&1
  sleep 2
  load_ko "$MODDIR/modules/kshrink_slabd.ko" "kshrink_slabd"
  load_ko "$MODDIR/modules/mi_rmap_efficiency.ko" "mi_rmap_efficiency"
  load_ko "$MODDIR/modules/binder_prio.ko" "binder_prio"
  load_ko "$MODDIR/modules/mi_async_reclaim.ko" "mi_async_reclaim"

  apply_system_opt
  kill_hyperos_log
  update_module_description
}

main &
