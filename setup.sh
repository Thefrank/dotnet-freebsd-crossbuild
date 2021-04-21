#! /bin/bash

# docker installation
curl -fsSL https://get.docker.com | sh

# dotnet installation
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y apt-transport-https
apt-get update
apt-get install -y dotnet-sdk-5.0

# everything else needed for build script
apt-get install -y --no-install-recommends emacs-nox git nodejs npm jq
