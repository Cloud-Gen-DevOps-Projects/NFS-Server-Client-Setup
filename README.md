# NFS-Server-Client-Setup

🚀 Steps to Execute
On the NFS Server

chmod +x setup-nfs-server.sh
sudo ./setup-nfs-server.sh

===================================


On Each NFS Client

chmod +x setup-nfs-client.sh
sudo ./setup-nfs-client.sh


===================================

✅ Final Verification

🔹 Check NFS Server IP (Run on Server):

hostname -I

exportfs -v

===================================================

🔹 Check NFS Mount on Client (Run on Client):

df -h | grep nfs

ls -l /mnt/nfs-share/

===================================================

🔹 Test File Creation on NFS Share (Run on Client):


touch /mnt/nfs-share/test-file.txt

ls -l /mnt/nfs-share/
