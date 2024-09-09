#!/bin/bash

# Install OpenSSH server
sudo apt-get update
sudo apt-get install openssh-server -y

# Create a group for SFTP users
sudo groupadd sftpusers

# Create a user "ipod" and add it to the SFTP users group
sudo useradd -m -G sftpusers $USER

# Set directory permissions
sudo mkdir -p /home/$USER/sftpfiles

# Restart SSH service
sudo service ssh restart