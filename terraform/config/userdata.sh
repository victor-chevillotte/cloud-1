#!/usr/bin/env bash

sudo dnf update
sudo dnf install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
newgrp docker
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl start wordpress-app.service
sudo systemctl enable wordpress-app.service
mkdir -p /app
