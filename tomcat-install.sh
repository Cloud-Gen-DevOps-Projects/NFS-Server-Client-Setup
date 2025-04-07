#!/bin/bash

# Exit on any error
set -e

# Step 1: Set the hostname
echo "Setting hostname to 'tomcatwebserver'..."
hostnamectl set-hostname tomcatwebserver

# Verify the hostname
echo "Current hostname is:"
hostname

# Step 2: Install Java 17
echo "Installing Java 17..."
yum install fontconfig java-17-openjdk-devel -y

# Step 3: Set Java Home and Executable Path
echo "Setting JAVA_HOME and updating PATH..."
{
  printf "\n\n\n\n"  # Four blank lines
  echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk'
  echo 'export PATH=$JAVA_HOME/bin:$PATH'
} >> ~/.bashrc

# Step 4: Tomcat User Configuration
echo "Creating Tomcat user..."
useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat

# Step 5: Download and Install Tomcat
echo "Downloading Apache Tomcat..."
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.95/bin/apache-tomcat-9.0.95.tar.gz
tar -xvf apache-tomcat-9.0.95.tar.gz
mv apache-tomcat-9.0.95/* /opt/tomcat/
rmdir apache-tomcat-9.0.95  # Remove the empty directory
rm apache-tomcat-9.0.95.tar.gz  # Remove the tarball
chown -R tomcat: /opt/tomcat

# Step 6: Create Tomcat Startup Script
echo "Creating Tomcat startup script..."
bash -c 'cat << EOF > /opt/tomcat/tomcat-startup.sh
#!/bin/bash
export CATALINA_HOME=/opt/tomcat
export CATALINA_BASE=/opt/tomcat
\$CATALINA_HOME/bin/startup.sh
EOF'

# Make the startup script executable
chmod +x /opt/tomcat/tomcat-startup.sh

# Step 7: Create systemd service file for Tomcat
echo "Creating systemd service file..."
sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF'

# Step 8: Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Step 9: Enable and Start the Tomcat Service
echo "Enabling and starting Tomcat service..."
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Step 10: Check Tomcat Service Status
echo "Checking Tomcat service status..."
sudo systemctl status tomcat --no-pager  # Using --no-pager for immediate prompt


firewall-cmd --permanent --add-port=8080/tcp 
firewall-cmd --reload 

