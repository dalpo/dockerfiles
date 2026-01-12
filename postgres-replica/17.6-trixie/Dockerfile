########################################################################
# Required ENV vars:
# - $PG_REP_HOSTNAME
# - $PG_REP_USERNAME
# - $PG_REP_PASSWORD
# - $PG_REP_PORT
########################################################################

FROM postgres:17.6-trixie

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y iputils-ping

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN mkdir -p /tmp-conf
COPY ./pg_hba.conf ./pg_ident.conf ./postgresql.conf /tmp-conf/
RUN chown -R postgres:postgres /tmp-conf

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432

CMD ["postgres"]
