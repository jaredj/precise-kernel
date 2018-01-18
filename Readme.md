# Backport Trusty kernel package to Precise

There are security updates to the 3.13.0 kernel publicly available for use in Trusty, but not Precise.  It may be possible to backport these packages for use on systems unfortunate enough to be running Precise that need these security updates.

# Build instructions

## General

```sh
docker build -t build-kernel .
docker run -it -v "${PWD}/output:/out" build-kernel
```

All packages built in the docker container will appear in the `output` directory.

## Replibit-specific example

```sh
rm output/*

docker build \
    --build-arg name="Jared Johnson" \
    --build-arg email="jjohnson@efolder.net" \
    --build-arg version="efs1204+0" \
    --build-arg distribution="rb-precise-alpha" \
    -t \
    build-kernel \
    .

docker run -it -v "${PWD}/output:/out" build-kernel

# dput output/*
# scp output/* user@repository:/upload-location/
```

