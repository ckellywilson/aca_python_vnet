# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    # for mysql
    python3-dev default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --upgrade pip --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY app.py app.py
COPY DigiCertGlobalRootCA.crt.pem DigiCertGlobalRootCA.crt.pem

# create user vscode and grant them admin rights in the container
RUN useradd -ms /bin/bash -G sudo vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R vscode:vscode /app

# create upload directory and grant vscode user access
RUN mkdir -p /home/vscode/upload && chown -R vscode:vscode /home/vscode/upload

# switch to vscode user
USER vscode

# Set the entry point for the container
CMD ["python", "app.py"]