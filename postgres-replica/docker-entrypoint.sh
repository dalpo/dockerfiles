#!/usr/bin/env bash

set -Eeo pipefail

# allow the container to be started with `--user`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then
  mkdir -p "$PGDATA"
  chown -R postgres "$PGDATA"
  chmod 700 "$PGDATA"

  mkdir -p /var/run/postgresql
  chown -R postgres /var/run/postgresql
  chmod 775 /var/run/postgresql

  # Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
  if [ "$POSTGRES_INITDB_XLOGDIR" ]; then
    mkdir -p "$POSTGRES_INITDB_XLOGDIR"
    chown -R postgres "$POSTGRES_INITDB_XLOGDIR"
    chmod 700 "$POSTGRES_INITDB_XLOGDIR"
  fi

  exec su-exec postgres "$BASH_SOURCE" "$@"
fi

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "*:*:*:$PG_REP_USERNAME:$PG_REP_PASSWORD" > ~/.pgpass
  chmod 0600 ~/.pgpass

  until ping -c 1 -W 1 $PG_REP_HOSTNAME
  do
    echo "Waiting for master to ping..."
    sleep 1s
  done

  until pg_basebackup -h $PG_REP_HOSTNAME -D ${PGDATA} -U $PG_REP_USERNAME -p $PG_REP_PORT -vP -Xs -R
  do
    echo "Waiting for master to connect..."
    sleep 1s
  done

  cp /tmp-conf/*  ${PGDATA}
fi

# sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf

exec "$@"
