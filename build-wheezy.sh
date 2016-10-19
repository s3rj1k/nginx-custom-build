#!/bin/bash

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get install -y autotools-dev build-essential debhelper devscripts fakeroot dpkg-dev libexpat1-dev libgeoip-dev libpcre3-dev libssl-dev lsb-release po-debconf quilt unzip zlib1g-dev libgd2-noxpm-dev libperl-dev libxslt1-dev patch uuid-dev

git reset --hard
git clean -xfd

mv -v debian-wheezy debian

wget --no-check-certificate -qO- https://nginx.org/download/nginx-1.18.0.tar.gz | tar -xvz --strip=1 -C .

# https://www.nginx.com/blog/supporting-http2-google-chrome-users/
# https://launchpad.net/~fxr/+archive/ubuntu/nginx-alpn/+packages
mkdir -p openssl
wget --no-check-certificate -qO- https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz | tar -xvz --strip=1 -C openssl

mkdir -p modules/dav-ext
wget --no-check-certificate -qO- https://github.com/arut/nginx-dav-ext-module/archive/f5e30888a256136d9c550bf1ada77d6ea78a48af.tar.gz | tar -xvz --strip=1 -C modules/dav-ext

mkdir -p modules/push-stream
wget --no-check-certificate -qO- https://github.com/wandenberg/nginx-push-stream-module/archive/0.4.1.tar.gz  | tar -xvz --strip=1 -C modules/push-stream
patch modules/push-stream/config < push_stream.patch

# https://launchpad.net/~hda-me/+archive/ubuntu/nginx-stable
mkdir -p modules/cache_purge
wget --no-check-certificate -qO- https://github.com/FRiCKLE/ngx_cache_purge/archive/331fe43e8d9a3d1fa5e0c9fec7d3201d431a9177.tar.gz | tar -xvz --strip 1 -C modules/cache_purge
patch modules/cache_purge/config < cache_purge_dynamic.patch
patch modules/cache_purge/ngx_cache_purge_module.c < cache_purge_nginx_version.patch

mkdir -p modules/enhanced_memcached
wget --no-check-certificate -qO- https://github.com/bpaquet/ngx_http_enhanced_memcached_module/archive/b58a4500db3c4ee274be54a18abc767219dcfd36.tar.gz | tar xvz --strip=1 -C modules/enhanced_memcached

mkdir -p modules/njs
wget --no-check-certificate -qO- http://hg.nginx.org/njs/archive/0.4.1.tar.gz | tar xvz --strip=1 -C modules/njs

#patch -p0 < listen-transparent.patch

debuild --no-tgz-check -i -us -uc -b
