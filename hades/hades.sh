#!/system/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Originally Coded by Tkkg1994 @GrifoDev, enhanced by BlackMesa @XDAdevelopers
# enhanced once again corsicanu @XDAdevelopers with some code from 6h0st@ghost.com.ro
# resetprop by @nkk71 (R.I.P.), renamed to fakeprop to avoid Magisk conflicts
#

PATH=/sbin:/system/sbin:/system/bin:/system/xbin:/hades
export PATH
RUN=/hades/busybox;
LOGFILE=/data/hades/boot.log
REBOOTLOGFILE=/data/hades/reboot.log

log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}
rebootlog_print() {
  echo "$1"
  echo "$1" >> $REBOOTLOGFILE
}

if [ ! -e /data/hades ]; then
	mkdir -p /data/hades
	chown -R root.root /data/hades
	chmod -R 755 /data/hades
fi

for FILE in /data/hades/*; do
	$RUN rm -f $FILE
done;

log_print "------------------------------------------------------"


log_print "------------------------------------------------------"
log_print "**hades boot script started at $( date +"%d-%m-%Y %H:%M:%S" )**"

if [ -z "$(ls -A /data/dalvik-cache/arm64)" ]; then
   rebootlog_print "dalvik cache not built, rebooted at $( date +"%d-%m-%Y %H:%M:%S" )"
   reboot
else
   log_print "dalvik cache already built, nothing to do"
fi

# Initial
mount -o remount,rw -t auto /
mount -t rootfs -o remount,rw rootfs
mount -o remount,rw -t auto /system
mount -o remount,rw /data
mount -o remount,rw /cache

# Change to Enforce Status.
chmod 644 /sys/fs/selinux/enforce
setenforce 0
# Fix SafetyNet by Repulsa
chmod 640 /sys/fs/selinux/enforce

## Custom FLAGS reset
# Tamper fuse prop set to 0 on running system
/hades/fakeprop -n ro.boot.warranty_bit "0"
/hades/fakeprop -n ro.warranty_bit "0"
# Fix safetynet flags
/hades/fakeprop -n ro.boot.veritymode "enforcing"
/hades/fakeprop -n ro.boot.verifiedbootstate "green"
/hades/fakeprop -n ro.boot.flash.locked "1"
/hades/fakeprop -n ro.boot.ddrinfo "00000001"
/hades/fakeprop -n ro.build.selinux "1"
# Samsung related flags
/hades/fakeprop -n ro.fmp_config "1"
/hades/fakeprop -n ro.boot.fmp_config "1"
/hades/fakeprop -n sys.oem_unlock_allowed "0"

# Panic off
$RUN sysctl -w vm.panic_on_oom=0
$RUN sysctl -w kernel.panic_on_oops=0
$RUN sysctl -w kernel.panic=0

# RMM patch (part)
if [ -d /system/priv-app/Rlc ]; then
	rm -rf /system/priv-app/Rlc
fi
# Disabling unauthorized changes warnings...
if [ -d /system/app/SecurityLogAgent ]; then
rm -rf /system/app/SecurityLogAgent
fi

# Tweaking logging, debugubg, tracing
dmesg -n 1 -C
$RUN echo "N" > /sys/kernel/debug/debug_enabled
$RUN echo "N" > /sys/kernel/debug/seclog/seclog_debug
$RUN echo "0" > /sys/kernel/debug/tracing/tracing_on

# Deepsleep fix @Chainfire
for i in `ls /sys/class/scsi_disk/`; do
	cat /sys/class/scsi_disk/$i/write_protect 2>/dev/null | grep 1 >/dev/null
	if [ $? -eq 0 ]; then
		echo 'temporary none' > /sys/class/scsi_disk/$i/cache_type
	fi
done

# Google play services wakelock fix
sleep 1
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"


mount -o remount,ro -t auto /
mount -t rootfs -o remount,ro rootfs
mount -o remount,ro -t auto /system
mount -o remount,rw /data
mount -o remount,rw /cache

   log_print "**hades early boot script finished at $( date +"%d-%m-%Y %H:%M:%S" )**"
   log_print "------------------------------------------------------"

