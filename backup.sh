#!/bin/bash
set -e

export RCLONE_CONFIG_CLOUDFLARE_TYPE=s3
export RCLONE_CONFIG_CLOUDFLARE_PROVIDER=Cloudflare
export RCLONE_CONFIG_CLOUDFLARE_REGION=auto
export RCLONE_CONFIG_CLOUDFLARE_ACL=private
export RCLONE_CONFIG_CLOUDFLARE_ACCESS_KEY_ID=$CLOUDFLARE_ACCESS_KEY_ID
export RCLONE_CONFIG_CLOUDFLARE_SECRET_ACCESS_KEY=$CLOUDFLARE_SECRET_ACCESS_KEY
export RCLONE_CONFIG_CLOUDFLARE_ENDPOINT="https://${CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com"

DB_NAME=$1
FILENAME="$(date +%Y-%m-%d_%H_%M).xz"

if [ -z "$DB_NAME" ]; then
    echo "No database name provided. Exiting."
    exit 1
fi

# Ensure required environment variables are set
: "${CLOUDFLARE_ACCOUNT_ID:?CLOUDFLARE_ACCOUNT_ID environment variable not set.}"
: "${CLOUDFLARE_ACCESS_KEY_ID:?CLOUDFLARE_ACCESS_KEY_ID environment variable not set.}"
: "${CLOUDFLARE_SECRET_ACCESS_KEY:?CLOUDFLARE_SECRET_ACCESS_KEY environment variable not set.}"
: "${PGHOST:?PGHOST environment variable not set.}"
: "${PGPORT:?PGPORT environment variable not set.}"
: "${PGUSER:?PGUSER environment variable not set.}"

echo "Backup start at $(date) for database '$DB_NAME'"

pg_dump -v -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" --exclude-table=generation_text_to_images | xz -9e > "$FILENAME"
BACKUP_SIZE=$(du -h "$FILENAME" | awk '{print $1}')
echo "Local backup created: $FILENAME with size $BACKUP_SIZE"

if [ ! -s "$FILENAME" ]; then
    echo "Backup file $FILENAME is empty or does not exist. Exiting."
    rm -f "$FILENAME" # Clean up empty file
    exit 1
fi

# --- Upload Backup ---
REMOTE_PATH="cloudflare:pgsql-backup/${DB_NAME}/"
echo "Uploading $FILENAME to $REMOTE_PATH"
rclone copy "$FILENAME" "$REMOTE_PATH"
echo "Upload complete."

# Clean up local file
rm "$FILENAME"
echo "Local backup file $FILENAME removed."

# --- Cleanup Old Backups ---
echo "Cleaning up old backups in $REMOTE_PATH"

rclone delete "$REMOTE_PATH" --min-age 10d
echo "Old backups deleted."

echo "Backup process complete at $(date)"