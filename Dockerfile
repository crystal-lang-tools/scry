FROM crystallang/crystal:0.36.1-build

RUN apt-get update
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.cache/crystal

ADD . /opt/scry
