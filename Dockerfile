From centos:latest

ENV RPMBUILDROOT=/root/rpmbuild

RUN mkdir -p $RPMBUILDROOT/SOURCES && mkdir -p $RPMBUILDROOT/SPECS && mkdir -p $RPMBUILDROOT/SRPMS
RUN yum install -y rpm-build make patch tftp-server dhcp openssl epel-release
RUN yum install -y git python2-devel PyYAML python-cheetah python-setuptools supervisor debmirror cman fence-agents && yum clean all
RUN sed -i -e "s/^@dists/#@dists/g" -e "s/^@arches/#@arches/g" /etc/debmirror.conf

# fix rpm marcos
RUN sed -i -e "s#.centos##g" /etc/rpm/macros.dist

# cobbler
RUN curl -s -o $RPMBUILDROOT/SRPMS/cobbler-2.8.3-2.el7.src.rpm http://rpmfind.net/linux/epel/7/SRPMS/Packages/c/cobbler-2.8.3-2.el7.src.rpm
RUN rpm -i $RPMBUILDROOT/SRPMS/cobbler-2.8.3-2.el7.src.rpm
COPY ./sources/cobbler-2.8.3.patch $RPMBUILDROOT/SPECS/
COPY ./sources/cobbler-nginx-2.8.3.patch $RPMBUILDROOT/SOURCES/
COPY ./sources/cobbler-*.ini $RPMBUILDROOT/SOURCES/
COPY ./sources/cobbler-*.conf $RPMBUILDROOT/SOURCES/
RUN cd $RPMBUILDROOT/SPECS && patch -p1 < $RPMBUILDROOT/SPECS/cobbler-2.8.3.patch && rpmbuild -bb cobbler.spec

RUN yum localinstall -y $RPMBUILDROOT/RPMS/noarch/cobbler-*${COBBERVER}*.rpm $RPMBUILDROOT/RPMS/x86_64/cobbler-*${COBBERVER}*.rpm && yum clean all
RUN rm -rf $RPMBUILDROOT/SOURCES && rm -rf $RPMBUILDROOT/SPECS && rm -rf $RPMBUILDROOT/SRPMS && rm -rf $RPMBUILDROOT/RPMS
COPY sources/loaders/* /var/lib/cobbler/loaders/
RUN mkdir -p /var/lib/cobbler/snippets/custom

VOLUME ["/var/www/cobbler/images", "/var/www/cobbler/ks_mirror", "/var/www/cobbler/links", "/var/www/cobbler/repo_mirror", "/var/lib/cobbler/config", "/var/lib/cobbler/kickstarts", "/var/lib/cobbler/loaders", "/var/lib/cobbler/snippets", "/var/lib/tftpboot", "/mnt"]

COPY sources/docker-entrypoint.sh /usr/bin/
COPY sources/supervisor/*.ini /etc/supervisord.d/
 
EXPOSE 69
EXPOSE 80
EXPOSE 25151

RUN ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh
CMD ["docker-entrypoint.sh"]
