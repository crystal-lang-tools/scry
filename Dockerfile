FROM crystallang/crystal:0.30.1

RUN apt-get update
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.cache/crystal

ADD . /opt/scry
