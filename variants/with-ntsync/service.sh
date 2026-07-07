#!/system/bin/sh

MODDIR=${0%/*}

function wait_boot_completed ()
{
    until [ "$(getprop sys.boot_completed)" = "1" ]; do
        sleep 2
    done
    sleep 10
}

function replace_kernel_modules ()
{
    piano_ko=${MODDIR}/modules

    # remove kernel module
    rmmod binder_prio >/dev/null 2>&1
    rmmod kshrink_slabd >/dev/null 2>&1

    # update for piano kernel module
    sleep 2
    insmod $piano_ko/ntsync.ko >/dev/null 2>&1
    insmod $piano_ko/kshrink_slabd.ko >/dev/null 2>&1
    insmod $piano_ko/mi_rmap_efficiency.ko >/dev/null 2>&1
    insmod $piano_ko/binder_prio.ko >/dev/null 2>&1
}

function set_ntsync_sepolicy_env ()
{
    if [ -e /dev/ntsync ]; then
        chmod 0666 /dev/ntsync >/dev/null 2>&1
        chcon u:object_r:ntsync_device:s0 /dev/ntsync >/dev/null 2>&1
    fi
}

function load_mi_async_reclaim ()
{
    insmod ${MODDIR}/modules/mi_async_reclaim.ko >/dev/null 2>&1
}

function set_system_opt ()
{
    # generic kernel sysfs node and folder
    kernel_vm_param=/proc/sys/vm
    sda_iosched=/sys/block/sda/queue/iosched
    f2fs_sysfs=/dev/sys/fs/by-name/userdata

    # get device memory size total (unit: MB)
    memsize=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024)

    if [ $memsize -gt 12288 ]; then
        echo 800 > $kernel_vm_param/extfrag_threshold
        echo 0 > $kernel_vm_param/compact_unevictable_allowed
        # echo 20 > $kernel_vm_param/watermark_scale_factor
    fi

    # Disable OOM dump Task Info
    echo 0 > $kernel_vm_param/oom_dump_tasks

    # config: xiaomi CPQ-Iosched param:
    echo 4 > $sda_iosched/read_expire
    echo 8 > $sda_iosched/write_expire

    echo 126 > $sda_iosched/async_depth
    echo 200 > $sda_iosched/prio_aging_expire
    echo 256 > $sda_iosched/io_threshold

    # config: change f2fs-ckpt ioprio to rt,3
    echo "rt,3" > $f2fs_sysfs/ckpt_thread_ioprio
}

function start_moon_log_kill ()
{
    tags=(
        RecentsTaskLoader
        AurogonImmobulusMode
        ViewRootImplStubImpl
        RefreshRateSelector

        DynamicIslandEventCoordinator
        MiuiWallpaperSurfaceAnimation
        ActivityManagerWrapper

        MiuiDecorationDot
        MiuiDecorationBottom
        MiuiDecorationBase

        MIUIInput
        RenderEngine
        InsetsSource
        HwcComposer

        PassBlur
        TRUETONE
        NTKernel
    )

    for tag in "${tags[@]}"; do
        setprop log.tag.$tag S
    done
}

function main ()
{
    wait_boot_completed
    replace_kernel_modules
    set_ntsync_sepolicy_env
    load_mi_async_reclaim
    set_system_opt
    start_moon_log_kill
}

main &
