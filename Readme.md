# Backport Trusty kernel package to Precise

There are security updates to the 3.13.0 kernel publicly available for use in Trusty, but not Precise.  It may be possible to backport these packages for use on systems unfortunate enough to be running Precise that need these security updates.

# Build instructions

```sh
docker build -t build-kernel .
docker run -it -v "${PWD}/output:/packages" build-kernel
```

All debian packages built in the docker container will appear in the `output` directory.
