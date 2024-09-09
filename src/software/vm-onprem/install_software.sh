#!/bin/bash

# Update and upgrade Ubuntu
sudo apt update
sudo apt upgrade -y

# Call install_sftp.sh script
chmod +x install_sftp.sh
./install_sftp.sh

# Call install_cups.sh script
chmod +x install_cups.sh
./install_cups.sh