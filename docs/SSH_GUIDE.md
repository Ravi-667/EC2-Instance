# SSH Connection Guide for AWS EC2

This guide will help you connect to your AWS EC2 instance using SSH (Secure Shell).

## Prerequisites

- EC2 instance running and in "Running" state
- Private key file (.pem) downloaded from AWS
- Instance's public IP address
- Security group allowing inbound SSH (port 22)

## Quick Reference

### Connection Command

```bash
ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
```

Replace:
- `/path/to/your-key.pem` with actual path to your private key
- `YOUR_PUBLIC_IP` with your EC2 instance's public IP address

---

## Platform-Specific Instructions

### Windows

#### Option 1: Using Git Bash (Recommended)

1. **Install Git Bash**: Download from [git-scm.com](https://git-scm.com/)

2. **Set key permissions**:
   ```bash
   chmod 400 /path/to/your-key.pem
   ```

3. **Connect**:
   ```bash
   ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
   ```

#### Option 2: Using Windows PowerShell/CMD with OpenSSH

1. **Verify OpenSSH is installed**:
   ```powershell
   ssh -V
   ```

2. **Set key permissions**:
   - Right-click the .pem file → Properties
   - Security tab → Advanced
   - Disable inheritance and remove all users except yourself
   - Give yourself Full Control

3. **Connect**:
   ```powershell
   ssh -i C:\path\to\your-key.pem ubuntu@YOUR_PUBLIC_IP
   ```

#### Option 3: Using PuTTY

1. **Convert .pem to .ppk format**:
   - Download and open PuTTYgen
   - Load your .pem file (select "All Files" in file dialog)
   - Click "Save private key"
   - Save as .ppk file

2. **Connect using PuTTY**:
   - Open PuTTY
   - Host Name: `ubuntu@YOUR_PUBLIC_IP`
   - Port: 22
   - Connection → SSH → Auth → Browse for .ppk file
   - Click "Open"

### macOS

1. **Open Terminal**

2. **Set key permissions**:
   ```bash
   chmod 400 ~/path/to/your-key.pem
   ```

3. **Connect**:
   ```bash
   ssh -i ~/path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
   ```

### Linux

1. **Open Terminal**

2. **Set key permissions**:
   ```bash
   chmod 400 ~/path/to/your-key.pem
   ```

3. **Connect**:
   ```bash
   ssh -i ~/path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP
   ```

---

## Important Notes

### Default Usernames by AMI

| AMI Type | Username |
|----------|----------|
| Ubuntu | `ubuntu` |
| Amazon Linux | `ec2-user` |
| CentOS | `centos` |
| Debian | `admin` |
| RHEL | `ec2-user` |

### Key File Permissions

**Linux/macOS**: Key file must have `400` or `600` permissions:
```bash
chmod 400 your-key.pem
```

**Windows**: Only the current user should have access to the key file.

---

## Common Issues and Solutions

### Issue: "Permission denied (publickey)"

**Cause**: Key file permissions too open or wrong username

**Solutions**:
1. Check key permissions: `chmod 400 your-key.pem`
2. Verify username (should be `ubuntu` for Ubuntu AMI)
3. Ensure using correct key file for the instance

### Issue: "Connection timed out"

**Cause**: Security group not allowing SSH or instance not running

**Solutions**:
1. Check instance state (must be "Running")
2. Verify security group allows inbound SSH (port 22)
3. Confirm using correct public IP address
4. Check your internet connection

### Issue: "Host key verification failed"

**Cause**: Host key changed (usually after replacing instance)

**Solution**:
```bash
ssh-keygen -R YOUR_PUBLIC_IP
```

### Issue: "Warning: Unprotected private key file"

**Cause**: Key file permissions too open

**Solution**:
```bash
chmod 400 your-key.pem
```

### Issue: "No such file or directory" (Key file not found)

**Cause**: Incorrect path to key file

**Solutions**:
1. Use absolute path: `/home/user/keys/mykey.pem`
2. Navigate to key directory: `cd /path/to/keys`
3. Verify file exists: `ls -la | grep .pem`

---

## Advanced SSH Options

### Connect Without Typing Full Command

Create SSH config file: `~/.ssh/config`

```
Host my-ec2
    HostName YOUR_PUBLIC_IP
    User ubuntu
    IdentityFile /path/to/your-key.pem
```

Then connect with:
```bash
ssh my-ec2
```

### Copy Files to EC2 (SCP)

**Upload file to EC2**:
```bash
scp -i /path/to/key.pem /local/file.txt ubuntu@YOUR_PUBLIC_IP:/remote/path/
```

**Download file from EC2**:
```bash
scp -i /path/to/key.pem ubuntu@YOUR_PUBLIC_IP:/remote/file.txt /local/path/
```

**Upload entire directory**:
```bash
scp -i /path/to/key.pem -r /local/directory ubuntu@YOUR_PUBLIC_IP:/remote/path/
```

### Port Forwarding

Forward remote port to local machine:
```bash
ssh -i /path/to/key.pem -L 8080:localhost:80 ubuntu@YOUR_PUBLIC_IP
```

Access via `http://localhost:8080` on your local machine.

### Keep Connection Alive

Add to SSH command:
```bash
ssh -i /path/to/key.pem -o ServerAliveInterval=60 ubuntu@YOUR_PUBLIC_IP
```

Or add to `~/.ssh/config`:
```
ServerAliveInterval 60
ServerAliveCountMax 3
```

---

## Security Best Practices

### 1. Protect Your Private Key

- ✅ Never share your .pem file
- ✅ Set restrictive permissions (400)
- ✅ Store in secure location
- ✅ Back up to encrypted storage
- ❌ Don't commit to version control
- ❌ Don't email or upload to cloud

### 2. Secure Your Instance

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Configure firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable

# Disable root login (optional)
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

### 3. Restrict SSH Access

In AWS Security Group:
- **Don't use**: 0.0.0.0/0 (allows everyone)
- **Do use**: Your specific IP address (e.g., 203.0.113.25/32)

### 4. Use SSH Key Rotation

Regularly rotate your SSH keys:
1. Generate new key pair in AWS
2. Add new key to instance
3. Test connection with new key
4. Remove old key

---

## Helpful Commands After Connecting

### System Information
```bash
# Check system info
uname -a
lsb_release -a

# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
top
htop  # (install with: sudo apt install htop)
```

### Nginx Management
```bash
# Check Nginx status
sudo systemctl status nginx

# Start Nginx
sudo systemctl start nginx

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx
sudo systemctl restart nginx

# Check configuration
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log

# View access logs
sudo tail -f /var/log/nginx/access.log
```

### File Management
```bash
# Navigate to web root
cd /var/www/html

# List files
ls -la

# Edit index.html
sudo nano /var/www/html/index.html

# Set proper permissions
sudo chown www-data:www-data /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
```

---

## Using Helper Scripts

This project includes helper scripts:

### SSH Connection Script

```bash
# Update configuration in scripts/ssh-connect.sh
# Then run:
bash scripts/ssh-connect.sh

# Test connection only:
bash scripts/ssh-connect.sh --test

# Show connection info:
bash scripts/ssh-connect.sh --info
```

---

## Disconnecting from SSH

To disconnect from your SSH session:

1. Type `exit` and press Enter
2. Or press `Ctrl+D`
3. Or close the terminal window

---

## Quick Troubleshooting Checklist

Before asking for help, verify:

- [ ] EC2 instance is in "Running" state
- [ ] Security group allows SSH (port 22) from your IP
- [ ] Using correct public IP address
- [ ] Using correct username (`ubuntu` for Ubuntu)
- [ ] Key file permissions are 400 or 600
- [ ] Using correct key file path
- [ ] Internet connection is working

---

## Additional Resources

- [AWS EC2 SSH Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
- [SSH Command Manual](https://man.openbsd.org/ssh)
- [PuTTY Documentation](https://www.chiark.greenend.org.uk/~sgtatham/putty/docs.html)
- [OpenSSH for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)

---

## Need Help?

If you're still having trouble connecting:

1. Check AWS EC2 instance logs in the console
2. Review security group rules
3. Verify key pair is correct
4. Try connecting from a different network
5. Check AWS Service Health Dashboard for outages

**Remember**: Keep your private key secure and never share it!
