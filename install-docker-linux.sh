#!/bin/bash

set -euo pipefail

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-apt-repository

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo rm -f /etc/apt/sources.list.d/docker.list

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update

sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo groupadd -f docker
sudo usermod -aG docker "$USER"

echo "Docker installed successfully."
echo "To use docker without sudo, log out and log back in, or run:"
echo "  newgrp docker"
echo
echo "Verify with:"
echo "  docker run hello-world"
