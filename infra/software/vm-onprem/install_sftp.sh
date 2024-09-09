#!/bin/bash

# Install OpenSSH server
sudo apt-get update
sudo apt-get install ssh -y

# Create a group for SFTP users
sudo groupadd sftpusers

# Create a user and add it to the SFTP users group
sudo useradd -m $USER -g sftpusers

# Set the user's password
sudo passwd $USER

# Set directory permissions
sudo chmod 700 /home/$USER/

# Modify OpenSSH server configuration to use internal-sftp
sudo sed -i 's/Subsystem sftp \/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/' /etc/ssh/sshd_config

# Add the following lines to the end of the file
sudo tee -a /etc/ssh/sshd_config <<EOF
Match Group sftpusers
    ChrootDirectory /home
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
EOF

# Restart SSH service
sudo systemctl restart sshd