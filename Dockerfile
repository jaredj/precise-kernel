FROM ubuntu:precise

# Set locale to fix character encoding
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16126D3A3E5C1192

ENV DEBIAN_FRONTEND=noninteractive

# Copy trusty sources to precise system
COPY trusty-source-packages.list /etc/apt/sources.list.d/

# Install dependencies and utilities
RUN apt-get update && apt-get install -y \
  ccache \
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
RUN apt-get update && apt-get -y build-dep \
  dkms \
  linux-image-3.13.0-143-generic
RUN apt-get update && apt-get source \
  dkms \
  linux-meta \
  linux-image-3.13.0-143-generic

# Set name and email that will appear in changelog entries
ARG name="Backport Builder"
ARG email="nowhere@example.com"
ARG version="backport"
ARG distribution="precise"
ENV NAME=${name}
ENV EMAIL=${email}
ENV VERSION=${version}
ENV DISTRIBUTION=${distribution}

COPY build_backport.sh /build
RUN ./build_backport.sh dkms-2.2.0.3
RUN ./build_backport.sh linux-meta-3.13.0.143.153

# If apt ever tries to upgrade the kernel before upgrading DKMS, it
# will break things horribly; use Breaks: in debian/control to avoid that
ENV stub_file linux-3.13.0/debian.master/control.d/flavour-control.stub
RUN awk '/^Package: linux-image-/{print;print "Breaks: dkms (<< 2.2.0.3-1.1ubuntu5.14.04.9~), e1000e-dkms (<< 3.4.0.2), ixgbe-dkms (<< 5.3.6)";next}1' ${stub_file} > ${stub_file}.new
RUN mv ${stub_file}.new ${stub_file}
# Some validation
RUN grep "Breaks: dkms" ${stub_file} >/dev/null 2>&1
RUN grep "e1000e-dkms (<<" ${stub_file} >/dev/null 2>&1
RUN grep "ixgbe-dkms (<<" ${stub_file} >/dev/null 2>&1

# Avoid attempting to compile with retpoline since Precise GCC doesn't support it
ENV config_file linux-3.13.0/debian.master/config/config.common.ubuntu
RUN sed -i 's/CONFIG_RETPOLINE=y/CONFIG_RETPOLINE=n/' ${config_file}

ENV previous_abi_dir linux-3.13.0/debian.master/abi/3.13.0-143.192
RUN mkdir -p ${previous_abi_dir}/amd64
RUN mkdir -p ${previous_abi_dir}/i386
RUN mkdir -p ${previous_abi_dir}/armhf
RUN mkdir -p ${previous_abi_dir}/arm64
RUN mkdir -p ${previous_abi_dir}/powerpc
RUN mkdir -p ${previous_abi_dir}/ppc64el
RUN echo "1" > ${previous_abi_dir}/amd64/ignore.retpoline
RUN echo "1" > ${previous_abi_dir}/i386/ignore.retpoline
RUN echo "1" > ${previous_abi_dir}/armhf/ignore.retpoline
RUN echo "1" > ${previous_abi_dir}/arm64/ignore.retpoline
RUN echo "1" > ${previous_abi_dir}/powerpc/ignore.retpoline
RUN echo "1" > ${previous_abi_dir}/ppc64el/ignore.retpoline

# Build it
COPY build_and_copy.sh /build
ENV CCACHE_DIR /ccache

VOLUME /out

# Copy build packages to volume
CMD ["/build/build_and_copy.sh"]
