# Xiaomi15 Series Kernel Optimize

小米 15 系列内核与系统优化 Magisk 模块。

作者：酷安@Amktiao、GitHub@SndeOK

## 优化内容

- 系统交互与调度优化：`binder_prio.ko`
- 内存回收优化：`kshrink_slabd.ko`
- 页面回收效率优化：`mi_rmap_efficiency.ko`
- 异步内存回收：`mi_async_reclaim.ko`
- IO 调度器与 F2FS checkpoint 优化
- VM 内存参数优化
- 降低 HyperOS 高频调试日志

## 说明

- 无 NTSync 相关优化。
- 不包含 `ntsync.ko`。
- 不包含 NTSync SELinux 规则。
- 不检测内核版本，开机后直接尝试加载 `.ko` 模块。

## 安装

在 Magisk / KernelSU / APatch 管理器中刷入：

```text
releases/Xiaomi15-Kernel-Optimize-No-NTSync-NoCheck-v1.5.zip
```

刷入后重启。

## 运行日志

```text
/data/local/tmp/xiaomi15_kernel_opt_no_ntsync.log
```

## 文件结构

```text
module.prop
customize.sh
service.sh
modules/
  binder_prio.ko
  kshrink_slabd.ko
  mi_rmap_efficiency.ko
  mi_async_reclaim.ko
```

## 风险提示

内核模块 `.ko` 与设备内核版本强相关。若设备或系统版本不匹配，可能导致模块加载失败、异常重启或无法开机。请确认设备环境并自行承担风险。
