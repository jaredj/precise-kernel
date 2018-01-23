#!/bin/sh

cd /build/

# Buid kernel with module and abi checks disabled because they fail
# with the funky backports version number
./build_backport.sh linux-3.13.0 \
    --preserve-envvar=CCACHE_DIR \
    --prepend-path=/usr/lib/ccache \
    --set-envvar skipmodule=true \
    --set-envvar skipabi=true

ccache -s

#dpkg-scanpackages . | gzip -9c > Packages.gz

cp * /out/
