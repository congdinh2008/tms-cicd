#!/bin/bash
# TMS Client Initialization Script
# This script sets up the TMS client environment and starts the application

set -e

# Logging configuration
LOG_FILE="/var/log/tms-client-init.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting TMS Client initialization..."

# Update system
log "Updating system packages..."
yum update -y

# Install Docker
log "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
log "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install Nginx (for reverse proxy if needed)
log "Installing Nginx..."
amazon-linux-extras install -y nginx1
systemctl enable nginx

# Install CloudWatch Agent if enabled
%{ if ENABLE_CLOUDWATCH_LOGS }
log "Installing CloudWatch Agent..."
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/tms-client-init.log",
                        "log_group_name": "/aws/ec2/tms-client",
                        "log_stream_name": "{instance_id}/init"
                    },
                    {
                        "file_path": "/var/log/docker.log",
                        "log_group_name": "/aws/ec2/tms-client",
                        "log_stream_name": "{instance_id}/docker"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/tms-client",
                        "log_stream_name": "{instance_id}/nginx-access"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/tms-client",
                        "log_stream_name": "{instance_id}/nginx-error"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "TMS/Client",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
%{ endif }

# Create application directory
log "Creating application directory..."
mkdir -p /opt/tms-client
cd /opt/tms-client

# Create Nginx configuration for reverse proxy
log "Configuring Nginx..."
cat > /etc/nginx/conf.d/tms-client.conf << 'EOF'
server {
    listen 80;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        proxy_pass http://localhost:${CLIENT_PORT};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Create systemd service for TMS client
log "Creating systemd service..."
cat > /etc/systemd/system/tms-client.service << 'EOF'
[Unit]
Description=TMS Client Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker run -d \
  --name tms-client \
  --restart unless-stopped \
  -p ${CLIENT_PORT}:80 \
  -e ENVIRONMENT=${ENVIRONMENT} \
  ${DOCKERHUB_USERNAME}/tms-client:${CLIENT_IMAGE_TAG}
ExecStop=/usr/bin/docker stop tms-client
ExecStopPost=/usr/bin/docker rm tms-client

[Install]
WantedBy=multi-user.target
EOF

# Create update script for deployments
log "Creating update script..."
cat > /opt/tms-client/update-client.sh << 'EOF'
#!/bin/bash
set -e

IMAGE_TAG=$${1:-latest}
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME}"
CONTAINER_NAME="tms-client"

echo "Updating TMS Client to tag: $IMAGE_TAG"

# Stop and remove existing container
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Pull new image
docker pull $DOCKERHUB_USERNAME/tms-client:$IMAGE_TAG

# Run new container
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p ${CLIENT_PORT}:80 \
  -e ENVIRONMENT=${ENVIRONMENT} \
  $DOCKERHUB_USERNAME/tms-client:$IMAGE_TAG

# Health check
sleep 10
if curl -f http://localhost:${CLIENT_PORT}/; then
    echo "Client started successfully"
else
    echo "Client health check failed"
    exit 1
fi
EOF

chmod +x /opt/tms-client/update-client.sh

# Pull initial image and start service
log "Pulling initial Docker image..."
docker pull ${DOCKERHUB_USERNAME}/tms-client:${CLIENT_IMAGE_TAG}

log "Starting TMS Client service..."
systemctl enable tms-client
systemctl start tms-client

# Wait for service to be ready
log "Waiting for client to be ready..."
sleep 15

# Start Nginx
log "Starting Nginx..."
systemctl start nginx

# Health check
log "Performing health check..."
if curl -f http://localhost/health; then
    log "TMS Client is running successfully"
else
    log "WARNING: TMS Client health check failed"
fi

# Install useful tools
log "Installing additional tools..."
yum install -y htop tree jq

# Configure log rotation
log "Configuring log rotation..."
cat > /etc/logrotate.d/tms-client << 'EOF'
/var/log/tms-client-init.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 644 root root
}
EOF

log "TMS Client initialization completed successfully"

# Create status file
echo "TMS Client initialized at $(date)" > /opt/tms-client/init-complete
