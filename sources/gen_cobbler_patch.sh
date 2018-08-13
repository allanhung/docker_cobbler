#!/bin/bash

tar -zxf $RPMBUILDROOT/SOURCES/cobbler-2.8.3.tar.gz -C /tmp && cp -rf /tmp/cobbler-2.8.3 /tmp/cobbler-2.8.3.ori
cd /tmp/cobbler-2.8.3 && patch -p1 < $RPMBUILDROOT/SOURCES/cobbler-nginx-2.8.3.patch
# wait for fix patch reject
read -n 1 -s -r -p "Press any key to continue when patch fixed"
find /tmp/cobbler-2.8.3 -iname "*.rej" |xargs rm -f
find /tmp/cobbler-2.8.3 -iname "*.orig" |xargs rm -f
rm -f /tmp/cobbler-nginx-2.8.3.patch
diff -qr /tmp/cobbler-2.8.3.ori /tmp/cobbler-2.8.3 | awk {'print "diff -uN "$2" "$4" >> /tmp/cobbler-nginx-2.8.3.patch"'} | bash
sed -i -e "s#/tmp/cobbler-2.8.3.ori#a#g" /tmp/cobbler-nginx-2.8.3.patch
sed -i -e "s#/tmp/cobbler-2.8.3#b#g" /tmp/cobbler-nginx-2.8.3.patch
/bin/cp -f /tmp/cobbler-nginx-2.8.3.patch $RPMBUILDROOT/SOURCES/
