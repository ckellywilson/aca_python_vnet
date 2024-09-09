#!/bin/bash

# Install CUPS
echo "Installing CUPS..."
sudo apt-get update
sudo apt-get install cups -y
echo "CUPS installed."

# Configure CUPS
echo "Configuring CUPS..."
sudo cupsctl --remote-admin --remote-any --share-printers
echo "CUPS configured."

# Add user to lpadmin group
echo "Adding user to lpadmin group..."
sudo usermod -aG lpadmin $USER
echo "User added to lpadmin group."

# Install CUPS PDF
echo "Installing CUPS PDF..."
sudo apt-get install printer-driver-cups-pdf -y
echo "CUPS PDF installed."

# Restart CUPS service
echo "Restarting CUPS service..."
sudo systemctl restart cups.service
echo "CUPS service restarted."

# Enable CUPS on system startup
echo "Enabling CUPS on system startup..."
sudo systemctl enable cups.service
echo "CUPS enabled on system startup."

echo "CUPS installation and configuration completed."