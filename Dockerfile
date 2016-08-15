FROM crystallang/crystal:0.18.7



RUN apt-get update && \
    apt-get install -y build-essential curl libevent-dev git libxml2-dev llvm-3.6 llvm-3.6-dev libedit-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ADD . /opt/scry
