# Multi-stage build for Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the entire app
COPY . .

# Build the web app for production
RUN flutter build web --release --no-tree-shake-icons

# Production stage - simple file copy
FROM alpine:latest

# Create the target directory
RUN mkdir -p /var/www/html-podman/xdoc-web

# Copy the built web app to the target directory
COPY --from=build /app/build/web /var/www/html-podman/xdoc-web

# Set proper permissions
RUN chmod -R 755 /var/www/html-podman/xdoc-web

# Keep container running
CMD ["tail", "-f", "/dev/null"]
