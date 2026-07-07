#!/system/bin/sh
ui_print "****************************************"
ui_print " Xiaomi15-Series-Kernel-Optimize"
ui_print " Performance / Memory / IO / Log / NTSync"
ui_print " Author: 酷安@Amktiao、GitHub@SndeOK"
ui_print "****************************************"

print_done() {
  printf "%s " "$1"
  sleep 0.28
  ui_print "✅"
}
print_done "加载系统交互与调度优化模块: binder_prio"
print_done "加载内存回收优化模块: kshrink_slabd"
print_done "加载页面回收效率优化模块: mi_rmap_efficiency"
print_done "加载异步内存回收模块: mi_async_reclaim"
print_done "加载 PC 游戏模拟器优化模块: ntsync"
print_done "应用 NTSync SELinux 与 /dev/ntsync 权限配置"
print_done "应用 IO 调度器与 F2FS checkpoint 优化"
print_done "应用 VM 内存参数优化"
print_done "降低 HyperOS 高频调试日志输出"
print_done "开机后自动执行优化"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/sepolicy.rule 0 0 0644
