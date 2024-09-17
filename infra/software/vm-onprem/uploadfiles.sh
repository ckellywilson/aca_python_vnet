#!/bin/bash

# Create folder for user uploads
mkdir -p /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads

# Create and populate CSV files
for i in {1..3}; do
    # Create CSV file
    touch /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads/file$i.csv

    # Add header to CSV file
    echo "product_id,product_description,date_shipped" > /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads/file$i.csv

    # Add rows to CSV file
    echo "1,Product 1,2022-01-01" >> /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads/file$i.csv
    echo "2,Product 2,2022-01-02" >> /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads/file$i.csv
    echo "3,Product 3,2022-01-03" >> /workspaces/aca_python_vnet/infra/software/vm-onprem/uploads/file$i.csv
done