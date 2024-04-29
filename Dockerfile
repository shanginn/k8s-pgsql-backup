FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y postgresql-common gnupg curl unzip && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get install postgresql-15 -y && \
    apt-get clean

RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip && \
    cp rclone-*-linux-amd64/rclone /usr/bin/ && \
    rm -rf rclone-*-linux-amd64 rclone-current-linux-amd64.zip && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

COPY --link backup.sh /usr/local/bin/run-pgsql-backup

ENTRYPOINT ["/usr/local/bin/run-pgsql-backup"]