#!/bin/bash
set -e

export RCLONE_CONFIG_CLOUDFLARE_TYPE=s3
export RCLONE_CONFIG_CLOUDFLARE_PROVIDER=Cloudflare
export RCLONE_CONFIG_CLOUDFLARE_REGION=auto
export RCLONE_CONFIG_CLOUDFLARE_ACL=private
export RCLONE_CONFIG_CLOUDFLARE_ACCESS_KEY_ID=$CLOUDFLARE_ACCESS_KEY_ID
export RCLONE_CONFIG_CLOUDFLARE_SECRET_ACCESS_KEY=$CLOUDFLARE_SECRET_ACCESS_KEY
export RCLONE_CONFIG_CLOUDFLARE_ENDPOINT="https://${CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com/pgsql-backup"

DB_NAME=$1
FILENAME="$(date +%Y-%m-%d_%H_%M).xz"

if [ -z "$DB_NAME" ]; then
    echo "No database name provided. Exiting."
    exit 1
fi

echo "Backup start at $(date)"

pg_dump -v -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" | xz -9e > "$FILENAME"
echo "Backup created with size $(du -h "$FILENAME" | awk '{print $1}')"

# name `cloudflare` comes from env variables names RCLONE_CONFIG_CLOUDFLARE_*
rclone copy "$FILENAME" cloudflare:"${DB_NAME}/"

echo "Backup complete at $(date)"