#!/bin/bash

# Install OpenSSH server
sudo apt-get update
sudo apt-get install ssh -y

# Create a group for SFTP users
sudo groupadd sftp

# Create a user and add it to the SFTP users group
sudo useradd -m $USER -g sftp

# Set directory permissions
sudo chmod 700 /home/$USER/

# Open the SSH config file
sudo vi /etc/ssh/sshd_config

# NOTE: Find the Subsystem sftp line and replace it with the following line 'Subsystem sftp  internal-sftp'
# close the file by pressing 'Esc' and typing ':wq' and pressing 'Enter'

# Add the following lines to the end of the file
sudo tee -a /etc/ssh/sshd_config <<EOF
Match Group sftp
    ChrootDirectory /home
    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
EOF

# Restart SSH service
sudo systemctl restart sshd