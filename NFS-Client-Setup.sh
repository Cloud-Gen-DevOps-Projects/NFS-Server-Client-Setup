#!/bin/bash

# Find NFS Server IP by checking for shared file
NFS_SERVER_IP=$(curl -s http://$(ip route | awk '/default/ {print $3}')/server-ip.txt)

# If auto-detection fails, use an alternative method
if [ -z "$NFS_SERVER_IP" ]; then
    NFS_SERVER_IP=$(arp -a | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
fi

# If still not found, fallback to network scan (optional)
if [ -z "$NFS_SERVER_IP" ]; then
    echo "Could not auto-detect NFS Server IP. Please enter manually:"
    read -p "Enter NFS Server IP: " NFS_SERVER_IP
fi

echo "Detected NFS Server IP: $NFS_SERVER_IP"

NFS_DIR="/mnt/nfs-share"

echo "Installing NFS client..."
sudo dnf install -y nfs-utils

echo "Creating mount point..."
sudo mkdir -p $NFS_DIR

echo "Mounting NFS share..."
sudo mount -t nfs $NFS_SERVER_IP:/nfs-share $NFS_DIR

echo "Verifying the mount..."
df -h | grep nfs

echo "Making the mount persistent..."
echo "$NFS_SERVER_IP:/nfs-share  $NFS_DIR  nfs  defaults  0  0" | sudo tee -a /etc/fstab

echo "✅ NFS Client setup completed!"
