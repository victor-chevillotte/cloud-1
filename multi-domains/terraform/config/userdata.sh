#!/usr/bin/env bash

sudo dnf update
sudo dnf install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
newgrp docker

# Mounting Efs 
sudo mkdir -p /home/ec2-user/data
# sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFS_DNS}:/  /home/ec2-user/data
# Making Mount Permanent
# echo ${EFS_DNS}:/ /home/ec2-user/data nfs4 defaults,_netdev 0 0  | sudo cat >> /etc/fstab
sudo chown -R 33 /home/ec2-user/data
sudo chmod -R 755 /home/ec2-user/data

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
mv /tmp/.env /home/ec2-user/.env
sudo chown ec2-user:ec2-user /home/ec2-user/.env
mv /tmp/docker-compose.yaml /home/ec2-user/docker-compose.yaml
sudo chown ec2-user:ec2-user /home/ec2-user/docker-compose.yaml
sudo systemctl start wordpress.service
sudo systemctl enable wordpress.service
