# 🧹 VPS RESET & FRESH DEPLOYMENT GUIDE

Complete guide to clear your VPS and deploy the fresh OLA Laundry system from the new repository.

## 📋 OVERVIEW

This guide will help you:
1. **Completely clean** your existing VPS installation
2. **Deploy fresh** from the new repository: `https://github.com/sajidabbas3156/Olalaundry-prod.git`
3. **Verify** everything is working correctly

---

## 🚨 IMPORTANT WARNINGS

⚠️ **BACKUP FIRST**: This process will **PERMANENTLY DELETE** all existing applications and data  
⚠️ **IRREVERSIBLE**: Once you run the cleanup, you cannot recover the old installation  
⚠️ **DOWNTIME**: Your services will be offline during this process  

---

## 🛠️ STEP-BY-STEP PROCESS

### **Step 1: Connect to Your VPS**

```bash
# SSH into your AlmaLinux VPS
ssh root@YOUR_SERVER_IP
# or
ssh your_username@YOUR_SERVER_IP
```

### **Step 2: Download the Cleanup Script**

```bash
# Download the cleanup script directly
curl -o vps-cleanup.sh https://raw.githubusercontent.com/sajidabbas3156/Olalaundry-prod/main/scripts/vps-cleanup.sh

# Make it executable
chmod +x vps-cleanup.sh
```

### **Step 3: Run the Cleanup Script**

```bash
# Run the cleanup (will ask for confirmation)
./vps-cleanup.sh
```

**What the cleanup script does:**
- ✅ Stops all services (PM2, Nginx, Apache, MySQL)
- ✅ Removes all application directories
- ✅ Uninstalls Node.js and NPM completely
- ✅ Removes PM2 and all configurations
- ✅ Cleans Nginx configurations
- ✅ Resets firewall rules
- ✅ Removes databases and logs
- ✅ Cleans temporary files
- ✅ Updates system packages

### **Step 4: Download the Fresh Deployment Script**

```bash
# Download the fresh deployment script
curl -o fresh-deploy.sh https://raw.githubusercontent.com/sajidabbas3156/Olalaundry-prod/main/scripts/fresh-deploy.sh

# Make it executable
chmod +x fresh-deploy.sh
```

### **Step 5: Run the Fresh Deployment**

```bash
# Run the fresh deployment
./fresh-deploy.sh
```

**What the deployment script does:**
- ✅ Updates system packages
- ✅ Installs essential packages
- ✅ Creates application user
- ✅ Installs Node.js v18
- ✅ Installs PM2 globally
- ✅ Clones the new repository
- ✅ Installs dependencies
- ✅ Builds the application
- ✅ Sets up database
- ✅ Configures PM2
- ✅ Configures Nginx
- ✅ Sets up firewall
- ✅ Performs health checks

### **Step 6: Verify Deployment**

```bash
# Check PM2 status
sudo -u olalaundry pm2 status

# Check Nginx status
sudo systemctl status nginx

# Test application response
curl -I http://localhost

# Check logs if needed
sudo -u olalaundry pm2 logs
```

---

## 🎯 ALTERNATIVE: ONE-COMMAND RESET

If you want to do everything in one go:

```bash
# Download and run cleanup
curl -s https://raw.githubusercontent.com/sajidabbas3156/Olalaundry-prod/main/scripts/vps-cleanup.sh | bash

# Download and run fresh deployment
curl -s https://raw.githubusercontent.com/sajidabbas3156/Olalaundry-prod/main/scripts/fresh-deploy.sh | bash
```

---

## 🔧 MANUAL CLEANUP (If Scripts Fail)

If the automated scripts don't work, here's the manual process:

### **Manual Service Cleanup:**
```bash
# Stop all services
sudo pm2 kill
sudo systemctl stop nginx
sudo systemctl stop httpd
sudo systemctl disable nginx
sudo systemctl disable httpd

# Remove Node.js
sudo dnf remove -y nodejs npm
sudo rm -rf ~/.nvm ~/.npm

# Remove application directories
sudo rm -rf /var/www/olalaundry
sudo rm -rf /var/www/html
sudo rm -rf /opt/olalaundry

# Clean Nginx config
sudo rm -f /etc/nginx/conf.d/olalaundry.conf
sudo rm -f /etc/nginx/sites-available/olalaundry
sudo rm -f /etc/nginx/sites-enabled/olalaundry
```

### **Manual Fresh Installation:**
```bash
# Update system
sudo dnf update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2
sudo npm install -g pm2

# Clone repository
sudo git clone https://github.com/sajidabbas3156/Olalaundry-prod.git /var/www/olalaundry
cd /var/www/olalaundry

# Install and build
npm install
npm run build

# Start with PM2
pm2 start ecosystem.config.js
pm2 save
```

---

## 🌐 POST-DEPLOYMENT ACCESS

After successful deployment:

### **Application URLs:**
- **Local**: `http://localhost`
- **External**: `http://YOUR_SERVER_IP`

### **Management Commands:**
```bash
# Check application status
sudo -u olalaundry pm2 status

# View logs
sudo -u olalaundry pm2 logs

# Restart application
sudo -u olalaundry pm2 restart olalaundry

# Stop application
sudo -u olalaundry pm2 stop olalaundry

# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx
```

---

## 🚨 TROUBLESHOOTING

### **If PM2 fails to start:**
```bash
# Check logs
sudo -u olalaundry pm2 logs

# Try manual start
cd /var/www/olalaundry
sudo -u olalaundry node server/index.js
```

### **If Nginx fails:**
```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

### **If application doesn't respond:**
```bash
# Check if port 3000 is listening
sudo netstat -tlnp | grep :3000

# Check firewall
sudo firewall-cmd --list-all
```

### **If database issues:**
```bash
# Check database file permissions
ls -la /var/www/olalaundry/dev.db*

# Fix permissions if needed
sudo chown -R olalaundry:olalaundry /var/www/olalaundry/
```

---

## 📊 EXPECTED RESULTS

After successful deployment, you should see:

### **PM2 Status:**
```
┌─────┬──────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name         │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼──────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ olalaundry   │ default     │ 1.0.0   │ cluster │ 12345    │ 5m     │ 0    │ online    │ 0%       │ 45.2mb   │ olala... │ disabled │
└─────┴──────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
```

### **Nginx Status:**
```
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running)
```

### **Application Response:**
```bash
curl -I http://localhost
# Should return: HTTP/1.1 200 OK
```

---

## 🎉 SUCCESS INDICATORS

✅ **PM2 shows "online" status**  
✅ **Nginx is active and running**  
✅ **Application responds on port 80**  
✅ **No error messages in logs**  
✅ **Firewall allows HTTP traffic**  

---

## 📞 SUPPORT

If you encounter issues:

1. **Check the logs** first: `sudo -u olalaundry pm2 logs`
2. **Verify system status**: `sudo systemctl status nginx`
3. **Test connectivity**: `curl -I http://localhost`
4. **Review firewall**: `sudo firewall-cmd --list-all`

---

## 🔗 REPOSITORY INFORMATION

- **Repository**: https://github.com/sajidabbas3156/Olalaundry-prod.git
- **Branch**: main
- **Deployment Path**: `/var/www/olalaundry`
- **User**: `olalaundry`
- **Port**: 3000 (proxied through Nginx on port 80)

---

**🎯 Your fresh OLA Laundry system will be ready for production use!**