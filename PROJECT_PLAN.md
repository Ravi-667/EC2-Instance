# AWS EC2 Static Website Deployment - Implementation Plan

## Prerequisites

Before starting this project, ensure you have the following:

### Required
- [ ] A valid email address for AWS account creation
- [ ] A credit/debit card for AWS account verification (won't be charged on free tier)
- [ ] Basic understanding of command line/terminal operations
- [ ] A text editor (VS Code, Sublime Text, Notepad++, etc.)
- [ ] SSH client installed:
  - **Windows**: PuTTY, Git Bash, or Windows Terminal with OpenSSH
  - **macOS/Linux**: Built-in SSH client (Terminal)

### Recommended Knowledge
- [ ] Basic HTML/CSS understanding
- [ ] Familiarity with Linux command line basics
- [ ] Understanding of web servers and HTTP protocol
- [ ] Basic networking concepts (IP addresses, ports, DNS)

### Tools & Resources
- [ ] Modern web browser (Chrome, Firefox, Edge)
- [ ] Internet connection with access to AWS services
- [ ] Note-taking application for documenting your setup

---

## Phase 1: AWS Account Setup

### Step 1.1: Create AWS Account
- [ ] Navigate to [AWS Console](https://aws.amazon.com/)
- [ ] Click "Create an AWS Account"
- [ ] Provide required information:
  - Email address
  - Account name
  - Password
- [ ] Complete identity verification with phone number
- [ ] Add payment method (credit/debit card)
- [ ] Select AWS Free Tier plan
- [ ] Wait for account activation email

### Step 1.2: Secure Your Account
- [ ] Enable Multi-Factor Authentication (MFA) on root account
- [ ] Create an IAM user for daily operations (best practice)
- [ ] Review AWS Free Tier limits to avoid unexpected charges

### Step 1.3: Familiarize with AWS Console
- [ ] Explore the AWS Management Console dashboard
- [ ] Locate EC2 service in the Services menu
- [ ] Review your selected AWS region (top-right corner)
- [ ] Bookmark the EC2 dashboard for quick access

**Expected Outcome**: Active AWS account with MFA enabled and access to AWS Management Console.

---

## Phase 2: Launch EC2 Instance

### Step 2.1: Navigate to EC2 Dashboard
- [ ] Sign in to AWS Management Console
- [ ] Navigate to EC2 service (search "EC2" or use Services menu)
- [ ] Click "Launch Instance" button

### Step 2.2: Configure Instance Details

#### Name and AMI Selection
- [ ] **Name**: Give your instance a descriptive name (e.g., "my-static-website")
- [ ] **AMI**: Select "Ubuntu Server 22.04 LTS" (or latest Ubuntu LTS version)
- [ ] Ensure "64-bit (x86)" architecture is selected

#### Instance Type
- [ ] Select **t2.micro** instance type
- [ ] Verify "Free tier eligible" label is displayed

#### Key Pair Configuration
- [ ] Click "Create new key pair"
- [ ] **Key pair name**: Enter a name (e.g., "my-ec2-key")
- [ ] **Key pair type**: RSA
- [ ] **Private key file format**: 
  - `.pem` for macOS/Linux
  - `.ppk` for Windows (if using PuTTY)
- [ ] Download and save the private key file securely
- [ ] **IMPORTANT**: Store this file safely - you cannot download it again!

#### Network Settings
- [ ] **VPC**: Use default VPC
- [ ] **Subnet**: Use default subnet (no preference)
- [ ] **Auto-assign public IP**: Enable

#### Configure Security Group
- [ ] Create new security group or select existing
- [ ] **Security group name**: "web-server-sg" (or similar)
- [ ] Add inbound rules:
  - **Rule 1 - SSH**:
    - Type: SSH
    - Protocol: TCP
    - Port: 22
    - Source: My IP (or 0.0.0.0/0 for anywhere - less secure)
  - **Rule 2 - HTTP**:
    - Type: HTTP
    - Protocol: TCP
    - Port: 80
    - Source: 0.0.0.0/0 (allow from anywhere)

#### Storage Configuration
- [ ] Keep default storage: 8 GB gp2 (free tier eligible)
- [ ] No additional volumes needed

### Step 2.3: Launch Instance
- [ ] Review all configuration settings
- [ ] Click "Launch Instance"
- [ ] Wait for instance to enter "Running" state (2-3 minutes)
- [ ] Note down the **Public IPv4 address** from instance details

**Expected Outcome**: Running EC2 instance with Ubuntu, accessible via SSH and HTTP.

---

## Phase 3: Connect to EC2 Instance

### Step 3.1: Prepare SSH Connection

#### For Windows Users (using Git Bash or OpenSSH)
```bash
# Set proper permissions on key file (if needed)
chmod 400 /path/to/your-key.pem

# Connect to instance
ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
```

#### For Windows Users (using PuTTY)
- [ ] Open PuTTYgen
- [ ] Load your `.ppk` file or convert `.pem` to `.ppk`
- [ ] Open PuTTY
- [ ] Enter Host Name: `ubuntu@YOUR_PUBLIC_IP`
- [ ] Navigate to Connection → SSH → Auth
- [ ] Browse and select your private key file
- [ ] Click "Open" to connect

#### For macOS/Linux Users
```bash
# Set proper permissions on key file
chmod 400 ~/path/to/your-key.pem

# Connect to instance
ssh -i ~/path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
```

### Step 3.2: First Connection
- [ ] Accept the security warning (type "yes")
- [ ] Verify successful connection (you should see Ubuntu welcome message)
- [ ] Confirm you're logged in as `ubuntu` user

**Expected Outcome**: Successfully connected to EC2 instance via SSH.

---

## Phase 4: Server Setup and Configuration

### Step 4.1: Update System Packages
```bash
# Update package list
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y
```

### Step 4.2: Install Nginx Web Server
```bash
# Install Nginx
sudo apt install nginx -y

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Check Nginx status
sudo systemctl status nginx
```

### Step 4.3: Configure Firewall (UFW)
```bash
# Allow SSH (port 22)
sudo ufw allow 22/tcp

# Allow HTTP (port 80)
sudo ufw allow 80/tcp

# Allow HTTPS (port 443) - for future use
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check firewall status
sudo ufw status
```

### Step 4.4: Verify Nginx Installation
- [ ] Open web browser
- [ ] Navigate to: `http://YOUR_PUBLIC_IP`
- [ ] You should see the default Nginx welcome page

**Expected Outcome**: Nginx running and serving default page on port 80.

---

## Phase 5: Create and Deploy Static Website

### Step 5.1: Create Simple HTML Website
```bash
# Navigate to web root directory
cd /var/www/html

# Backup default index file
sudo mv index.nginx-debian.html index.nginx-debian.html.bak

# Create new index.html file
sudo nano index.html
```

### Step 5.2: Add HTML Content
Copy and paste the following HTML content:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My AWS EC2 Website</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            text-align: center;
            animation: fadeIn 1s ease-in;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        h1 {
            color: #667eea;
            margin-bottom: 1rem;
            font-size: 2.5rem;
        }
        
        .badge {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            font-size: 0.9rem;
            margin-bottom: 1.5rem;
        }
        
        p {
            color: #555;
            line-height: 1.6;
            margin-bottom: 1rem;
        }
        
        .info {
            background: #f0f0f0;
            padding: 1rem;
            border-radius: 10px;
            margin-top: 1.5rem;
            font-size: 0.9rem;
        }
        
        .footer {
            margin-top: 2rem;
            color: #888;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Success!</h1>
        <div class="badge">AWS EC2 Instance</div>
        <p>Your static website is now live on Amazon Web Services!</p>
        <p>This website is hosted on an <strong>Ubuntu Server</strong> running on an <strong>AWS EC2 t2.micro instance</strong>, served by <strong>Nginx</strong>.</p>
        
        <div class="info">
            <strong>Project Completed:</strong><br>
            ✅ AWS Account Created<br>
            ✅ EC2 Instance Launched<br>
            ✅ SSH Connection Established<br>
            ✅ Nginx Web Server Installed<br>
            ✅ Static Website Deployed
        </div>
        
        <div class="footer">
            <p>Powered by AWS EC2 | Built with ❤️</p>
        </div>
    </div>
</body>
</html>
```

### Step 5.3: Save and Deploy
- [ ] Save the file: `Ctrl + O`, then `Enter`
- [ ] Exit nano: `Ctrl + X`
- [ ] Set proper permissions:
```bash
sudo chmod 644 /var/www/html/index.html
sudo chown www-data:www-data /var/www/html/index.html
```

### Step 5.4: Restart Nginx
```bash
sudo systemctl restart nginx
```

### Step 5.5: Test Your Website
- [ ] Open web browser
- [ ] Navigate to: `http://YOUR_PUBLIC_IP`
- [ ] Verify your custom HTML page is displayed

**Expected Outcome**: Custom static website visible at your EC2 instance's public IP address.

---

## Phase 6: Documentation and Cleanup

### Step 6.1: Document Your Setup
Create a document with:
- [ ] AWS account details (username, region)
- [ ] EC2 instance ID and public IP address
- [ ] Security group configuration
- [ ] SSH key pair name and location
- [ ] Any issues encountered and solutions

### Step 6.2: Test Accessibility
- [ ] Access website from different devices/networks
- [ ] Verify HTTP works on port 80
- [ ] Test SSH connection from different terminal

### Step 6.3: Cost Monitoring
- [ ] Check AWS Billing Dashboard
- [ ] Set up billing alerts (recommended: alert at $5)
- [ ] Review Free Tier usage

**Expected Outcome**: Fully functional static website with complete documentation.

---

## Stretch Goals (Advanced Challenges)

### Stretch Goal 1: Custom Domain with Route 53

#### Prerequisites
- [ ] Purchase a domain name (or use existing one)
- [ ] Access to domain registrar settings

#### Steps
1. **Create Hosted Zone in Route 53**
   ```bash
   # In AWS Console:
   # Route 53 → Hosted Zones → Create Hosted Zone
   # Enter your domain name
   ```

2. **Update Name Servers**
   - [ ] Copy Route 53 name servers
   - [ ] Update name servers at your domain registrar
   - [ ] Wait for DNS propagation (up to 48 hours)

3. **Create A Record**
   - [ ] Add A record pointing to EC2 public IP
   - [ ] Test: `nslookup yourdomain.com`

4. **Update Nginx Configuration**
   ```bash
   sudo nano /etc/nginx/sites-available/default
   # Add: server_name yourdomain.com www.yourdomain.com;
   sudo systemctl restart nginx
   ```

**Expected Outcome**: Website accessible via custom domain name.

---

### Stretch Goal 2: HTTPS with Let's Encrypt

#### Prerequisites
- [ ] Domain name configured and working
- [ ] Port 443 open in security group

#### Steps
1. **Install Certbot**
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   ```

2. **Obtain SSL Certificate**
   ```bash
   sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
   ```

3. **Test Auto-Renewal**
   ```bash
   sudo certbot renew --dry-run
   ```

4. **Verify HTTPS**
   - [ ] Navigate to: `https://yourdomain.com`
   - [ ] Check for padlock icon in browser

**Expected Outcome**: Website accessible via HTTPS with valid SSL certificate.

---

### Stretch Goal 3: CI/CD Pipeline with AWS CodePipeline

#### Prerequisites
- [ ] GitHub/GitLab repository for website code
- [ ] AWS CodeCommit, CodeBuild, CodeDeploy familiarity

#### Overview
1. **Set Up Source Control**
   - [ ] Push website files to GitHub repository
   - [ ] Create `buildspec.yml` for CodeBuild

2. **Create CodePipeline**
   - [ ] Source: Connect to GitHub repository
   - [ ] Build: Configure CodeBuild project
   - [ ] Deploy: Use CodeDeploy to EC2 instance

3. **Configure CodeDeploy Agent on EC2**
   ```bash
   # Install CodeDeploy agent
   sudo apt update
   sudo apt install ruby wget -y
   cd /home/ubuntu
   wget https://aws-codedeploy-YOUR_REGION.s3.YOUR_REGION.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   sudo systemctl start codedeploy-agent
   ```

4. **Create AppSpec File**
   - [ ] Add `appspec.yml` to repository
   - [ ] Define deployment hooks

5. **Test Pipeline**
   - [ ] Make changes to HTML file
   - [ ] Push to repository
   - [ ] Verify automatic deployment

**Expected Outcome**: Automated deployment pipeline that updates website on code changes.

---

## Learning Outcomes Checklist

After completing this project, you should be able to:

### Cloud Computing Fundamentals
- [ ] Explain what cloud computing is and its benefits
- [ ] Understand IaaS, PaaS, and SaaS models
- [ ] Describe AWS Free Tier offerings and limitations

### AWS EC2
- [ ] Launch and configure EC2 instances
- [ ] Choose appropriate instance types for workloads
- [ ] Understand AMIs and their purpose
- [ ] Manage instance lifecycle (start, stop, terminate)

### Networking
- [ ] Configure security groups and firewall rules
- [ ] Understand public vs. private IP addresses
- [ ] Explain inbound and outbound traffic rules
- [ ] Describe VPC and subnet concepts

### Linux Administration
- [ ] Connect to remote servers via SSH
- [ ] Execute basic Linux commands
- [ ] Manage system packages with apt
- [ ] Configure and manage systemd services
- [ ] Set file permissions and ownership

### Web Servers
- [ ] Install and configure Nginx
- [ ] Serve static content
- [ ] Understand web server configuration files
- [ ] Troubleshoot basic web server issues

### Security Best Practices
- [ ] Use SSH key authentication
- [ ] Secure private key files
- [ ] Configure minimal security group rules
- [ ] Implement HTTPS (if completed stretch goal)
- [ ] Enable MFA on AWS account

---

## Troubleshooting Guide

### Cannot SSH to Instance
**Issue**: Connection timeout or refused
**Solutions**:
- [ ] Verify security group allows inbound SSH (port 22)
- [ ] Check instance is in "running" state
- [ ] Confirm correct public IP address
- [ ] Verify key file permissions: `chmod 400 yourkey.pem`
- [ ] Check if using correct username (`ubuntu` for Ubuntu AMI)

### Website Not Loading
**Issue**: Cannot access website via browser
**Solutions**:
- [ ] Verify Nginx is running: `sudo systemctl status nginx`
- [ ] Check security group allows HTTP (port 80)
- [ ] Confirm using HTTP not HTTPS: `http://YOUR_IP`
- [ ] Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`
- [ ] Verify firewall rules: `sudo ufw status`

### Unexpected AWS Charges
**Issue**: Receiving charges beyond free tier
**Solutions**:
- [ ] Review AWS Billing Dashboard
- [ ] Check for running instances you forgot to stop
- [ ] Verify you're using t2.micro (free tier eligible)
- [ ] Review data transfer limits (1GB/month outbound)
- [ ] Stop or terminate unused instances

### Lost SSH Key
**Issue**: Cannot access instance due to lost private key
**Solutions**:
- [ ] No way to recover private key
- [ ] Options: Create AMI snapshot and launch new instance with new key
- [ ] Prevention: Back up private keys securely

---

## Cost Estimation

### Free Tier Limits (12 months)
- **EC2 t2.micro**: 750 hours/month (one instance running 24/7)
- **Storage**: 30 GB EBS storage
- **Data Transfer**: 15 GB outbound per month
- **Public IP**: Free when instance is running

### After Free Tier
- **t2.micro instance**: ~$8-10/month
- **EBS storage**: ~$0.10/GB/month
- **Data transfer**: ~$0.09/GB

### Cost Optimization Tips
- [ ] Stop instances when not in use (you're only charged when running)
- [ ] Use AWS Cost Explorer to monitor spending
- [ ] Set up billing alerts
- [ ] Delete unused resources (snapshots, volumes, elastic IPs)

---

## Next Steps

After completing this project, consider:

1. **Expand Your AWS Knowledge**
   - [ ] Explore S3 for static website hosting (simpler alternative)
   - [ ] Learn about Elastic Load Balancers
   - [ ] Study AWS Lambda for serverless computing

2. **Deploy More Complex Projects**
   - [ ] Deploy a Node.js/Python web application
   - [ ] Set up a database with RDS
   - [ ] Create multi-tier architecture

3. **Learn Infrastructure as Code**
   - [ ] Use AWS CloudFormation templates
   - [ ] Explore Terraform for infrastructure automation

4. **Pursue AWS Certification**
   - [ ] AWS Certified Cloud Practitioner
   - [ ] AWS Certified Solutions Architect - Associate

---

## Additional Resources

### Official Documentation
- [AWS Free Tier](https://aws.amazon.com/free/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

### Tutorials
- [AWS EC2 Getting Started](https://aws.amazon.com/ec2/getting-started/)
- [Nginx Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html)
- [SSH Key Management](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

### Community
- [AWS Forums](https://forums.aws.amazon.com/)
- [Stack Overflow - AWS Tag](https://stackoverflow.com/questions/tagged/amazon-web-services)
- [r/aws on Reddit](https://reddit.com/r/aws)

---

## Project Completion Checklist

Mark each item as you complete it:

- [ ] AWS account created and secured with MFA
- [ ] EC2 instance launched with Ubuntu AMI
- [ ] Security group configured for SSH and HTTP
- [ ] Successfully connected via SSH
- [ ] System packages updated
- [ ] Nginx installed and running
- [ ] Static website created and deployed
- [ ] Website accessible via public IP
- [ ] Documentation completed
- [ ] Billing alerts configured
- [ ] **BONUS**: Custom domain configured (Route 53)
- [ ] **BONUS**: HTTPS enabled (Let's Encrypt)
- [ ] **BONUS**: CI/CD pipeline created (CodePipeline)

---

**Congratulations!** 🎉 You've successfully deployed a static website on AWS EC2. You now have practical experience with cloud infrastructure and are ready to tackle more advanced projects!
