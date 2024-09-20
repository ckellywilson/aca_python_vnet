# Use the official Nginx image from the Docker Hub
FROM nginx:alpine

# Copy the custom Nginx configuration file to the container
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh

# Expose port 631
EXPOSE 631

# Start Nginx when the container launches
CMD ["/entrypoint.sh"]