#!/bin/bash
# EC2 Setup Script - Run this on your EC2 instance to install Docker

echo "===== EC2 Setup Script for FastAPI CI/CD ====="

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
echo "Adding user to docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose (optional)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
echo ""
echo "===== Installation Complete ====="
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker-compose --version

echo ""
echo "IMPORTANT: Please log out and log back in for group changes to take effect!"
echo "After that, test Docker with: docker run hello-world"
