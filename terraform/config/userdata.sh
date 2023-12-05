#!/usr/bin/env bash

sudo dnf update
sudo dnf install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
newgrp docker
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
mv /tmp/.env /home/ec2-user/.env
echo "EC2_HOSTNAME=$HOSTNAME" >> /home/ec2-user/.env
sudo chown ec2-user:ec2-user /home/ec2-user/.env
mv /tmp/docker-compose.yaml /home/ec2-user/docker-compose.yaml
sudo chown ec2-user:ec2-user /home/ec2-user/docker-compose.yaml
sudo systemctl start wordpress.service
sudo systemctl enable wordpress.service
