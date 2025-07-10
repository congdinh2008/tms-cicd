#!/bin/bash
# TMS Server Initialization Script
# This script sets up the TMS server environment and starts the application

set -e

# Logging configuration
LOG_FILE="/var/log/tms-server-init.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting TMS Server initialization..."

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
                        "file_path": "/var/log/tms-server-init.log",
                        "log_group_name": "/aws/ec2/tms-server",
                        "log_stream_name": "{instance_id}/init"
                    },
                    {
                        "file_path": "/var/log/docker.log",
                        "log_group_name": "/aws/ec2/tms-server",
                        "log_stream_name": "{instance_id}/docker"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "TMS/Server",
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
mkdir -p /opt/tms-server
cd /opt/tms-server

# Create systemd service for TMS server
log "Creating systemd service..."
cat > /etc/systemd/system/tms-server.service << 'EOF'
[Unit]
Description=TMS Server Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker run -d \
  --name tms-server \
  --restart unless-stopped \
  -p ${SERVER_PORT}:${SERVER_PORT} \
  -e SPRING_PROFILES_ACTIVE=${ENVIRONMENT} \
  -e SERVER_PORT=${SERVER_PORT} \
  ${DOCKERHUB_USERNAME}/tms-server:${SERVER_IMAGE_TAG}
ExecStop=/usr/bin/docker stop tms-server
ExecStopPost=/usr/bin/docker rm tms-server

[Install]
WantedBy=multi-user.target
EOF

# Create update script for deployments
log "Creating update script..."
cat > /opt/tms-server/update-server.sh << 'EOF'
#!/bin/bash
set -e

IMAGE_TAG=$${1:-latest}
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME}"
CONTAINER_NAME="tms-server"

echo "Updating TMS Server to tag: $IMAGE_TAG"

# Stop and remove existing container
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Pull new image
docker pull $DOCKERHUB_USERNAME/tms-server:$IMAGE_TAG

# Run new container
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p ${SERVER_PORT}:${SERVER_PORT} \
  -e SPRING_PROFILES_ACTIVE=${ENVIRONMENT} \
  -e SERVER_PORT=${SERVER_PORT} \
  $DOCKERHUB_USERNAME/tms-server:$IMAGE_TAG

# Health check
sleep 30
if curl -f http://localhost:${SERVER_PORT}/actuator/health; then
    echo "Server started successfully"
else
    echo "Server health check failed"
    exit 1
fi
EOF

chmod +x /opt/tms-server/update-server.sh

# Pull initial image and start service
log "Pulling initial Docker image..."
docker pull ${DOCKERHUB_USERNAME}/tms-server:${SERVER_IMAGE_TAG}

log "Starting TMS Server service..."
systemctl enable tms-server
systemctl start tms-server

# Wait for service to be ready
log "Waiting for server to be ready..."
sleep 30

# Health check
log "Performing health check..."
if curl -f http://localhost:${SERVER_PORT}/actuator/health; then
    log "TMS Server is running successfully"
else
    log "WARNING: TMS Server health check failed"
fi

# Install useful tools
log "Installing additional tools..."
yum install -y htop tree jq

# Configure log rotation
log "Configuring log rotation..."
cat > /etc/logrotate.d/tms-server << 'EOF'
/var/log/tms-server-init.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 644 root root
}
EOF

log "TMS Server initialization completed successfully"

# Create status file
echo "TMS Server initialized at $(date)" > /opt/tms-server/init-complete
