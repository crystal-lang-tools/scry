FROM crystallang/crystal:0.24.1

RUN apt-get update
RUN apt-get install -y llvm-4.0-dev
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.cache/crystal

ADD . /opt/scry
