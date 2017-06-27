FROM crystallang/crystal:0.22.0



RUN apt-get update && \
    apt-get install -y build-essential curl libevent-dev git libxml2-dev \
    llvm-3.5 llvm-3.5-dev llvm3.5-dbg libedit-dev libncurses-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.cache/crystal

ADD . /opt/scry
