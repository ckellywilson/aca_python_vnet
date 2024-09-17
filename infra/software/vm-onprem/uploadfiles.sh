#!/bin/bash

# Create folder for user upload
mkdir -p /home/vscode/upload

# Create and populate CSV files
for i in {1..3}; do

    # Delete file if it exists
    if [ -f /home/vscode/upload/file$i.csv ]; then
        rm /home/vscode/upload/file$i.csv
    fi
    
    # Create CSV file
    touch /home/vscode/upload/file$i.csv

    # Add header to CSV file
    echo "product_id,product_description,date_shipped" > /home/vscode/upload/file$i.csv

    # Add rows to CSV file
    echo "1,Product 1,2022-01-01" >> /home/vscode/upload/file$i.csv
    echo "2,Product 2,2022-01-02" >> home/vscode/upload/file$i.csv
    echo "3,Product 3,2022-01-03" >> home/vscode/upload/file$i.csv
done