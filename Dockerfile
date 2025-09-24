# Use Alpine Linux with OpenJDK 8
FROM openjdk:8-jdk-alpine

# Set environment variables
ENV MAVEN_HOME=/opt/maven
ENV PATH=$PATH:$MAVEN_HOME/bin

# Install required packages
RUN apk add --no-cache \
    wget \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz \
    && tar -xzf apache-maven-3.8.8-bin.tar.gz -C /opt \
    && mv /opt/apache-maven-3.8.8 /opt/maven \
    && rm apache-maven-3.8.8-bin.tar.gz

# Verify Java installation
RUN java -version && javac -version

# Create working directory
WORKDIR /app

# Copy the project files
COPY . .

# Build the project
RUN mvn clean compile assembly:single

# Create directories for migration data
RUN mkdir -p /data/dump /data/migration/thingsboard/ts_kv_cf /data/migration/thingsboard/ts_kv_latest_cf /data/migration/thingsboard/ts_kv_partitions_cf

# Set permissions
RUN chmod +x target/database-migrator-*.jar

# Default command - shows help/usage information
# Users can override this with docker run command
CMD ["java", "-jar", "./target/database-migrator-1.0-SNAPSHOT-jar-with-dependencies.jar"]