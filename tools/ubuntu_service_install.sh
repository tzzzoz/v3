#!/bin/sh
if [ `id -u` != 0 ]; then
  echo you must run $(basename $0) as root
  exit
fi
cd $(dirname $0)
/usr/sbin/update-rc.d -f pw_processors remove
rm /etc/init.d/pw_processors
sed -e "s:WORKING_DIR:$(pwd):g" pw_processors > /etc/init.d/pw_processors
chmod 755 /etc/init.d/pw_processors
/usr/sbin/update-rc.d -f pw_processors defaults 99 00