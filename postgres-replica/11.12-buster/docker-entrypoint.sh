#!/usr/bin/env bash

set -Eeo pipefail

echo "[ENTRYPOING] Boot from entrypoint."

# allow the container to be started with `--user`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then
  echo "[ENTRYPOING] Configuring PGDATA..."

  mkdir -p "$PGDATA"
  chown -R postgres "$PGDATA"
  chmod 700 "$PGDATA"

  mkdir -p /var/run/postgresql
  chown -R postgres /var/run/postgresql
  chmod 775 /var/run/postgresql

  if [ -s "$PGDATA/PG_VERSION" ]; then
    # Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
    if [ "$POSTGRES_INITDB_XLOGDIR" ]; then
      mkdir -p "$POSTGRES_INITDB_XLOGDIR"
      chown -R postgres "$POSTGRES_INITDB_XLOGDIR"
      chmod 700 "$POSTGRES_INITDB_XLOGDIR"
    fi
  fi
  # exec su-exec postgres "$BASH_SOURCE" "$@"
  exec gosu postgres "$BASH_SOURCE" "$@"
fi

if [ ! -s ~/.pgpass ]; then
  echo "[ENTRYPOING] WARN the ~/.pgpass is missing!"
  echo "[ENTRYPOING] Configuring the ~/.pgpass file..."
  echo "*:*:*:$PG_REP_USERNAME:$PG_REP_PASSWORD" > ~/.pgpass
  chmod 0600 ~/.pgpass
fi

if [ ! -s "$PGDATA/PG_VERSION" ]; then

  echo "[ENTRYPOING] Setup .pgpass ..."
  echo "*:*:*:$PG_REP_USERNAME:$PG_REP_PASSWORD" > ~/.pgpass
  chmod 0600 ~/.pgpass

  until ping -c 1 -W 1 $PG_REP_HOSTNAME
  do
    echo "[ENTRYPOING] Waiting for main PG to ping at $PG_REP_HOSTNAME..."

    sleep 1s
  done

  echo "[ENTRYPOING] Starting inital pg_basebackup..."
  until pg_basebackup -h $PG_REP_HOSTNAME -D ${PGDATA} -U $PG_REP_USERNAME -p $PG_REP_PORT -vP -Xs -R
  do
    echo "[ENTRYPOING] Waiting for main PG to ping..."
    sleep 1s
  done
fi

if [ ! -s "$PGDATA/postgresql.conf" ]; then
  echo "[ENTRYPOING] Coping postgresql conf files..."
  cp /tmp-conf/*  ${PGDATA}
fi

# sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf

exec "$@"
