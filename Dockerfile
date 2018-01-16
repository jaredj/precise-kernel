FROM ubuntu:precise

# Set locale to fix character encoding
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Copy trusty sources to precise system
COPY trusty-source-packages.list /etc/apt/sources.list.d/trust-sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
  vim \
  debhelper \
  kernel-wedge \
  makedumpfile \
  libelf-dev \
  libnewt-dev \
  libdw-dev \
  libpci-dev \
  pkg-config \
  flex \
  bison \
  libaudit-dev \
  bc \
  xmlto \
  docbook-utils \
  transfig \
  sharutils \
  asciidoc \
  build-essential \
  make \
  autotools-dev \
  dh-autoreconf \
  liblzma-dev \
  python-dev \
  quilt \
  debian-keyring

# Set the working directory
WORKDIR /build

# Build and install trusty build dependencies
RUN apt-get source -b \
  libiberty-dev \
  libunwind8-dev
RUN dpkg -i \
  libiberty-dev_20131116-1ubuntu0.2_amd64.deb \
  libunwind8_1.1-2.2ubuntu3_amd64.deb \
  libunwind8-dev_1.1-2.2ubuntu3_amd64.deb

# Build dkms package which will play nicer with zfs and spl
RUN apt-get source -b dkms

# Build kernel package
RUN apt-get source -b linux-image-3.13.0-139-generic

VOLUME /packages

ENTRYPOINT ["/bin/cp", "/build/*.deb", "/packages/"]

