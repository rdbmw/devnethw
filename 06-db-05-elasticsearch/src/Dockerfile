FROM elasticsearch:8.2.3

USER root

RUN mkdir /var/lib/log && \
    chown elasticsearch /var/lib/log &&\
    mkdir /var/lib/data && \
    chown elasticsearch /var/lib/data

COPY --chown=elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/

USER elasticsearch