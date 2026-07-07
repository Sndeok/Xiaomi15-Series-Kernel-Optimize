#!/system/bin/sh

MODDIR=${0%/*}
LOG=/data/system/Xiaomi15-Series-Kernel-Optimize/with-ntsync.log

logi() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"
}

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
    logi "$name already loaded"
    return 0
  fi
  if [ -f "$ko" ]; then
    insmod "$ko" >> "$LOG" 2>&1 && logi "loaded $name" || logi "failed to load $name"
  else
    logi "missing $ko"
  fi
}

apply_ntsync_env() {
  if [ -e /dev/ntsync ]; then
    chmod 0666 /dev/ntsync >> "$LOG" 2>&1
    chcon u:object_r:ntsync_device:s0 /dev/ntsync >> "$LOG" 2>&1
    logi "NTSync env configured: $(ls -Z /dev/ntsync 2>/dev/null)"
  else
    logi "/dev/ntsync not found"
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
  logi "system opt applied"
}

kill_hyperos_log() {
  tags="RecentsTaskLoader AurogonImmobulusMode ViewRootImplStubImpl RefreshRateSelector DynamicIslandEventCoordinator MiuiWallpaperSurfaceAnimation ActivityManagerWrapper MiuiDecorationDot MiuiDecorationBottom MiuiDecorationBase MIUIInput RenderEngine InsetsSource HwcComposer PassBlur TRUETONE NTKernel"
  for tag in $tags; do
    setprop log.tag.$tag S
  done
  logi "HyperOS log tags set to S"
}

main() {
  wait_boot
  mkdir -p /data/system/Xiaomi15-Series-Kernel-Optimize
  : > "$LOG"
  logi "module service started"
  logi "current kernel: $(uname -r)"
  logi "kernel check disabled, loading modules directly"

  rmmod binder_prio >> "$LOG" 2>&1
  rmmod kshrink_slabd >> "$LOG" 2>&1
  sleep 2
  load_ko "$MODDIR/modules/ntsync.ko" "ntsync"
  load_ko "$MODDIR/modules/kshrink_slabd.ko" "kshrink_slabd"
  load_ko "$MODDIR/modules/mi_rmap_efficiency.ko" "mi_rmap_efficiency"
  load_ko "$MODDIR/modules/binder_prio.ko" "binder_prio"
  load_ko "$MODDIR/modules/mi_async_reclaim.ko" "mi_async_reclaim"

  apply_ntsync_env
  apply_system_opt
  kill_hyperos_log
  logi "module service finished"
}

main &
