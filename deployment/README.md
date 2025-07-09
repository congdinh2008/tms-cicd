# TMS CI/CD Infrastructure Documentation

## Tổng quan

Hệ thống CI/CD này được thiết kế để triển khai ứng dụng TMS (Task Management System) bao gồm:
- **tms-server**: Spring Boot backend application
- **tms-client**: React frontend application

## Kiến trúc

### CI/CD Pipeline
1. **Continuous Integration (CI)**:
   - Build và test code
   - Build Docker images
   - Push images lên Docker Hub
   - Security scanning với Trivy

2. **Continuous Deployment (CD)**:
   - Deploy lên AWS EC2 instances
   - Health checks
   - Rollback tự động nếu deployment fail
   - Performance testing

### Infrastructure
- **AWS VPC** với public/private subnets
- **EC2 instances** (t3.micro - free tier)
- **Security Groups** với các rules phù hợp
- **Elastic IPs** cho stable public IPs
- **CloudWatch** cho monitoring và logging
- **SSM** cho remote management

## Cài đặt

### 1. Chuẩn bị môi trường

#### a. GitHub Secrets
Thêm các secrets sau vào GitHub repository:

```bash
# Docker Hub
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-token

# AWS
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key

# Deployment
EC2_INSTANCE_ID=i-xxxxxxxxx (sẽ có sau khi chạy Terraform)

# Optional: Slack notifications
SLACK_WEBHOOK=your-slack-webhook-url
```

#### b. SSH Key Pair
Tạo SSH key pair cho EC2 instances:
```bash
# Tạo SSH key với passphrase (recommended for security)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/tms-key

# Hoặc không dùng passphrase (cho automation)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/tms-key -N ""
```

**Lưu ý về SSH passphrase:**
- ✅ **Có passphrase**: Bảo mật cao hơn, nhưng cần nhập passphrase khi SSH manually
- ✅ **Không passphrase**: Dễ dàng cho automation và scripts
- 🔒 CI/CD pipeline sử dụng **AWS SSM** (không cần SSH), nên passphrase không ảnh hưởng deployment

### 2. Triển khai Infrastructure với Terraform

```bash
cd deployment/terraform

# Copy và cấu hình variables
cp terraform.tfvars.example terraform.tfvars
# Chỉnh sửa terraform.tfvars với thông tin của bạn

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### 3. Cấu hình GitHub Actions

Sau khi Terraform deployment hoàn thành:
1. Lấy instance IDs từ Terraform outputs
2. Cập nhật GitHub secrets với instance IDs
3. Push code để trigger CI/CD pipeline

## Cấu trúc Files

```
deployment/
├── cicd/
│   ├── tms-server-ci.yml    # CI pipeline cho server
│   ├── tms-server-cd.yml    # CD pipeline cho server
│   ├── tms-client-ci.yml    # CI pipeline cho client
│   └── tms-client-cd.yml    # CD pipeline cho client
├── terraform/
│   ├── main.tf              # Main infrastructure
│   ├── variables.tf         # Terraform variables
│   ├── outputs.tf           # Terraform outputs
│   ├── ec2.tf              # EC2 instances configuration
│   ├── terraform.tfvars.example
│   └── scripts/
│       ├── server-init.sh   # Server initialization script
│       └── client-init.sh   # Client initialization script
├── deploy.sh               # Automated deployment script
├── connect.sh              # SSH/SSM connection helper script
└── README.md               # Deployment guide
```

## CI/CD Pipeline Details

### Server CI Pipeline (tms-server-ci.yml)
1. **Test**: Chạy Maven tests
2. **Build**: Build JAR file và Docker image
3. **Security Scan**: Trivy vulnerability scanning
4. **Push**: Push image lên Docker Hub

### Server CD Pipeline (tms-server-cd.yml)
1. **Deploy**: Deploy Docker container lên EC2
2. **Health Check**: Kiểm tra /actuator/health endpoint
3. **Rollback**: Tự động rollback nếu deployment fail

### Client CI Pipeline (tms-client-ci.yml)
1. **Test**: ESLint, TypeScript checking
2. **Build**: Build React app và Docker image
3. **Security Scan**: Trivy vulnerability scanning
4. **Push**: Push image lên Docker Hub

### Client CD Pipeline (tms-client-cd.yml)
1. **Deploy**: Deploy Docker container lên EC2
2. **Health Check**: Kiểm tra HTTP response
3. **Performance Test**: Chạy k6 performance tests
4. **Rollback**: Tự động rollback nếu deployment fail

## Monitoring và Logging

### CloudWatch
- **Metrics**: CPU, Memory, Disk utilization
- **Logs**: Application logs, Nginx logs, System logs
- **Alarms**: CPU usage > 80%

### Health Checks
- **Server**: `http://server-ip:8080/actuator/health`
- **Client**: `http://client-ip/`

## Bảo mật

### Network Security
- Security Groups restrict access to necessary ports only
- SSH access có thể restrict theo IP
- HTTPS support (có thể enable với SSL certificate)

### Container Security
- Trivy scanning cho vulnerabilities
- Regular base image updates
- Non-root user trong containers

### Access Control
- IAM roles với least privilege
- SSM Session Manager cho secure access
- CloudWatch logs encryption

## Troubleshooting

### Kiểm tra deployment status

#### Option 1: Sử dụng Connect Helper Script (Recommended)
```bash
# Interactive connection menu
cd deployment
./connect.sh

# Direct connection commands
./connect.sh server          # SSH to server (will prompt for passphrase if needed)
./connect.sh --ssm server    # SSM to server (no SSH key needed)
./connect.sh client          # SSH to client
./connect.sh --ssm client    # SSM to client

# Setup ssh-agent to cache passphrase
./connect.sh --setup-agent
```

#### Option 2: Manual SSH connection
```bash
# Nếu SSH key có passphrase, sử dụng ssh-agent để cache passphrase
ssh-add ~/.ssh/tms-key
ssh ec2-user@<instance-ip>

# Hoặc nhập passphrase mỗi lần connect
ssh -i ~/.ssh/tms-key ec2-user@<instance-ip>
```

#### Option 3: AWS SSM Session Manager (No SSH key needed)
```bash
# Không cần SSH key, chỉ cần AWS credentials
aws ssm start-session --target <instance-id>
```

**Sau khi connect (bằng bất kỳ method nào):**
```bash
# Kiểm tra container status
docker ps
docker logs tms-server
docker logs tms-client

# Kiểm tra service logs
sudo journalctl -u tms-server
sudo journalctl -u tms-client

# Kiểm tra user-data execution
cat /var/log/user-data.log
```

### SSH Connection với Passphrase
```bash
# Nếu SSH key có passphrase, bạn có thể:
# 1. Sử dụng ssh-agent để cache passphrase
ssh-add ~/.ssh/tms-key
ssh ec2-user@<instance-ip>

# 2. Hoặc nhập passphrase mỗi lần connect
ssh -i ~/.ssh/tms-key ec2-user@<instance-ip>

# 3. Sử dụng AWS SSM thay vì SSH (recommended)
aws ssm start-session --target <instance-id>
```

### Common Issues
1. **Docker image pull fails**: Kiểm tra Docker Hub credentials
2. **Health check fails**: Kiểm tra application logs và network connectivity
3. **Deployment timeout**: Tăng timeout values trong GitHub Actions

## Cost Optimization

### AWS Free Tier Usage
- t3.micro instances (eligible for free tier)
- 750 hours/month free EC2 usage
- CloudWatch logs free tier: 5GB/month

### Resource Management
- Auto-stop instances ngoài business hours (có thể implement)
- Use spot instances cho non-production environments
- Regular cleanup của old Docker images

## Scaling và High Availability

### Tương lai có thể mở rộng
- Application Load Balancer
- Auto Scaling Groups
- RDS database với Multi-AZ
- CloudFront CDN
- ECS/EKS cho container orchestration

## Backup và Disaster Recovery

### Current Setup
- EBS snapshots (có thể implement)
- Code backup trên GitHub
- Infrastructure as Code với Terraform

### Recommended Additions
- Automated EBS snapshots
- Cross-region backups
- Database backups (khi có RDS)

## Support và Maintenance

### Regular Tasks
- Update base AMIs
- Update Docker base images
- Review và update security groups
- Monitor costs và usage

### Monitoring Checklist
- [ ] CI/CD pipeline success rates
- [ ] Application performance metrics
- [ ] Security vulnerability scans
- [ ] AWS cost monitoring
- [ ] Backup verification
