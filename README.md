# Xiaomi15 Series Kernel Optimize

小米 15 系列内核与系统优化 Magisk 模块。

作者：酷安@Amktiao、GitHub@SndeOK

## 版本选择

Release 中提供两个可刷入版本：

1. **No-NTSync 版本**
   - 文件：`Xiaomi15-Series-Kernel-Optimize-No-NTSync-v1.7.zip`
   - 适合：不在手机上玩 PC 游戏 / 不需要 Winlator、盖世游戏等 PC 游戏模拟器优化的人。
   - 不包含 `ntsync.ko` 和 NTSync 相关 SELinux 配置。

2. **With-NTSync 版本**
   - 文件：`Xiaomi15-Series-Kernel-Optimize-With-NTSync-v1.7.zip`
   - 适合：需要在手机上游玩 PC 游戏，使用 Winlator、盖世游戏等模拟器的人。
   - 包含 `ntsync.ko`、`sepolicy.rule` 以及 `/dev/ntsync` 权限配置。

> 两个版本二选一刷入即可，不建议同时安装。

## 通用优化内容

- 系统交互与调度优化：`binder_prio.ko`
- 内存回收优化：`kshrink_slabd.ko`
- 页面回收效率优化：`mi_rmap_efficiency.ko`
- 异步内存回收：`mi_async_reclaim.ko`
- IO 调度器与 F2FS checkpoint 优化
- VM 内存参数优化
- 降低 HyperOS 高频调试日志

## 运行日志

No-NTSync 版本：

```text
/data/local/tmp/xiaomi15_kernel_opt_no_ntsync.log
```

With-NTSync 版本：

```text
/data/local/tmp/xiaomi15_kernel_opt_with_ntsync.log
```

## 风险提示

内核模块 `.ko` 与设备内核版本强相关。若设备或系统版本不匹配，可能导致模块加载失败、异常重启或无法开机。请确认设备环境并自行承担风险。
