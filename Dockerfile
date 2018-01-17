FROM ubuntu:precise

# Set locale to fix character encoding
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

ENV DEBIAN_FRONTEND=noninteractive

# Copy trusty sources to precise system
COPY trusty-source-packages.list /etc/apt/sources.list.d/trust-sources.list

# Install dependencies and utilities
RUN apt-get update && apt-get install -y \
  devscripts \
  debian-keyring \
  less \
  vim 

WORKDIR /build

# Backport build deps that aren't shipped in precise; we must install these
# before attempting to use apt to install the rest of our build deps
RUN apt-get -y build-dep \
  libiberty-dev \
  libunwind8-dev

RUN apt-get source -b \
  libiberty-dev \
  libunwind8-dev

RUN dpkg -i \
  libiberty-dev_20131116-1ubuntu0.2_amd64.deb \
  libunwind8_1.1-2.2ubuntu3_amd64.deb \
  libunwind8-dev_1.1-2.2ubuntu3_amd64.deb

# None of this is shipped
RUN rm -rf /build/*

# Install deps and fetch source for DKMS and kernel
RUN apt-get -y build-dep \
  dkms \
  linux-image-3.13.0-139-generic
RUN apt-get source \
  dkms \
  linux-meta \
  linux-image-3.13.0-139-generic

# Set name and email that will appear in changelog entries
ENV NAME Jared Johnson
ENV EMAIL jjohnson@efolder.net

COPY build_backport.sh /build
RUN ./build_backport.sh dkms-2.2.0.3
RUN ./build_backport.sh linux-meta-3.13.0.139.148
RUN ./build_backport.sh linux-3.13.0

# Create ad-hoc repository for easy distribution
WORKDIR /packages
RUN mv /build/*.deb /build/*.changes /packages/
RUN dpkg-scanpackages . | gzip -9c > Packages.gz


VOLUME /out

# Copy build packages to volume
CMD cp /packages/* /out/
