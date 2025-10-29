#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Set default values for environment variables (PORT is set in Dockerfile).
: "${TITLE:=My Game Cache}"
: "${BGG_USERNAME:=bgg_username}"
: "${UPDATE_INTERVAL_MINUTES:=60}"

# --- Initial Setup ---

# 1. Generate config.ini from environment variables.
CONFIG_PATH="/app/config.ini"
echo "title=${TITLE}\nbgg_username=${BGG_USERNAME}\ngithub_repo=" > ${CONFIG_PATH}

# 2. Generate the Nginx config from the template.
envsubst < /app/nginx.conf.template > /etc/nginx/conf.d/default.conf

# 3. Create the cron job file.
# We redirect all output to PID 1's stdout/stderr to make it visible with 'docker logs'.
echo "*/${UPDATE_INTERVAL_MINUTES} * * * * root /app/update_db.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/gamecache-cron

# 4. Give the cron job file the correct permissions.
chmod 0644 /etc/cron.d/gamecache-cron

# 5. Run the initial database update.
/app/update_db.sh

# --- Start Services ---
echo "Starting services..."
echo "- Nginx listening on port ${PORT}"
echo "- Database updates will run every ${UPDATE_INTERVAL_MINUTES} minutes."

# Start the cron daemon in the background.
cron -f &

# Start nginx in the foreground.
# This will keep the container running.
nginx -g 'daemon off;'
