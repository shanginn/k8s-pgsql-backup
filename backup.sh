#!/bin/bash
set -ex

echo "Backup start at $(date)"

pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" | 7z a -si db.7z
echo "Backup created with size $(du -h db.7z | awk '{print $1}')"

wrangler r2 object put "pgsql-backup/db_$(date +%Y-%m-%d_%H_%M).7z" --file=db.7z

echo "Backup complete at $(date)"