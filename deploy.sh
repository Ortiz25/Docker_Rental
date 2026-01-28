#!/bin/bash
set -e

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found"
  exit 1
fi

echo "Building and starting services..."
docker-compose up -d --build

echo "Waiting for services to be ready..."
sleep 10

# Create required directories
mkdir -p certs certbot/www

# Check if certificates already exist
if [ ! -f "./certs/live/$SERVER_NAME/fullchain.pem" ] || [ ! -f "./certs/live/$SERVER_NAME/privkey.pem" ]; then
  echo "Setting up SSL certificates..."
  
  # Temporarily stop the proxy
  docker-compose stop proxy
  
  # Get certificates using standalone mode
  docker-compose run --rm --entrypoint "\
    certbot certonly --standalone \
      -d $SERVER_NAME \
      --email $DOMAIN_EMAIL \
      --agree-tos \
      --non-interactive \
      --force-renewal" certbot
  
  # Start the proxy
  docker-compose up -d proxy
  
  echo "SSL certificates have been set up successfully!"
else
  echo "SSL certificates already exist. Skipping certificate setup."
fi

echo "Deployment complete!"
echo "Frontend: https://$SERVER_NAME"
echo "PGAdmin: http://localhost:5050"
