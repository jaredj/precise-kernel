#!/bin/sh
set -e
set -x

cd $1/

debchange \
    --local "~${VERSION}" \
    --distribution "${DISTRIBUTION}" \
    --force-distribution \
    "Backport for Precise."

# Validate version change somewhat
head -n1 debian/changelog \
    | grep "~${VERSION}" \
    | grep "${DISTRIBUTION}"

debuild -i -uc -us

cd ..
rm -rf $1
