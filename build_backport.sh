#!/bin/sh
set -e

cd $1/

debchange \
    --local "~efs1204+0" \
    "Backport for Precise."

debuild -i -uc -us

cd ..
rm -rf $1
