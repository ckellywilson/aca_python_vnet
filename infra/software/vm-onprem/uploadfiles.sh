#!/bin/bash

# Define the directory and file path
DIR="/home/vscode/upload"
FILE="$DIR/data.csv"

# Check if the directory exists, if not, create it
if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi

# Create the CSV file with the specified content
cat <<EOL > $FILE
name,description,created_at
John Doe,Sample description 1,$(date +%Y-%m-%d)
Jane Smith,Sample description 2,$(date +%Y-%m-%d)
Alice Johnson,Sample description 3,$(date +%Y-%m-%d)
EOL

echo "CSV file created at $FILE"