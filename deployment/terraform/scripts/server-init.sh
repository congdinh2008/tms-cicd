#!/bin/bash
# User data script for TMS Server EC2 instance

set -e

# Log all output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting TMS Server initialization..."

# Update system
yum update -y

# Install required packages
yum install -y \
    docker \
    awscli \
    amazon-ssm-agent \
    cloudwatch-agent \
    htop \
    git \
    curl \
    wget

# Start and enable services
systemctl start docker
systemctl enable docker
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create application directory
mkdir -p /opt/tms-server
chown ec2-user:ec2-user /opt/tms-server

# Create environment file
cat > /opt/tms-server/.env << EOF
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
SERVER_IMAGE_TAG=${SERVER_IMAGE_TAG}
SERVER_PORT=${SERVER_PORT}
ENVIRONMENT=${ENVIRONMENT}
SPRING_PROFILES_ACTIVE=${ENVIRONMENT}
EOF

# Create docker-compose file for server
cat > /opt/tms-server/docker-compose.yml << EOF
version: '3.8'

services:
  tms-server:
    image: \${DOCKERHUB_USERNAME}/tms-server:\${SERVER_IMAGE_TAG}
    container_name: tms-server
    restart: unless-stopped
    ports:
      - "\${SERVER_PORT}:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=\${ENVIRONMENT}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    logging:
      driver: "awslogs"
      options:
        awslogs-group: "/aws/ec2/tms-server-\${ENVIRONMENT}"
        awslogs-region: "ap-southeast-1"
        awslogs-create-group: "true"
EOF

# Create systemd service for the application
cat > /etc/systemd/system/tms-server.service << EOF
[Unit]
Description=TMS Server Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/tms-server
ExecStart=/usr/local/bin/docker-compose --env-file .env up -d
ExecStop=/usr/local/bin/docker-compose --env-file .env down
TimeoutStartSec=0
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOF

# Create startup script
cat > /opt/tms-server/start.sh << 'EOF'
#!/bin/bash
cd /opt/tms-server

# Pull latest image
docker-compose --env-file .env pull

# Start services
docker-compose --env-file .env up -d

# Wait for health check
echo "Waiting for application to be healthy..."
for i in {1..30}; do
    if curl -f http://localhost:${SERVER_PORT}/actuator/health 2>/dev/null; then
        echo "Application is healthy!"
        break
    fi
    echo "Attempt $i/30: Application not ready yet..."
    sleep 10
done
EOF

chmod +x /opt/tms-server/start.sh
chown ec2-user:ec2-user /opt/tms-server/start.sh

# Create CloudWatch agent config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/tms-server-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/user-data.log"
                    },
                    {
                        "file_path": "/var/log/docker",
                        "log_group_name": "/aws/ec2/tms-server-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/docker.log"
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

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable and start the TMS server service
systemctl daemon-reload
systemctl enable tms-server.service

# Wait for Docker to be ready
sleep 30

# Pull the initial image
cd /opt/tms-server
sudo -u ec2-user docker-compose --env-file .env pull || echo "Failed to pull image, will retry on first deployment"

echo "TMS Server initialization completed!"

# Create a status file
echo "$(date): TMS Server initialization completed" > /var/log/tms-server-init-status
