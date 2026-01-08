# Troubleshooting Guide

Common issues and solutions for AWS EC2 static website deployment.

## Table of Contents

- [SSH Connection Issues](#ssh-connection-issues)
- [Website Not Loading](#website-not-loading)
- [Nginx Issues](#nginx-issues)
- [AWS Account & Billing Issues](#aws-account--billing-issues)
- [Security Group Issues](#security-group-issues)
- [File Permission Issues](#file-permission-issues)
- [General AWS Issues](#general-aws-issues)

---

## SSH Connection Issues

### Cannot Connect - "Connection timed out"

**Symptoms**: SSH connection hangs and times out

**Possible Causes**:
- Security group not allowing SSH traffic
- Instance not running
- Wrong IP address
- Network issues

**Solutions**:
1. **Check instance status**:
   - Go to EC2 Dashboard
   - Verify instance state is "Running"
   - If stopped, click "Start Instance"

2. **Verify security group**:
   - Select instance → Security tab
   - Check inbound rules allow SSH (port 22)
   - Source should include your IP address
   - Add rule if missing:
     - Type: SSH
     - Protocol: TCP
     - Port: 22
     - Source: Your IP or 0.0.0.0/0

3. **Confirm correct IP**:
   - Use the Public IPv4 address (not Private IP)
   - Copy directly from EC2 console
   - Public IP changes if instance stops/starts

4. **Test connection**:
   ```bash
   ping YOUR_PUBLIC_IP
   telnet YOUR_PUBLIC_IP 22
   ```

### "Permission denied (publickey)"

**Symptoms**: SSH rejects authentication

**Possible Causes**:
- Wrong username
- Incorrect key file
- Key file permissions too open
- Wrong instance/key pair mismatch

**Solutions**:
1. **Use correct username**:
   - Ubuntu AMI: `ubuntu`
   - Amazon Linux: `ec2-user`
   - CentOS: `centos`
   
   ```bash
   ssh -i key.pem ubuntu@YOUR_IP  # Not root!
   ```

2. **Fix key permissions**:
   ```bash
   # Linux/macOS
   chmod 400 your-key.pem
   
   # Windows PowerShell
   icacls your-key.pem /inheritance:r
   icacls your-key.pem /grant:r "$($env:USERNAME):(R)"
   ```

3. **Verify correct key file**:
   - Ensure using the key pair associated with the instance
   - Check EC2 console → Instance details → Key pair name

4. **Try verbose mode for debugging**:
   ```bash
   ssh -vvv -i key.pem ubuntu@YOUR_IP
   ```

### "WARNING: UNPROTECTED PRIVATE KEY FILE"

**Symptoms**: SSH warns about key permissions

**Cause**: Key file has too-open permissions

**Solution**:
```bash
chmod 400 your-key.pem
```

### "Host key verification failed"

**Symptoms**: SSH warns about changed host key

**Cause**: Instance was recreated or IP reassigned

**Solution**:
```bash
ssh-keygen -R YOUR_PUBLIC_IP
```

### "No such file or directory" (Key not found)

**Symptoms**: SSH can't find key file

**Solutions**:
1. **Use absolute path**:
   ```bash
   ssh -i /full/path/to/key.pem ubuntu@YOUR_IP
   ```

2. **Check file exists**:
   ```bash
   ls -la key.pem
   ```

3. **Navigate to key directory**:
   ```bash
   cd ~/Downloads  # or wherever key is stored
   ssh -i ./key.pem ubuntu@YOUR_IP
   ```

---

## Website Not Loading

### Browser Shows "Site Can't Be Reached"

**Symptoms**: Cannot access website via public IP

**Solutions**:

1. **Check security group**:
   - Must allow HTTP (port 80)
   - Inbound rule:
     - Type: HTTP
     - Protocol: TCP
     - Port: 80
     - Source: 0.0.0.0/0

2. **Verify Nginx is running**:
   ```bash
   ssh to instance
   sudo systemctl status nginx
   ```
   
   If not running:
   ```bash
   sudo systemctl start nginx
   ```

3. **Check firewall (UFW)**:
   ```bash
   sudo ufw status
   ```
   
   Should show:
   ```
   80/tcp         ALLOW       Anywhere
   ```
   
   If not allowed:
   ```bash
   sudo ufw allow 80/tcp
   ```

4. **Use HTTP not HTTPS**:
   - ✅ Correct: `http://YOUR_IP`
   - ❌ Wrong: `https://YOUR_IP`

5. **Test from server**:
   ```bash
   curl http://localhost
   curl http://YOUR_PUBLIC_IP
   ```

### Shows Nginx Default Page Instead of Custom Site

**Symptoms**: Nginx welcome page appears, not your custom page

**Solutions**:

1. **Check file location**:
   ```bash
   ls -la /var/www/html/index.html
   ```

2. **Ensure index.html exists**:
   ```bash
   sudo nano /var/www/html/index.html
   # Add your HTML content
   ```

3. **Check file permissions**:
   ```bash
   sudo chmod 644 /var/www/html/index.html
   sudo chown www-data:www-data /var/www/html/index.html
   ```

4. **Clear browser cache**:
   - Press Ctrl+Shift+R (hard refresh)
   - Try incognito/private window

5. **Restart Nginx**:
   ```bash
   sudo systemctl restart nginx
   ```

### Page Shows Old Content

**Symptoms**: Changes not appearing

**Solutions**:

1. **Clear browser cache**: Ctrl+Shift+R

2. **Verify file updated on server**:
   ```bash
   sudo cat /var/www/html/index.html
   ```

3. **Check Nginx cache** (if configured):
   ```bash
   sudo rm -rf /var/cache/nginx/*
   sudo systemctl restart nginx
   ```

---

## Nginx Issues

### Nginx Won't Start

**Symptoms**: `systemctl start nginx` fails

**Solutions**:

1. **Check error logs**:
   ```bash
   sudo journalctl -xe
   sudo tail -50 /var/log/nginx/error.log
   ```

2. **Test configuration**:
   ```bash
   sudo nginx -t
   ```

3. **Check port conflict**:
   ```bash
   sudo netstat -tulpn | grep :80
   sudo lsof -i :80
   ```

4. **Fix configuration errors**:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```

5. **Reinstall if corrupted**:
   ```bash
   sudo apt remove nginx
   sudo apt purge nginx
   sudo apt install nginx
   ```

### 403 Forbidden Error

**Symptoms**: Browser shows "403 Forbidden"

**Cause**: File permissions or ownership issues

**Solutions**:

1. **Fix file ownership**:
   ```bash
   sudo chown -R www-data:www-data /var/www/html
   ```

2. **Fix file permissions**:
   ```bash
   sudo chmod 755 /var/www/html
   sudo chmod 644 /var/www/html/index.html
   ```

3. **Check directory permissions**:
   ```bash
   ls -la /var/www/html/
   ```

4. **Check SELinux** (if applicable):
   ```bash
   sudo setenforce 0  # Temporarily disable
   ```

### 502 Bad Gateway Error

**Symptoms**: Browser shows "502 Bad Gateway"

**Cause**: Backend service not running or misconfigured

**Solutions**:

1. For static sites, this shouldn't occur
2. Check Nginx configuration:
   ```bash
   sudo nginx -t
   ```

3. Restart Nginx:
   ```bash
   sudo systemctl restart nginx
   ```

---

## AWS Account & Billing Issues

### Unexpected Charges

**Symptoms**: AWS bill higher than expected

**Solutions**:

1. **Check Billing Dashboard**:
   - AWS Console → Billing
   - Review charges by service

2. **Common causes**:
   - Instance running 24/7 beyond 750 hours
   - Multiple instances running
   - Data transfer exceeds 15GB/month
   - Elastic IP not attached to running instance

3. **Free Tier limits**:
   - 750 hours t2.micro per month (first 12 months)
   - 30 GB storage
   - 15 GB data transfer OUT

4. **Cost optimization**:
   ```bash
   # Stop instance when not in use
   aws ec2 stop-instances --instance-ids i-xxxxx
   
   # Or from console: Instance → Instance State → Stop
   ```

5. **Set up billing alerts**:
   - Billing → Budgets → Create Budget
   - Set threshold (e.g., $5)

### Free Tier Expired

**Symptoms**: Charges appearing after 12 months

**Solutions**:
- Free tier expires after 12 months
- Expected cost: ~$8-10/month for t2.micro
- Stop instances when not in use
- Consider AWS Lightsail for fixed pricing
- Terminate resources if no longer needed

### Can't Access Billing Dashboard

**Symptoms**: "You are not authorized" error

**Solutions**:
1. Must be root account or IAM user with billing permissions
2. Sign in with root account credentials
3. Enable IAM access to billing (root account):
   - Account → IAM User and Role Access to Billing Information

---

## Security Group Issues

### Can't Edit Security Group

**Symptoms**: Changes don't save or permission errors

**Solutions**:
1. Check IAM permissions
2. Ensure correct security group selected
3. Some actions require admin privileges

### Too Many Security Groups

**Symptoms**: Confused about which group to modify

**Solutions**:
1. Check instance → Security tab
2. Note security group ID
3. Modify only that security group

### Locked Out After Changing Rules

**Symptoms**: Lost SSH access after modifying security group

**Solutions**:
1. Use EC2 Instance Connect in console
2. Add your current IP to security group
3. Or temporarily allow 0.0.0.0/0 for troubleshooting (remove after)

---

## File Permission Issues

### Can't Edit Files in /var/www/html

**Symptoms**: "Permission denied" when editing

**Solutions**:

1. **Use sudo**:
   ```bash
   sudo nano /var/www/html/index.html
   ```

2. **Add user to www-data group** (optional):
   ```bash
   sudo usermod -aG www-data ubuntu
   sudo chown -R www-data:www-data /var/www/html
   sudo chmod -R 775 /var/www/html
   # Logout and login again
   ```

### Files Have Wrong Ownership

**Symptoms**: Nginx can't read files

**Solution**:
```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo chmod 644 /var/www/html/*.html
```

---

## General AWS Issues

### Instance State Stuck

**Symptoms**: Instance stuck in "pending" or "stopping"

**Solutions**:
1. Wait 5-10 minutes
2. Refresh console
3. Stop and start instance
4. Contact AWS support if persists

### Can't Find EC2 in Console

**Symptoms**: EC2 service not visible

**Solutions**:
1. Check correct AWS region (top-right dropdown)
2. Instance might be in different region
3. Check all regions for resources

### Lost Private Key

**Symptoms**: Cannot SSH, lost .pem file

**Solutions**:
1. **No way to recover the private key**
2. Options:
   - Create AMI of instance
   - Launch new instance with new key pair
   - Restore from AMI
3. **Prevention**: Back up keys securely

### Instance won't Start

**Symptoms**: Start fails or instance immediately stops

**Solutions**:
1. Check instance limits for account
2. Verify Free Tier eligibility
3. Check billing/payment method
4. Review status checks in console
5. Check CloudWatch logs

---

## Debugging Commands

### System Diagnostics

```bash
# Check system logs
sudo journalctl -xe

# Check Nginx status
sudo systemctl status nginx

# Test Nginx configuration
sudo nginx -t

# Check open ports
sudo netstat -tulpn

# Check running processes
ps aux | grep nginx

# Check disk space
df -h

# Check memory
free -h

# Check firewall status
sudo ufw status verbose
```

### Network Diagnostics

```bash
# Test local web server
curl http://localhost

# Test public IP from server
curl http://YOUR_PUBLIC_IP

# Check listening ports
sudo lsof -i :80
sudo lsof -i :22

# DNS lookup
nslookup your-domain.com

# Trace route
traceroute your-domain.com
```

### Log Files to Check

```bash
# Nginx access log
sudo tail -f /var/log/nginx/access.log

# Nginx error log
sudo tail -f /var/log/nginx/error.log

# System log
sudo tail -f /var/log/syslog

# Auth log (SSH attempts)
sudo tail -f /var/log/auth.log
```

---

## Getting Help

### AWS Support

1. **Free Tier**: Basic support included
2. **Documentation**: [AWS Docs](https://docs.aws.amazon.com/)
3. **Forums**: [AWS Forums](https://forums.aws.amazon.com/)
4. **Support Center**: AWS Console → Support

### Community Resources

- [Stack Overflow - AWS Tag](https://stackoverflow.com/questions/tagged/amazon-web-services)
- [Reddit - r/aws](https://reddit.com/r/aws)
- [AWS Subreddit Wiki](https://www.reddit.com/r/aws/wiki/)
- [ServerFault](https://serverfault.com/)

### Before Asking for Help

Gather this information:
- Instance ID
- AMI used
- Instance type
- Security group configuration
- Error messages (exact text)
- Steps to reproduce
- What you've tried already

---

## Prevention Tips

### Regular Maintenance

```bash
# Update system weekly
sudo apt update && sudo apt upgrade -y

# Check disk space
df -h

# Review logs for errors
sudo tail -100 /var/log/nginx/error.log

# Check security updates
sudo unattended-upgrades --dry-run
```

### Monitoring

1. **Set up CloudWatch alarms**
2. **Enable billing alerts**
3. **Review logs regularly**
4. **Check AWS Service Health Dashboard**

### Backups

```bash
# Create AMI from instance (AWS Console)
# Or use AWS CLI:
aws ec2 create-image --instance-id i-xxxxx --name "backup-$(date +%Y%m%d)"
```

### Documentation

Keep record of:
- Instance IDs
- Security group IDs
- Key pair names
- Elastic IP addresses
- Configuration changes made

---

**Still stuck?** Check the [SSH_GUIDE.md](./SSH_GUIDE.md) for more detailed SSH troubleshooting.
