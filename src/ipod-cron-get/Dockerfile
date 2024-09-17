# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.12.6-slim-bookworm

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

# Set the working directory in the container
WORKDIR /app
COPY . /app

# create user vscode and grant them admin rights in the container
RUN useradd -ms /bin/bash -G sudo vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R vscode:vscode /app

# switch to vscode user
USER vscode

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "app.py"]
