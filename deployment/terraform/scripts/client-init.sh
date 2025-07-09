#!/bin/bash
# User data script for TMS Client EC2 instance

set -e

# Log all output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting TMS Client initialization..."

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
    wget \
    nginx

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
mkdir -p /opt/tms-client
chown ec2-user:ec2-user /opt/tms-client

# Create environment file
cat > /opt/tms-client/.env << EOF
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
CLIENT_IMAGE_TAG=${CLIENT_IMAGE_TAG}
CLIENT_PORT=${CLIENT_PORT}
ENVIRONMENT=${ENVIRONMENT}
EOF

# Create docker-compose file for client
cat > /opt/tms-client/docker-compose.yml << EOF
version: '3.8'

services:
  tms-client:
    image: \${DOCKERHUB_USERNAME}/tms-client:\${CLIENT_IMAGE_TAG}
    container_name: tms-client
    restart: unless-stopped
    ports:
      - "\${CLIENT_PORT}:80"
      - "443:443"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    logging:
      driver: "awslogs"
      options:
        awslogs-group: "/aws/ec2/tms-client-\${ENVIRONMENT}"
        awslogs-region: "ap-southeast-1"
        awslogs-create-group: "true"
EOF

# Configure Nginx as reverse proxy (if needed)
cat > /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    # Upstream for the Docker container
    upstream tms_client {
        server 127.0.0.1:${CLIENT_PORT};
    }

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Proxy to Docker container
        location / {
            proxy_pass http://tms_client;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
            
            # Rate limiting
            limit_req zone=api burst=20 nodelay;
        }

        error_page   404              /404.html;
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Create systemd service for the application
cat > /etc/systemd/system/tms-client.service << EOF
[Unit]
Description=TMS Client Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/tms-client
ExecStart=/usr/local/bin/docker-compose --env-file .env up -d
ExecStop=/usr/local/bin/docker-compose --env-file .env down
TimeoutStartSec=0
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOF

# Create startup script
cat > /opt/tms-client/start.sh << 'EOF'
#!/bin/bash
cd /opt/tms-client

# Pull latest image
docker-compose --env-file .env pull

# Start services
docker-compose --env-file .env up -d

# Wait for health check
echo "Waiting for application to be healthy..."
for i in {1..30}; do
    if curl -f http://localhost:${CLIENT_PORT}/ 2>/dev/null; then
        echo "Application is healthy!"
        break
    fi
    echo "Attempt $i/30: Application not ready yet..."
    sleep 10
done
EOF

chmod +x /opt/tms-client/start.sh
chown ec2-user:ec2-user /opt/tms-client/start.sh

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
                        "log_group_name": "/aws/ec2/tms-client-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/user-data.log"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/tms-client-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/nginx-access.log"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/tms-client-${ENVIRONMENT}",
                        "log_stream_name": "{instance_id}/nginx-error.log"
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

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable and start services
systemctl daemon-reload
systemctl enable tms-client.service
systemctl enable nginx
systemctl start nginx

# Wait for Docker to be ready
sleep 30

# Pull the initial image
cd /opt/tms-client
sudo -u ec2-user docker-compose --env-file .env pull || echo "Failed to pull image, will retry on first deployment"

echo "TMS Client initialization completed!"

# Create a status file
echo "$(date): TMS Client initialization completed" > /var/log/tms-client-init-status
