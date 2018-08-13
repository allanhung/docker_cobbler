#!/bin/bash

set -ex
if [ ! $SERVER_IP ]
then
        echo "Please use $SERVER_IP set the IP address of the need to monitor."
        exit 1
elif [ ! $ROOT_PASSWORD ]
then
        echo "Please use $ROOT_PASSWORD set the root password."
        exit 1
else
        PASSWORD=`openssl passwd -1 -salt hLGoLIZR $ROOT_PASSWORD`
        sed -i -e "s/^server:.*/server: $SERVER_IP/g" /etc/cobbler/settings
        sed -i -e "s/^next_server:.*/next_server: $SERVER_IP/g" /etc/cobbler/settings
        sed -i -e "s/allow_dynamic_settings:.*/allow_dynamic_settings: 1/g" /etc/cobbler/settings
        sed -i -e "s/pxe_just_once:.*/pxe_just_once: 1/g" /etc/cobbler/settings
        sed -i -e "s/manage_dhcp:.*/manage_dhcp: 0/g" /etc/cobbler/settings
        sed -i -e "s#^default_password.*#default_password_crypted: \"$PASSWORD\"#g" /etc/cobbler/settings
        sed -i -e "s/service %s restart/supervisorctl restart %s/g" /usr/lib/python2.7/site-packages/cobbler/modules/sync_post_restart_services.py

#        /usr/sbin/nginx
#        /usr/bin/cobblerd
#        cobbler sync

#        pkill cobblerd
#        pkill nginx

        exec /usr/bin/supervisord -nc /etc/supervisord.conf
fi
