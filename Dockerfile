FROM oven/bun:latest

RUN bun install -g wrangler

RUN ln -s /usr/local/bin/bun /bin/node

COPY --link backup.sh /usr/local/bin/run-pgsql-backup