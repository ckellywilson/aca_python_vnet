#!/bin/bash

# Update and upgrade Ubuntu
sudo apt update
sudo apt upgrade -y

# Add password to $USER
echo "Adding password to $USER..."
sudo passwd $USER
echo "Password added to $USER."

# Add user "ipod"
echo "Adding user 'ipod'..."
sudo useradd ipod

# Add password to user "ipod"
echo "Adding password to user 'ipod'..."
sudo passwd ipod
echo "Password added to user 'ipod'."

# Call install_sftp.sh script
chmod +x install_sftp.sh
./install_sftp.sh

# Call install_cups.sh script
chmod +x install_cups.sh
./install_cups.sh