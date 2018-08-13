# docker for cobbler

## How to Build
```sh
git clone https://github.com/allanhung/docker_cobbler
cd docker_cobbler
docker build -t cobbler_centos:2.8.3 -f Dockerfile .
``

## How to use
```sh
mkdir -p /opt/cobbler/data
tar -zxf example/cobbler_init_data.tar.gz -C /opt/cobbler/data/

docker run -d --name=cobbler --net=host \
 -v /opt/cobbler/data/nginx/nginx.conf:/etc/nginx/nginx.conf \
 -v /opt/cobbler/data/nginx/conf.d/cobbler.conf:/etc/nginx/conf.d/cobbler.conf \
 -v /opt/cobbler/data/dhcp/dhcp.template:/etc/dhcp/dhcpd.conf \
 -v /opt/cobbler/data/tftpboot:/var/lib/tftpboot/ \
 -v /opt/cobbler/data/var/www/cobbler/images:/var/www/cobbler/images \
 -v /opt/cobbler/data/var/www/cobbler/ks_mirror:/var/www/cobbler/ks_mirror \
 -v /opt/cobbler/data/var/www/cobbler/links:/var/www/cobbler/links \
 -v /opt/cobbler/data/var/www/cobbler/repo_mirror:/var/www/cobbler/repo_mirror \
 -v /opt/cobbler/data/var/lib/cobbler/config:/var/lib/cobbler/config \
 -v /opt/cobbler/data/var/lib/cobbler/loaders:/var/lib/cobbler/loaders \
 -v /opt/cobbler/data/var/lib/cobbler/kickstarts:/var/lib/cobbler/kickstarts \
 -v /opt/cobbler/data/var/lib/cobbler/snippets:/var/lib/cobbler/snippets \
 -v /opt/cobbler/iso:/mnt \
 -e "SERVER_IP=`ip addr show dev eth0 |grep inet|head -n 1|awk '{print $2}' |awk -F'/' '{print $1}'`" \
 -e "ROOT_PASSWORD=`openssl passwd -1 'mypassword'`" \
 cobbler_centos:2.8.3
``

## import iso example
```sh
mount -t iso9660 -o loop CentOS-7-x86_64-Minimal-1611.iso /mnt
rsync -avP /mnt/* /opt/cobbler/iso/
umount /mnt
docker exec -ti cobbler /bin/bash
cobbler import --path=/mnt --name=centos-73 --arch=x86_64 --kickstart=/var/lib/cobbler/kickstarts/centos-73.ks
exit
rm -rf /opt/cobbler/iso/*
``

## create system
```sh
cobbler system add  --name=woo01.ts1.ux --profile=centos-71-mini-x86_64 --hostname=woo01.ts1.ux
cobbler system edit --name=woo01.ts1.ux --interface=eth0 --mac=00:0c:29:d9:ed:53 --static=1  --ip-address=10.168.25.11 --netmask=255.255.248.0 --if-gateway=10.168.24.254 --name-servers=10.168.24.1 --mtu=1500
cobbler system edit --name=woo01.ts1.ux --ksmeta="swapsize=4096  tree=http://192.168.24.250/cblr/links/centos-71-mini-x86_64 server=192.168.24.250"
``
