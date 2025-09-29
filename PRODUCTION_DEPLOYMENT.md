# 🚀 OLA Laundry Master - Production Deployment Guide

## 📋 Pre-Deployment Checklist

### ✅ Changes Ready for Production
- ✅ Security vulnerability fixed (demo token restricted to development)
- ✅ Complete login system with role-based authentication
- ✅ Fully functional Customer Mobile App
- ✅ QR Code Quick Order system
- ✅ Enhanced navigation across all mobile apps
- ✅ Comprehensive demo data and user accounts
- ✅ Production-ready configuration

## 🖥️ Namecheap VPS Deployment Steps

### 1. **Connect to Your VPS**
```bash
# SSH into your Namecheap VPS
ssh root@your-vps-ip-address
# or
ssh username@your-domain.com
```

### 2. **Navigate to Application Directory**
```bash
cd /path/to/your/olalaundry-app
# Common paths:
# cd /var/www/olalaundry
# cd /home/user/olalaundry-prod
```

### 3. **Backup Current Version (Recommended)**
```bash
# Create backup of current version
cp -r . ../olalaundry-backup-$(date +%Y%m%d-%H%M%S)

# Or backup database if using one
# pg_dump your_database > backup_$(date +%Y%m%d).sql
```

### 4. **Pull Latest Changes**
```bash
# Fetch and pull latest changes
git fetch origin
git pull origin fix/remove-demo-token-security-vulnerability

# Or if you want to merge to main branch first:
git checkout main
git merge fix/remove-demo-token-security-vulnerability
git push origin main
```

### 5. **Set Production Environment Variables**
```bash
# Create or update .env.production file
nano .env.production
```

**Required Environment Variables:**
```env
# CRITICAL: Set a strong JWT secret for production
JWT_SECRET=your-super-secure-jwt-secret-key-here-minimum-32-characters

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/olalaundry_prod

# Production Settings
NODE_ENV=production
PORT=5000
HOST=0.0.0.0

# Domain Configuration
DOMAIN=your-domain.com
CORS_ORIGIN=https://your-domain.com,https://www.your-domain.com

# Trust proxy (if behind Nginx)
TRUST_PROXY=true

# Optional: Additional security settings
SESSION_SECRET=another-secure-secret-for-sessions
```

### 6. **Install Dependencies & Build**
```bash
# Install/update dependencies
npm install

# Build the application
npm run build
```

### 7. **Database Setup (if needed)**
```bash
# Run database migrations
npm run db:push

# Or if you have migration files
npm run db:migrate
```

### 8. **Start/Restart Production Server**

#### Option A: Using PM2 (Recommended)
```bash
# Stop existing process
npm run stop

# Start production server
npm run start:prod

# Check status
npm run logs
```

#### Option B: Using systemd service
```bash
# Restart the service
sudo systemctl restart olalaundry
sudo systemctl status olalaundry
```

#### Option C: Manual restart
```bash
# Kill existing process
pkill -f "node.*olalaundry"

# Start new process
nohup npm start > app.log 2>&1 &
```

### 9. **Verify Deployment**
```bash
# Check if application is running
curl http://localhost:5000/api/auth/user

# Check logs
tail -f app.log
# or
npm run logs
```

### 10. **Update Nginx Configuration (if applicable)**
```bash
# Edit Nginx config
sudo nano /etc/nginx/sites-available/olalaundry

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## 🔧 Production Configuration Files

### **ecosystem.config.js** (PM2 Configuration)
```javascript
module.exports = {
  apps: [{
    name: 'olalaundry',
    script: 'dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
```

### **nginx.conf** (Sample Nginx Configuration)
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /path/to/ssl/certificate.crt;
    ssl_certificate_key /path/to/ssl/private.key;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔐 Production Security Checklist

### ✅ **Environment Variables**
- [ ] JWT_SECRET set to strong, unique value (minimum 32 characters)
- [ ] DATABASE_URL configured for production database
- [ ] NODE_ENV set to "production"
- [ ] CORS_ORIGIN set to your actual domain(s)
- [ ] SESSION_SECRET set (if using sessions)

### ✅ **Database Security**
- [ ] Production database with strong credentials
- [ ] Database backups configured
- [ ] SSL connection to database (if remote)

### ✅ **Server Security**
- [ ] Firewall configured (only necessary ports open)
- [ ] SSL certificate installed and configured
- [ ] Regular security updates applied
- [ ] Non-root user for application (if possible)

## 📱 **Post-Deployment Testing**

### 1. **Test Main Application**
```bash
# Test homepage
curl https://your-domain.com

# Test API health
curl https://your-domain.com/api/auth/user
```

### 2. **Test Login System**
- Visit: `https://your-domain.com/login`
- Try demo credentials:
  - Email: `owner@laundrypro.bh`
  - Password: `demo123`

### 3. **Test Mobile Apps**
- Customer App: `https://your-domain.com/customer-app`
- QR Quick Order: `https://your-domain.com/quick-order`
- Delivery App: `https://your-domain.com/delivery-app`
- POS System: `https://your-domain.com/vendor-pos`

### 4. **Test Admin Dashboard**
- Visit: `https://your-domain.com/tenant/ola-laundry/dashboard`
- Login with admin credentials

## 🚨 **Troubleshooting**

### **Application Won't Start**
```bash
# Check logs
npm run logs
# or
tail -f logs/combined.log

# Check if port is in use
netstat -tulpn | grep :5000

# Check environment variables
printenv | grep -E "(NODE_ENV|JWT_SECRET|DATABASE_URL)"
```

### **Database Connection Issues**
```bash
# Test database connection
psql $DATABASE_URL -c "SELECT 1;"

# Check database logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

### **Nginx Issues**
```bash
# Check Nginx status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## 📞 **Support Information**

**OLA ORDERS LAUNDRY W.L.L**
- 📞 Phone: +973 37960004
- 🌐 Website: www.Olalaundry.com
- 📍 Address: Shop 1309A, Road 1819, Block 318, Hoora, Manama, Kingdom of Bahrain

---

## 🎉 **Deployment Complete!**

After following these steps, your OLA Laundry Master application should be running in production with all the new features:

✅ **Secure Authentication System**
✅ **Complete Customer Mobile App**
✅ **QR Code Quick Order System**
✅ **Enhanced Admin Dashboard**
✅ **All Mobile Applications**

**Production URL**: `https://your-domain.com`

Remember to update your domain name in the configuration files and test all functionality after deployment!