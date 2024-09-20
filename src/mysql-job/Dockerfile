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

# Set the entry point for the container
CMD ["python", "app.py"]