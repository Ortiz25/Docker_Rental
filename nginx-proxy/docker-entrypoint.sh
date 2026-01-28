#!/bin/sh
set -euo pipefail

# Set default values
export SERVER_NAME=${SERVER_NAME:-localhost}

echo "Starting Nginx configuration..."

# Function to validate configuration
validate_config() {
    echo "Validating Nginx configuration..."
    if ! nginx -t; then
        echo "Error: Invalid Nginx configuration"
        exit 1
    fi
    echo "Configuration validation successful"
}

# Function to perform environment substitution
setup_config() {
    echo "Setting up Nginx configuration for server: ${SERVER_NAME}"
    
    # Create necessary directories if they don't exist
    mkdir -p /var/run/nginx
    mkdir -p /var/cache/nginx/{client_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp}
    
    # Set proper permissions
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx
    chmod -R 755 /var/cache/nginx /var/run/nginx
    
    # Generate nginx config from template
    echo "Generating Nginx configuration..."
    envsubst '${SERVER_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf
    
    # Set permissions for nginx to read the config
    chmod 644 /etc/nginx/conf.d/default.conf
    chown nginx:nginx /etc/nginx/conf.d/default.conf
}

# Function to check if nginx is running
is_nginx_running() {
    pgrep nginx > /dev/null
}

# Main execution
main() {
    # Setup configuration
    setup_config
    
    # Validate configuration
    validate_config
    
    # Stop nginx if it's already running
    if is_nginx_running; then
        echo "Reloading Nginx configuration..."
        nginx -s reload
    else
        echo "Starting Nginx..."
        exec "$@"
    fi
}

# Execute main function
main "$@"

exit 0
