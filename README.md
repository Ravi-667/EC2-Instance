# AWS EC2 Static Website Deployment Project

> Deploy a beautiful static website on Amazon Web Services using EC2 and Nginx

## 📋 Project Overview

This project demonstrates deploying a static website on AWS EC2, providing hands-on experience with cloud infrastructure, Linux server administration, and web server configuration.

## 🎯 Learning Objectives

- Understand cloud computing fundamentals and AWS services
- Launch and configure EC2 instances
- Manage Linux servers via SSH
- Configure web servers (Nginx)
- Deploy static websites to cloud infrastructure
- Implement security best practices (security groups, SSH keys)

## 🛠️ Technologies Used

- **Cloud Platform**: Amazon Web Services (AWS)
- **Compute Service**: EC2 (Elastic Compute Cloud)
- **Operating System**: Ubuntu Server 22.04 LTS
- **Web Server**: Nginx
- **Frontend**: HTML, CSS, JavaScript

## 📁 Project Structure

```
EC2-Instance/
├── README.md                 # Project documentation
├── PROJECT_PLAN.md          # Detailed implementation guide
├── website/                 # Static website files
│   └── index.html          # Main website file
├── scripts/                # Deployment scripts
│   ├── deploy.sh           # Deployment automation script
│   └── ssh-connect.sh      # SSH connection helper
└── docs/                   # Additional documentation
    ├── SSH_GUIDE.md        # SSH connection guide
    └── TROUBLESHOOTING.md  # Common issues and solutions
```

## 🚀 Quick Start

### Prerequisites

- AWS account (with Free Tier eligibility)
- Credit/debit card for AWS verification
- SSH client installed
- Basic command line knowledge

### Implementation Steps

1. **Follow the detailed guide**: See [PROJECT_PLAN.md](./PROJECT_PLAN.md) for complete step-by-step instructions

2. **Create AWS Account**: Sign up at [aws.amazon.com](https://aws.amazon.com)

3. **Launch EC2 Instance**:
   - AMI: Ubuntu Server 22.04 LTS
   - Instance Type: t2.micro (Free Tier)
   - Security Groups: Allow ports 22 (SSH) and 80 (HTTP)

4. **Connect via SSH**:
   ```bash
   ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
   ```

5. **Install Nginx**:
   ```bash
   sudo apt update
   sudo apt install nginx -y
   sudo systemctl start nginx
   ```

6. **Deploy Website**:
   ```bash
   # Copy website file to server
   scp -i /path/to/your-key.pem website/index.html ubuntu@YOUR_PUBLIC_IP:/tmp/
   
   # SSH into server and move file
   ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
   sudo mv /tmp/index.html /var/www/html/index.html
   sudo systemctl restart nginx
   ```

7. **Access Website**: Open `http://YOUR_PUBLIC_IP` in browser

## 📊 Instance Configuration

| Setting | Value |
|---------|-------|
| **AMI** | Ubuntu Server 22.04 LTS |
| **Instance Type** | t2.micro |
| **vCPUs** | 1 |
| **Memory** | 1 GB RAM |
| **Storage** | 8 GB EBS (gp2) |
| **Network** | Default VPC |
| **Public IP** | Auto-assigned |

## 🔒 Security Configuration

### Security Group Rules

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | My IP (recommended) | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web traffic |

### Best Practices

- ✅ Use SSH key authentication (no passwords)
- ✅ Restrict SSH access to your IP address
- ✅ Enable MFA on AWS root account
- ✅ Keep system packages updated
- ✅ Use firewall (UFW) on server
- ✅ Monitor AWS billing regularly

## 💰 Cost Information

### AWS Free Tier (First 12 Months)
- **EC2**: 750 hours/month of t2.micro
- **Storage**: 30 GB EBS
- **Data Transfer**: 15 GB/month outbound

### After Free Tier
- **t2.micro**: ~$8-10/month
- **Storage**: ~$0.80/month (8 GB)
- **Data Transfer**: ~$0.09/GB

💡 **Tip**: Stop your instance when not in use to save costs!

## 🎓 Learning Outcomes

After completing this project, you will understand:

- ✅ Cloud computing concepts (IaaS, virtual machines)
- ✅ AWS EC2 service and instance management
- ✅ Linux server administration basics
- ✅ SSH protocol and key-based authentication
- ✅ Web server configuration (Nginx)
- ✅ Network security (firewalls, security groups)
- ✅ Static website hosting

## 🚀 Stretch Goals

Want to take it further? Try these challenges:

1. **Custom Domain**: Set up a domain name using AWS Route 53
2. **HTTPS**: Add SSL certificate with Let's Encrypt
3. **CI/CD**: Automate deployments with AWS CodePipeline
4. **Monitoring**: Set up CloudWatch alarms
5. **Load Balancing**: Add Elastic Load Balancer
6. **Auto Scaling**: Configure auto-scaling groups

## 📚 Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [SSH Key Management](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

## 🐛 Troubleshooting

### Common Issues

**Cannot connect via SSH**
- Verify security group allows port 22
- Check instance is running
- Ensure correct key file permissions: `chmod 400 key.pem`

**Website not loading**
- Check security group allows port 80
- Verify Nginx is running: `sudo systemctl status nginx`
- Ensure using HTTP not HTTPS

**Unexpected charges**
- Stop unused instances
- Check data transfer usage
- Review Free Tier limits

For more help, see [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)

## 📝 Project Status

- [x] Project planning and documentation
- [ ] AWS account setup
- [ ] EC2 instance launched
- [ ] Server configured
- [ ] Website deployed
- [ ] Testing completed

## 🤝 Contributing

This is a learning project, but suggestions are welcome! Feel free to:
- Report issues
- Suggest improvements
- Share your deployment experience

## 📄 License

This project is open source and available for educational purposes.

## 🙌 Acknowledgments

- AWS for providing Free Tier resources
- Ubuntu and Nginx communities
- Cloud computing learning community

---

**Ready to deploy?** Start with [PROJECT_PLAN.md](./PROJECT_PLAN.md) for detailed instructions! 🚀