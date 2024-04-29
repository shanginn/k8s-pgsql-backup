FROM oven/bun:latest

RUN bun install -g wrangler
RUN apt-get update && \
    apt-get install -y postgresql-common gnupg && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get install postgresql-15 -y && \
    apt-get clean

RUN ln -s /usr/local/bin/bun /bin/node

COPY --link backup.sh /usr/local/bin/run-pgsql-backup