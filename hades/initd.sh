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

RUN=/hades/busybox;
LOGFILE=/data/hades/initd.log


log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}
log_print "------------------------------------------------------"
log_print "**hades initd script started at $( date +"%d-%m-%Y %H:%M:%S" )**"
# Create init.d folder if not exist
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d;
	$RUN chmod 0755 /system/etc/init.d;
	$RUN chmod 777 /system/etc/init.d/*
fi

killer=/system/etc/init.d/99killer
if [ ! -s $killer ]; then 
    cp /hades/99killer /system/etc/init.d/99killer
	$RUN chmod 777 /system/etc/init.d/99killer
fi

# Execute scripts
if [[ ! -e /system/xbin/run-parts ]]; then
/system/xbin/run-parts /system/etc/init.d
else
for FILE in /system/etc/init.d/*; do
	sh $FILE >/dev/null
done;
fi

# FS Triming
$run fstrim -v /system
$run fstrim -v /data
$run fstrim -v /cache

# Exit
   log_print "**hades initd script finished at $( date +"%d-%m-%Y %H:%M:%S" )**"
   log_print "------------------------------------------------------"

