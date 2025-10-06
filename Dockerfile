# Dockerfile for Flutter Web Development
FROM cirrusci/flutter:stable

LABEL maintainer="Talkative Team <dev@talkative.com>"
LABEL description="Flutter development environment for Talkative Chat App"

# Set working directory
WORKDIR /app

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Enable web support
RUN flutter config --enable-web

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Expose port for web development
EXPOSE 3000

# Default command
CMD ["flutter", "run", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "3000"]