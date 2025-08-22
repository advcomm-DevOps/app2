#!/bin/sh
set -e

# Create the target directory if it doesn't exist
mkdir -p /var/www/html-podman/xdoc-web

# Copy files from build stage to mounted volume
echo "Copying Flutter web files to /var/www/html-podman/xdoc-web..."
cp -r /tmp/web-build/* /var/www/html-podman/xdoc-web/

# Set proper permissions
chmod -R 755 /var/www/html-podman/xdoc-web

echo "Files copied successfully!"
echo "Contents of /var/www/html-podman/xdoc-web:"
ls -la /var/www/html-podman/xdoc-web/

# Keep container running
tail -f /dev/null
