# Multi-stage build for Flutter web app (Monorepo)
FROM ubuntu:22.04 AS build

# Install dependencies including Dart
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Dart SDK
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg' \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" | tee /etc/apt/sources.list.d/dart_stable.list' \
    && apt-get update \
    && apt-get install -y dart \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/dart/bin:$PATH"

# Install Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$HOME/.pub-cache/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME \
    && flutter doctor -v \
    && flutter config --enable-web

# Install Melos globally
RUN dart pub global activate melos

# Set working directory to monorepo root
WORKDIR /workspace

# Copy the entire monorepo
COPY . .

# Run Melos bootstrap to setup workspace
RUN melos bootstrap

# Change to app directory and build
WORKDIR /workspace/apps/xdoc
RUN flutter build web --release --no-tree-shake-icons

# Production stage - simple file copy
FROM alpine:latest

# Create the target directory
RUN mkdir -p /var/www/html-podman/xdoc-web

# Copy the built web app to a temporary location
COPY --from=build /workspace/apps/xdoc/build/web /tmp/web-build

# Copy entrypoint script
COPY apps/xdoc/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
