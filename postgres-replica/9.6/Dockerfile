########################################################################
# Required ENV vars:
# - $PG_REP_HOSTNAME
# - $PG_REP_USERNAME
# - $PG_REP_PASSWORD
########################################################################

FROM postgres:9.6-alpine

RUN apk add --update iputils

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN mkdir -p /tmp-conf
COPY ./pg_hba.conf ./pg_ident.conf ./postgresql.conf /tmp-conf/
RUN chown -R postgres:postgres /tmp-conf

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432

CMD ["postgres"]
