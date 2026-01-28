# Use specific version for production
FROM nginx:1.25-alpine

# Install system dependencies
RUN apk add --no-cache --update \
    gettext \
    tzdata \
    curl \
    && rm -rf /var/cache/apk/*

# Remove default config and logs
RUN rm -f /etc/nginx/conf.d/default.conf \
    && rm -f /var/log/nginx/access.log \
    && rm -f /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Create necessary directories
RUN mkdir -p /var/run/nginx \
    && mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/fastcgi_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/www/html \
    && mkdir -p /etc/nginx/templates \
    && chown -R nginx:nginx /var/cache/nginx \
    && chmod -R 755 /var/cache/nginx

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/default.conf /etc/nginx/templates/default.conf.template

# Create a simple error page
RUN echo '<!DOCTYPE html><html><head><title>Error</title><style>body{font-family:Arial,sans-serif;text-align:center;padding:50px;}</style></head><body><h1>Error</h1><p>An error occurred while processing your request.</p></body></html>' > /usr/share/nginx/html/error.html

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && chmod -R 755 /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /etc/nginx/conf.d \
    && chmod -R 755 /etc/nginx

# Copy and set up entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost/health || exit 1

# Switch to non-root user
USER nginx

# Expose ports
EXPOSE 80

# Set entrypoint and default command
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
