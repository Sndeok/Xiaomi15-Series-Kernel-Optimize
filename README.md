# 小米15系列内核优化

小米 15 系列内核与系统优化 Magisk 模块，提供 **No-NTSync** 与 **With-NTSync** 两个可刷入版本。

作者：酷安@Amktiao, GitHub@SndeOK

## 优化来源

相关优化内容来源于酷安 @Amktiao 帖子：

- [小米15系列 6.6 内核模块优化合集：binder_prio、kshrink_slabd、mi_rmap_efficiency、NTSync 与 IO/VM 优化](https://www.coolapk.com/feed/72139408?s=MjBiZjA4ZmYxNmRjZDZjZzZhNGQwZGRjega1622)
- [关闭 HyperOS 高频调试日志，降低 logd 额外开销](https://www.coolapk.com/feed/72422245?s=ZjJlZmFhNzExNmRjZDZjZzZhNGQwZGRhega1622)
- [小米15系列 mi_async_reclaim 异步内存回收优化模块](https://www.coolapk.com/feed/72357281?s=MDRiZDE5ZWUxNmRjZDZjZzZhNGQwZTg0ega1622)

## 模块优化内容

- 系统交互与调度优化：加载 `binder_prio.ko`，优化 Binder 相关调度表现
- 内存回收优化：加载 `kshrink_slabd.ko`，改善内存回收效率
- 页面回收效率优化：加载 `mi_rmap_efficiency.ko`，优化页面反向映射相关效率
- 异步内存回收：加载 `mi_async_reclaim.ko`，提升内存压力场景下的回收表现
- IO 调度器优化：调整 UFS / 块设备调度相关参数
- F2FS checkpoint 优化：调整 userdata 分区 checkpoint 线程 I/O 优先级
- VM 内存参数优化：根据设备内存容量调整部分 `/proc/sys/vm` 参数
- HyperOS 日志优化：降低指定高频调试日志输出，减少额外开销

## 版本选择

> 两个版本使用同一个模块 ID，二选一刷入即可；切换版本时会覆盖同一模块目录，不建议同时安装。

### No-NTSync 版本

- 文件：`Xiaomi15-Series-Kernel-Optimize-No-NTSync-v6.6.zip`
- 适合：无手机游玩 PC 游戏 / Winlator / 盖世游戏等 PC 游戏模拟器需求的用户
- 不包含：`ntsync.ko`、NTSync SELinux 配置、`/dev/ntsync` 权限配置

### With-NTSync 版本

- 文件：`Xiaomi15-Series-Kernel-Optimize-With-NTSync-v6.6.zip`
- 适合：有手机游玩 PC 游戏 / Winlator / 盖世游戏等 PC 游戏模拟器需求的用户
- 包含：`ntsync.ko`、`sepolicy.rule`、`/dev/ntsync` 权限配置
- 说明：`ntsync.ko` 依赖高通 / QCOM 的 `debug_symbol` 前置模块。使用类似 `lsmod | grep -E "ntsync|kshrink|mi_rmap|binder_prio"` 查询时，可能会显示类似下面的结果；其中 `debug_symbol` 行是因为 Used by 列包含 `ntsync` 等模块而被匹配到，属于正常现象。

```text
mi_rmap_efficiency  16384 0
ntsync             28672 0
binder_prio        16384 0
kshrink_slabd      16384 0
debug_symbol       16384 5 ntsync,debug_ext,qcom_logbuf_vendor_hooks,minidump,qcom_dma_heaps, [permanent]
```

## 风险提示

内核模块 `.ko` 与设备内核版本强相关。若设备或系统版本不匹配，可能导致模块加载失败、异常重启或无法开机。请确认设备环境并自行承担风险。
