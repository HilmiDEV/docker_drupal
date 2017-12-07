#!/bin/sh
set -e

STDERR () {
    cat - 1>&2
}

if [ "$1" = 'postgres' ]; then
    # exit if postgres directory does not already exist
    [ -d "$PGDATA" ] || (echo "PGDATA=$PGDATA does not exist" | STDERR && exit 1)
    echo '##### chown'
    chown -R postgres "$PGDATA"

    # if data directory does not have any files
    # initialize database in its place
    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb --encoding="UTF8"

        sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

        # Increase the number of max connection pool
        sed -i -e "s/max_connections = 100/max_connections = 1000/g" "$PGDATA"/postgresql.conf

        { echo; echo 'host all all 0.0.0.0/0 md5'; } >> "$PGDATA"/pg_hba.conf
        echo '##### start postgresql for cstl init'
        exec gosu postgres /usr/bin/"$@" -D "$PGDATA" -c config_file="$PGDATA"/postgresql.conf &
        # Perform all actions as $POSTGRES_USER
        export PGUSER="$POSTGRES_USER"
	    sleep 5
        echo 'creating geoadmin user'
        gosu postgres createuser -d -r -s geoadmin
        echo 'created geoadmin user'

        # Create drupal DB
        echo 'creating drupal db'
        gosu postgres createdb -O geoadmin -E UTF8 -T template0 drupal
        echo 'created drupal db'

        # alter cstl user and role
        gosu postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"drupal\" to geoadmin;
            ALTER ROLE geoadmin WITH PASSWORD 'g3o4dmin'"
        echo 'altered geoadmin user'
        kill -INT `head -1 "$PGDATA"/postmaster.pid`
        sleep 5
        echo 'kill postgresql'
    fi

fi


# command is a postgres executable hence execute it as postgres user
if [ -x /usr/bin/"$1" ]; then
    echo "executing as postgres user"
    exec gosu postgres /usr/bin/"$@" -D "$PGDATA" -c config_file="$PGDATA"/postgresql.conf
else
  echo "executing what else"
    exec "$@"
fi
