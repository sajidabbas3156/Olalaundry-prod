# ⚡ Quick Production Update - Namecheap VPS

## 🚀 **Immediate Steps to Update Production**

### **Step 1: Push Changes to Main Branch**
```bash
# Switch to main branch and merge our changes
git checkout main
git merge fix/remove-demo-token-security-vulnerability
git push origin main
```

### **Step 2: Connect to Your Namecheap VPS**
```bash
# SSH into your production server
ssh root@your-vps-ip
# or if you have a domain configured:
ssh root@olalaundry.com
```

### **Step 3: Navigate to App Directory**
```bash
# Go to your application directory (adjust path as needed)
cd /var/www/olalaundry-prod
# or wherever your app is located
```

### **Step 4: Backup Current Version**
```bash
# Quick backup
cp -r . ../backup-$(date +%Y%m%d-%H%M%S)
```

### **Step 5: Pull Latest Changes**
```bash
# Pull the latest code
git pull origin main
```

### **Step 6: Set Critical Environment Variable**
```bash
# IMPORTANT: Set JWT_SECRET for production
export JWT_SECRET="your-super-secure-production-jwt-secret-key-minimum-32-chars"

# Or add to your .env file
echo "JWT_SECRET=your-super-secure-production-jwt-secret-key-minimum-32-chars" >> .env.production
```

### **Step 7: Install Dependencies & Build**
```bash
# Install any new dependencies
npm install

# Build the application
npm run build
```

### **Step 8: Restart Production Server**
```bash
# If using PM2 (recommended):
npm run stop
npm run start:prod

# Or if using systemd:
sudo systemctl restart olalaundry

# Or manual restart:
pkill -f "node.*index.js"
NODE_ENV=production npm start &
```

### **Step 9: Verify Everything Works**
```bash
# Check if server is running
curl http://localhost:5000

# Check logs
npm run logs
# or
tail -f logs/combined.log
```

---

## 🔧 **Critical Production Settings**

### **Environment Variables Required:**
```env
JWT_SECRET=your-super-secure-production-secret-minimum-32-characters
NODE_ENV=production
DATABASE_URL=your-production-database-url
DOMAIN=olalaundry.com
CORS_ORIGIN=https://olalaundry.com,https://www.olalaundry.com
```

### **Test Your Deployment:**
1. **Homepage**: `https://olalaundry.com`
2. **Login Page**: `https://olalaundry.com/login`
3. **Customer App**: `https://olalaundry.com/customer-app`
4. **QR Order**: `https://olalaundry.com/quick-order`
5. **Admin Dashboard**: `https://olalaundry.com/tenant/ola-laundry/dashboard`

---

## 🎯 **What's New in This Update**

### ✅ **Fixed Issues:**
- ✅ Customer app button now works perfectly
- ✅ Admin login system with proper credentials
- ✅ Complete laundry pages with all services
- ✅ QR Code Order functionality
- ✅ Security vulnerability fixed

### ✅ **New Features:**
- ✅ Complete login system with demo accounts
- ✅ Fully functional Customer Mobile App
- ✅ QR Code Quick Order system
- ✅ Enhanced navigation across all apps
- ✅ Role-based authentication system

### 🔐 **Demo Login Credentials (Password: demo123):**
- **Super Admin**: `superadmin@laundrypro.com`
- **Organization Owner**: `owner@laundrypro.bh`
- **Branch Manager**: `manager@laundrypro.bh`
- **Customer**: `sara.ahmed@gmail.com`

---

## 🚨 **If Something Goes Wrong**

### **Rollback to Previous Version:**
```bash
# Stop current server
npm run stop

# Restore from backup
rm -rf ./*
cp -r ../backup-YYYYMMDD-HHMMSS/* .

# Restart
npm run start:prod
```

### **Check Logs for Errors:**
```bash
# PM2 logs
npm run logs

# Or direct log files
tail -f logs/err.log
tail -f logs/out.log
```

### **Common Issues:**
1. **JWT_SECRET not set**: Add to environment variables
2. **Port already in use**: Kill existing process with `pkill -f node`
3. **Database connection**: Check DATABASE_URL in environment
4. **Nginx issues**: `sudo systemctl restart nginx`

---

## 📞 **Need Help?**

If you encounter any issues during deployment:

1. **Check the logs** first: `npm run logs`
2. **Verify environment variables** are set correctly
3. **Test database connection** if using one
4. **Check if all ports are accessible**

**Contact Information:**
- 📞 Phone: +973 37960004
- 🌐 Website: www.Olalaundry.com

---

## ✅ **Deployment Checklist**

- [ ] Connected to VPS
- [ ] Backed up current version
- [ ] Pulled latest code
- [ ] Set JWT_SECRET environment variable
- [ ] Installed dependencies
- [ ] Built application
- [ ] Restarted server
- [ ] Tested main functionality
- [ ] Verified login system works
- [ ] Tested mobile apps
- [ ] Confirmed admin dashboard access

**🎉 Your OLA Laundry Master application is now updated and ready for production use!**