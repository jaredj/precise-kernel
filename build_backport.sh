#!/bin/sh
set -e
set -x

for debian_dir in "${1}/debian" "${1}/debian.master"; do
    changelog_file="${debian_dir}/changelog"
    test -f $changelog_file || continue
    echo "Modifying $changelog_file"
    debchange \
        --changelog "$changelog_file" \
        --local "~${VERSION}" \
        --distribution "${DISTRIBUTION}" \
        --force-distribution \
        "Backport for Precise."

    # Validate version change somewhat
    head -n1 $changelog_file \
        | grep "~${VERSION}" \
        | grep "${DISTRIBUTION}"

done

cd $1 && debuild -i -uc -us
cd .. && rm -rf $1
