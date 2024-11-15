# Use the official Python image from the Docker Hub
FROM ghcr.io/astral-sh/uv:python3.9-bookworm-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    # for mysql
    python3-dev default-libmysqlclient-dev pkg-config \
    # for cups
    cups \
    printer-driver-cups-pdf \
    libcups2-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure CUPS
# Copy the configure-cups script
COPY configure-cups.sh /usr/local/bin/configure-cups.sh
COPY cupsd.conf /tmp/cupsd.conf
RUN chmod +x /usr/local/bin/configure-cups.sh

# Create root directory for PDF files
RUN mkdir -p ~/root/PDF

# Set the working directory
WORKDIR /app

# # Copy the requirements file
# COPY requirements.txt /app/

# # Install Python dependencies
# RUN pip install --upgrade pip --no-cache-dir -r requirements.txt

# Copy the project files
COPY . /app/

RUN uv sync --frozen

# Expose the port that the app runs on
EXPOSE 8000

# Expose the CUPS web interface port
EXPOSE 631

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser

CMD ["sh", "-c", "configure-cups.sh && uv run -- flask run -p 8000 --host 0.0.0.0"]