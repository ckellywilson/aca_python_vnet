#!/bin/bash

# Stop any service that auto-started
service cups stop

# Modify cupsd.conf to allow remote access and disable IPv6 binding
CUPSD_CONF="/etc/cups/cupsd.conf"

# Backup the original cupsd.conf
cp $CUPSD_CONF ${CUPSD_CONF}.bak

# Update cupsd.conf
cp -f /tmp/cupsd.conf $CUPSD_CONF

# Start the CUPS daemon in the background
/usr/sbin/cupsd

# Wait for CUPS to start
until lpstat -H; do
  echo "Waiting for CUPS to start..."
  sleep 1
done
echo "CUPS started"

# Share everything
cupsctl --share-printers --remote-any --remote-admin --user-cancel-any "WebInterface=Yes"

# Configure CUPS-PDF
mkdir -p /var/spool/cups-pdf/CUPS-PDF
chmod 1777 /var/spool/cups-pdf/CUPS-PDF
lpadmin -p CUPS-PDF -E -v cups-pdf:/ -D "CUPS-PDF Printer" -L "PDF Printer" -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd
cupsenable CUPS-PDF
cupsaccept CUPS-PDF

echo "Printer configured."

service cups start