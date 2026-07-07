# Xiaomi15 Series Kernel Optimize

小米 15 系列内核与系统优化 Magisk 模块。

作者：酷安@Amktiao、GitHub@SndeOK

## 优化来源

相关优化内容来源于酷安 @Amktiao 帖子：

- [小米15系列 6.6 内核模块优化合集：binder_prio、kshrink_slabd、mi_rmap_efficiency、NTSync 与 IO/VM 优化](https://www.coolapk.com/feed/72139408?s=MjBiZjA4ZmYxNmRjZDZjZzZhNGQwZGRjega1622)
- [关闭 HyperOS 高频调试日志，降低 logd 额外开销](https://www.coolapk.com/feed/72422245?s=ZjJlZmFhNzExNmRjZDZjZzZhNGQwZGRhega1622)
- [小米15系列 mi_async_reclaim 异步内存回收优化模块](https://www.coolapk.com/feed/72357281?s=MDRiZDE5ZWUxNmRjZDZjZzZhNGQwZTg0ega1622)

## 版本选择

Release 中提供两个可刷入版本：

1. **No-NTSync 版本**
   - 文件：`Xiaomi15-Series-Kernel-Optimize-No-NTSync-v3.6.zip`
   - 适合：无手机上玩 PC 游戏 、Winlator、盖世游戏等 PC 游戏模拟器需求。
   - 不包含 `ntsync.ko` 和 NTSync 相关 SELinux 配置。

2. **With-NTSync 版本**
   - 文件：`Xiaomi15-Series-Kernel-Optimize-With-NTSync-v3.6.zip`
   - 适合：有手机上玩 PC 游戏 、Winlator、盖世游戏等 PC 游戏模拟器需求。
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

模块不写入运行时日志，减少持久化痕迹。刷入时会显示具体启用的优化内容。

## 风险提示

内核模块 `.ko` 与设备内核版本强相关。若设备或系统版本不匹配，可能导致模块加载失败、异常重启或无法开机。请确认设备环境并自行承担风险。
