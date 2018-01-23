#!/bin/sh
docker build \
    --build-arg name="Jared Johnson" \
    --build-arg email="jjohnson@efolder.net" \
    --build-arg version="efs1204+0" \
    --build-arg distribution="rb-precise-alpha" \
    -t \
    build-kernel \
    .

docker create \
    -v ccache:/ccache \
    --name ccache \
    build-kernel
docker run \
    --rm \
    --volumes-from ccache \
    -it \
    -v "${PWD}/output:/out" \
    build-kernel
