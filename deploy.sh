#!/bin/sh
set -x

replace_first_line() {
    pattern=$1
    newline=$2
    file=$3
    sed -e "/.*${pattern}/{s//${newline}/;:a" -e '$!N;$!ba' -e '}' $file > $file.new
    mv $file.new $file
}

mv output/* deploy/

cd deploy

rm *.udeb
changes=linux_3.13.0-142.191~efs1204+01_amd64.changes

# Remove references to .udebs which break our reprepro instance
grep -v "\.udeb$" $changes > $changes.new
mv $changes.new $changes

# Somehow the wrong orig file is references in .changes even though
# the right one is referenced in the .dsc
wrong_orig=linux_3.13.0-142.191~efs1204+01_amd64.tar.gz
rm $wrong_orig
orig=linux_3.13.0.orig.tar.gz
orig_size=$(wc -c $orig | awk '{print $1}')
dsc=linux_3.13.0-142.191~efs1204+01.dsc


sha1_line=$(grep $orig $dsc | tail -n3 | head -n1)
replace_first_line "${wrong_orig}" "${sha1_line}" $changes

sha256_line=$(grep $orig $dsc | tail -n2 | head -n1)
replace_first_line "${wrong_orig}" "${sha256_line}" $changes

md5=$(grep $orig $dsc | tail -n1 | cut -d ' ' -f 2)
md5_line=" ${md5} ${orig_size} raw-ueif - $orig"
replace_first_line "${wrong_orig}" "${md5_line}" $changes

cd ..
