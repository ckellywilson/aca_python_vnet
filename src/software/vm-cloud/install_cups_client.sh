#!/bin/bash

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install the CUPS client
sudo apt install cups-client -y