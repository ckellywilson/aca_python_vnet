#!/bin/bash

# Backup the current sshd_config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Change the SFTP port to 4422
sudo sed -i 's/^#Port 22/Port 4422/' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo systemctl restart sshd

echo "SFTP port changed to 4422 and SSH service restarted."