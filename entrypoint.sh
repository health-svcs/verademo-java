#!/usr/bin/env bash
set -e

# Start MariaDB in the background (provided by base image)
/usr/local/bin/docker-entrypoint.sh mysqld > /dev/null 2>&1 & disown

# Default app port (can be overridden by APP_PORT env var)
APP_PORT="${APP_PORT:-8080}"

echo "Starting Spring Boot app on port ${APP_PORT}, binding to 0.0.0.0"

# Run Spring Boot, explicitly binding to all interfaces
mvn spring-boot:run \
  -Dspring-boot.run.arguments="--server.port=${APP_PORT} --server.address=0.0.0.0"
