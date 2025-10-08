# Use a Python base image
FROM python:3.13-slim

# Install Nginx, gettext for envsubst, cron, and curl
RUN apt-get update && apt-get install -y nginx gettext cron curl && apt-get clean

WORKDIR /app

# Copy application code and scripts
# The .dockerignore file will exclude unnecessary files
COPY . .

# Change ownership of app files to the nginx user
RUN chown -R www-data:www-data /app

# Install Python dependencies
RUN pip install --no-cache-dir -r scripts/requirements.txt

# Make the scripts executable
# RUN chmod +x entrypoint.sh update_db.sh
RUN chmod +x update_db.sh

# Set default port
ENV PORT=8064

# Expose the port
EXPOSE $PORT

# Health check to ensure the server is responsive
HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl --fail http://localhost:${PORT}/ || exit 1

# Set the entrypoint
# The entrypoint script will handle config generation and starting nginx
# ENTRYPOINT ["/app/entrypoint.sh"]
ENTRYPOINT ["python", "/app/entrypoint.py"]