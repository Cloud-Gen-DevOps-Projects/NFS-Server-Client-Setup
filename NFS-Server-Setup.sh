#!/bin/bash

# Automatically detect the NFS Server's primary IP
SERVER_IP=$(hostname -I | awk '{print $1}')
NFS_DIR="/nfs-share"

echo "Detected NFS Server IP: $SERVER_IP"

echo "Installing NFS server..."
sudo dnf install -y nfs-utils

echo "Starting and enabling NFS service..."
sudo systemctl enable --now nfs-server

echo "Creating shared directory..."
sudo mkdir -p $NFS_DIR
sudo chmod 777 $NFS_DIR

echo "Configuring NFS exports..."
echo "$NFS_DIR *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee /etc/exports

echo "Exporting the shared directory..."
sudo exportfs -rav

echo "Restarting NFS service..."
sudo systemctl restart nfs-server

echo "Allowing NFS traffic in firewall..."
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --reload

echo "✅ NFS Server setup completed!"
echo "Server IP: $SERVER_IP"

# Save the server IP for clients to retrieve
echo "$SERVER_IP" | sudo tee /nfs-share/server-ip.txt
