#!/bin/sh

# This script is run by cron to periodically update the database.
# The config.ini file is already present, created by the main entrypoint.

echo "Starting database update at $(date)"

PYTHONPATH=/app/scripts /usr/local/bin/python /app/scripts/download_and_index.py --no_upload --config /app/config.ini

echo "Database update completed at $(date)"
