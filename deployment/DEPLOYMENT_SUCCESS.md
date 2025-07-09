# TMS Infrastructure Deployment - SUCCESS! 🚀

## Deployment Summary
✅ **Infrastructure successfully deployed to AWS!**

### Deployed Resources:
- **VPC**: `vpc-0f30c249da1a7a1c1` (10.0.0.0/16)
- **Security Group**: `sg-081fe55c3272fe464`
- **Key Pair**: `tms-key-dev`

### Server Instance:
- **Instance ID**: `i-0bb3e22a6fa57f9d6`
- **Public IP**: `3.0.34.33`
- **Private IP**: `10.0.1.38`
- **URL**: http://3.0.34.33:8080
- **Health Check**: http://3.0.34.33:8080/actuator/health
- **SSH Command**: `ssh -i ~/.ssh/tms-key-dev.pem ec2-user@3.0.34.33`

### Client Instance:
- **Instance ID**: `i-059a54610d4a7e397`
- **Public IP**: `52.77.106.169`
- **Private IP**: `10.0.2.202`
- **URL**: http://52.77.106.169
- **SSH Command**: `ssh -i ~/.ssh/tms-key-dev.pem ec2-user@52.77.106.169`

## GitHub Secrets Configuration
Configure these secrets in your GitHub repository for CI/CD:

```
AWS_REGION=ap-southeast-1
SERVER_PUBLIC_IP=3.0.34.33
CLIENT_PUBLIC_IP=52.77.106.169
EC2_SERVER_INSTANCE_ID=i-0bb3e22a6fa57f9d6
EC2_CLIENT_INSTANCE_ID=i-059a54610d4a7e397
```

## Next Steps

### 1. Connect to Instances ✅
Use the connect helper script (now working correctly):
```bash
cd deployment
./connect.sh
```

### 2. Setup GitHub Secrets ✅
Run the deploy script to see the exact secrets to configure:
```bash
cd deployment
./deploy.sh
```

The script will show you the exact GitHub secrets to configure:
- `AWS_REGION=ap-southeast-1`
- `EC2_SERVER_INSTANCE_ID=i-0bb3e22a6fa57f9d6`
- `EC2_CLIENT_INSTANCE_ID=i-059a54610d4a7e397`
- Plus your Docker Hub and AWS credentials

### 3. Deploy Your Applications
```bash
# Build and push Docker images
docker build -t congdinh2021/tms-server:latest ./tms-server
docker build -t congdinh2021/tms-client:latest ./tms-client
docker push congdinh2021/tms-server:latest
docker push congdinh2021/tms-client:latest

# Trigger CI/CD by pushing to GitHub
git add .
git commit -m "Deploy TMS applications"
git push origin main
```

### 4. Enable Advanced Features (Optional)
To enable IAM roles and CloudWatch monitoring, update `terraform.tfvars`:
```hcl
create_iam_resources        = true
create_cloudwatch_resources = true
```
Then run `terraform apply` again.

## Troubleshooting

### Applications Not Running?
- SSH to instances and check logs: `sudo journalctl -u docker`
- Check Docker containers: `docker ps -a`
- Check user-data logs: `sudo tail -f /var/log/user-data.log`

### SSH Access Issues?
- Ensure your SSH key has correct permissions: `chmod 600 ~/.ssh/tms-key-dev.pem`
- Use the exact SSH commands shown above
- Check security group allows SSH (port 22) from your IP

### Application Build/Deploy Issues?
- Ensure Docker images exist in Docker Hub
- Check GitHub Actions logs
- Verify GitHub secrets are configured correctly

## Cost Management
- These t3.micro instances are free-tier eligible
- Remember to `terraform destroy` when not needed to avoid charges
- Monitor AWS usage in AWS Console

## Architecture Overview
```
Internet
    |
[Internet Gateway]
    |
[Public Subnets] - [Security Group]
    |                    |
[TMS Server]        [TMS Client]
  :8080               :80
```

---
**Deployment completed**: $(date)
**Region**: ap-southeast-1
**Environment**: dev
