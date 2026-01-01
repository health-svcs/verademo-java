# For Security Labs we need both the application and DB running within the same container.
# It's far easier to use the MariaDB base image and install Maven and Java on top than
# the other way around. We are using Maven to enable re-compilation within the lab.
#
# https://hub.docker.com/_/mariadb/
# MariaDB 10.6.2 image is based on Ubuntu 20.04 LTS
FROM mariadb:10.6.2

# Configure MariaDB
ENV MYSQL_RANDOM_ROOT_PASSWORD=true
ENV MYSQL_DATABASE=blab

# Optional: make the app port explicit for the LiveDemo pipeline (NGINX proxies to this)
ENV APP_PORT=8080

# Copy DB schema for DB initialization
COPY db /docker-entrypoint-initdb.d

# Install OpenJDK 8 and Maven (plus a few lab utilities)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openjdk-8-jdk-headless \
      openjdk-8-jre-headless \
      maven \
      fortune-mod \
      iputils-ping \
      ca-certificates \
    && ln -s /usr/games/fortune /bin/fortune \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app
COPY app /app
COPY maven-settings.xml /usr/share/maven/conf/settings.xml

# Compile once at build-time (keep /app/target so entrypoint can run the artifact if it expects it)
RUN mvn -DskipTests clean package

# Document ports:
# - 3306: MariaDB (usually not published externally in your LiveDemo)
# - 8080: App HTTP port (NGINX on the EC2 host terminates TLS on 443 and proxies to this)
EXPOSE 3306 8080

ENTRYPOINT ["/entrypoint.sh"]
