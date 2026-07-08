# 更新日志

## v6.6

小米15系列内核优化模块首个正式发布版，提供 No-NTSync 与 With-NTSync 两个可刷入版本。

### 模块优化内容

- 系统交互与调度优化：加载 `binder_prio.ko`，优化 Binder 相关调度表现。
- 内存回收优化：加载 `kshrink_slabd.ko`，改善内存回收效率。
- 页面回收效率优化：加载 `mi_rmap_efficiency.ko`，优化页面反向映射相关效率。
- 异步内存回收：加载 `mi_async_reclaim.ko`，提升内存压力场景下的回收表现。
- IO 调度器优化：调整 UFS/块设备调度相关参数。
- F2FS checkpoint 优化：调整 userdata 分区 checkpoint 线程 I/O 优先级。
- VM 内存参数优化：根据设备内存容量调整部分 `/proc/sys/vm` 参数。
- HyperOS 日志优化：降低指定高频调试日志输出，减少额外开销。
- 模块状态显示：开机后在模块描述中按状态合并显示 `.ko` 载入、重新载入、卸载失败、载入失败等结果。

### 版本说明

- No-NTSync：不包含 `ntsync.ko`，适合无手机游玩 PC 游戏 / Winlator / 盖世游戏等需求的用户。
- With-NTSync：包含 `ntsync.ko`、`sepolicy.rule` 与 `/dev/ntsync` 权限配置，适合有 PC 游戏模拟器需求的用户。
- With-NTSync 说明：`ntsync.ko` 依赖高通 / QCOM 的 `debug_symbol` 前置模块；使用 `lsmod | grep -E "ntsync|kshrink|mi_rmap|binder_prio"` 查询时可能显示类似下面的结果，其中 `debug_symbol` 因 Used by 列包含 `ntsync` 等模块而被匹配显示，属于正常现象。

```text
mi_rmap_efficiency  16384 0
ntsync             28672 0
binder_prio        16384 0
kshrink_slabd      16384 0
debug_symbol       16384 5 ntsync,debug_ext,qcom_logbuf_vendor_hooks,minidump,qcom_dma_heaps, [permanent]
```

