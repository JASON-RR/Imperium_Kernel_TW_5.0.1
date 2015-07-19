#!/sbin/busybox sh

BB=/sbin/busybox

# Mounting partition in RW mode

OPEN_RW()
{
	$BB mount -o remount,rw /;
}
OPEN_RW;

sleep 1;

# Run Qualcomm scripts
$BB sh /sbin/init.qcom.post_boot.sh;

sleep 1;

OPEN_RW;

# Symlink
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
fi;

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R system:system /data/anr;
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 755 /sbin;
	$BB chmod -R 06755 /sbin/ext/;
	$BB chmod -R 0777 /data/anr/;
	$BB chmod -R 0400 /data/tombstones;
	$BB chmod 06755 /sbin/busybox
	$BB chown -R root:root /data/property;
	$BB chmod -R 0700 /data/property;
}
CRITICAL_PERM_FIX;

# Prop tweaks
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop pm.sleep_mode 1
setprop logcat.live disable
setprop profiler.force_disable_ulog 1

# Fixing ROOT
/system/xbin/daemonsu --auto-daemon &

# STweaks suppot
$BB rm -f /system/app/HybridTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/Hulk-Kernel sTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks_Googy-Max.apk > /dev/null 2>&1;
$BB rm -f /system/app/GTweaks.apk > /dev/null 2>&1;
$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
$BB chown root.root /system/priv-app/STweaks.apk;
$BB chmod 644 /system/priv-app/STweaks.apk;

if [ ! -d /data/.imperium ]; then
	$BB mkdir -p /data/.imperium;
fi;

[ ! -f /data/.imperium/default.profile ] && cp -a /res/customconfig/default.profile /data/.imperium/default.profile;
[ ! -f /data/.imperium/battery.profile ] && cp -a /res/customconfig/battery.profile /data/.imperium/battery.profile;
[ ! -f /data/.imperium/performance.profile ] && cp -a /res/customconfig/performance.profile /data/.imperium/performance.profile;
[ ! -f /data/.imperium/extreme_performance.profile ] && cp -a /res/customconfig/extreme_performance.profile /data/.imperium/extreme_performance.profile;
[ ! -f /data/.imperium/extreme_battery.profile ] && cp -a /res/customconfig/extreme_battery.profile /data/.imperium/extreme_battery.profile;

$BB chmod -R 0777 /data/.imperium/;

. /res/customconfig/customconfig-helper;
read_defaults;
read_config;

# Apply STweaks defaults
$BB sh /res/uci_boot.sh apply;
$BB mv /res/uci_boot.sh /res/uci.sh;

# Android logger
if [ "$logger_mode" == "on" ]; then
	$BB echo "1" > /sys/kernel/logger_mode/logger_mode;
else
	$BB echo "0" > /sys/kernel/logger_mode/logger_mode;
fi;

# zRam
if [ "$sammyzram" == "on" ];then
UNIT="M"
	/system/bin/rtccd3 -a "$zramdisksize$UNIT"
	echo "0" > /proc/sys/vm/page-cluster;
fi;

# Scheduler
	$BB echo "$int_scheduler" > /sys/block/mmcblk0/queue/scheduler;
	$BB echo "$int_read_ahead_kb" > /sys/block/mmcblk0/bdi/read_ahead_kb;
	$BB echo "$ext_scheduler" > /sys/block/mmcblk1/queue/scheduler;
	$BB echo "$ext_read_ahead_kb" > /sys/block/mmcblk1/bdi/read_ahead_kb;

# CPU
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq;

OPEN_RW;

# Fix critical perms again after init.d mess
	CRITICAL_PERM_FIX;
	
sleep 2;

# script finish here, so let me know when
rm /data/local/tmp/Imperium_LL_Kernel
touch /data/local/tmp/Imperium_LL_Kernel
echo "Imperium LL Kernel script correctly applied" > /data/local/tmp/Imperium_LL_Kernel;

$BB mount -o remount,ro /system;
