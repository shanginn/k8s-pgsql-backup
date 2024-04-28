FROM oven/bun:latest

RUN bun install wrangler

COPY --link backup.sh /usr/local/bin/run-pgsql-backup