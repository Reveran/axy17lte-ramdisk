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
#
# resetprop by @nkk71 (R.I.P.), renamed to fakeprop to avoid Magisk conflicts
#

LOGFILE=/data/hades/boot.log

log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}
if [ ! -e /data/hades ]; then
	mkdir /data/hades
	chown -R root.root /data/hades
	chmod -R 755 /data/hades
fi

log_print "------------------------------------------------------"
log_print "**hades early boot script started at $( date +"%d-%m-%Y %H:%M:%S" )**"
# Tamper fuse prop set to 0 on running system
/sbin/fakeprop -n ro.boot.warranty_bit "0"
/sbin/fakeprop -n ro.warranty_bit "0"

# Deepsleep fix @Chainfire
for i in `ls /sys/class/scsi_disk/`; do
	cat /sys/class/scsi_disk/$i/write_protect 2>/dev/null | grep 1 >/dev/null
	if [ $? -eq 0 ]; then
		echo 'temporary none' > /sys/class/scsi_disk/$i/cache_type
	fi
done
   log_print "**hades early boot script finished at $( date +"%d-%m-%Y %H:%M:%S" )**"
   log_print "------------------------------------------------------"

