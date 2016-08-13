FROM ubuntu

RUN apt-get update

RUN apt-get -y install \
  libbsd-dev \
  libedit-dev \
  libevent-core-2.0-5 \
  libevent-dev \
  libevent-extra-2.0-5 \
  libevent-openssl-2.0-5 \
  libevent-pthreads-2.0-5 \
  libgmp-dev \
  libgmpxx4ldbl \
  libpcl1-dev \
  libssl-dev \
  libxml2-dev \
  libyaml-dev \
  libreadline-dev \
  llvm-3.6 \
  curl \
  apt-transport-https \
  pkg-config

RUN apt-get -y install llvm-3.6-dev

RUN curl https://dist.crystal-lang.org/apt/setup.sh | bash
RUN apt-get -y install crystal

RUN mkdir -p /root/.cache/crystal

ADD . /opt/scry
