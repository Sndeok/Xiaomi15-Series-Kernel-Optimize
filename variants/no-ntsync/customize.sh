#!/system/bin/sh
ui_print "****************************************"
ui_print " Xiaomi15-Series-Kernel-Optimize"
ui_print " Performance / Memory / IO / Log / No NTSync"
ui_print " Author: 酷安@Amktiao、GitHub@SndeOK"
ui_print "****************************************"
ui_print "- 加载系统交互与调度优化模块: binder_prio"
ui_print "- 加载内存回收优化模块: kshrink_slabd"
ui_print "- 加载页面回收效率优化模块: mi_rmap_efficiency"
ui_print "- 加载异步内存回收模块: mi_async_reclaim"
ui_print "- 应用 IO 调度器与 F2FS checkpoint 优化"
ui_print "- 应用 VM 内存参数优化"
ui_print "- 降低 HyperOS 高频调试日志输出"
ui_print "- 开机后自动执行优化"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
