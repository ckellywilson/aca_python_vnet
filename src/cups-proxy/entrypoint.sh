#!/bin/sh

# Substitute environment variables in the Nginx configuration template
envsubst '$BACKEND_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx
nginx -g 'daemon off;'