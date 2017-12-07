FROM alpine:3.2

MAINTAINER Christophe Mourette <christophe.mourette@geomatys.com>

RUN mkdir -p /var/lib/postgresql/data && \
    mkdir -p /var/log/postgresql && \
    mkdir -p /data && \
    mkdir -p /var/lib/elasticsearch && \
    chmod 777 /var/lib/elasticsearch && \
    mkdir -p /var/log/elasticsearch && \
    chmod 777 /var/log/elasticsearch

VOLUME ["/var/log/postgresql", "/var/lib/postgresql/data", "/data", "/var/lib/elasticsearch", "/var/log/elasticsearch"]
