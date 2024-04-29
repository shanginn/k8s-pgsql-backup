#!/bin/bash
set -ex

echo "Backup start at $(date)"

pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" | xz -9e > db.xz
echo "Backup created with size $(du -h db.xz | awk '{print $1}')"

wrangler r2 object put "pgsql-backup/db_$(date +%Y-%m-%d_%H_%M).xz" --file=db.xz

echo "Backup complete at $(date)"