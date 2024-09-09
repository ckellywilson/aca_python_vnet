#!/bin/bash

# Install OpenSSH server
sudo apt-get update
sudo apt-get install openssh-server -y

# Create a group for SFTP users
sudo groupadd sftp_users

# Create a user "ipod" and add it to the SFTP users group
sudo useradd -m -G sftp_users ipod

# Set a password for the "ipod" user
sudo passwd ipod

# Restart SSH service
sudo service ssh restart