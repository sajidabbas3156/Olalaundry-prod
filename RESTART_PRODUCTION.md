# 🚀 Complete Production Restart Guide

## **Step-by-Step Restart Process:**

### **1. Complete Cleanup**
```bash
# Stop all PM2 processes
pm2 delete all
pm2 kill

# Kill any remaining node processes
pkill -f "node"
sudo lsof -ti:3000 | xargs kill -9 2>/dev/null || true
sudo lsof -ti:5000 | xargs kill -9 2>/dev/null || true

# Verify nothing is running
netstat -tulpn | grep -E ":3000|:5000"
```

### **2. Pull Latest Code (with fixed ecosystem.config.js)**
```bash
# Fix git ownership if needed
git config --global --add safe.directory /var/www/olalaundry

# Pull latest changes (includes the port fix)
git pull origin main
```

### **3. Set Environment Variables**
```bash
export NODE_ENV=production
export PORT=5000
export HOST=0.0.0.0
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"

# Verify they're set
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
echo "JWT_SECRET: $JWT_SECRET"
```

### **4. Clean Install & Build**
```bash
# Clean install
rm -rf node_modules package-lock.json dist
npm install --legacy-peer-deps

# Build application
npm run build

# Verify build output
ls -la dist/
```

### **5. Start Production Server**
```bash
# Method 1: Using PM2 (recommended)
npm run start:prod

# Method 2: If PM2 fails, start manually
# NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" nohup node dist/index.js > app.log 2>&1 &
```

### **6. Verify Server is Running**
```bash
# Check PM2 status
pm2 status

# Test server response
curl http://localhost:5000

# Check logs
npm run logs
```

## **Expected Success Output:**

### **PM2 Status:**
```
pm2 status
┌─────┬──────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name         │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼──────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ olalaundry   │ default     │ 1.0.0   │ cluster │ XXXXX    │ Xs     │ 0    │ online    │ 0%       │ XXmb     │ root     │ disabled │
└─────┴──────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
```

### **Server Response:**
```bash
curl http://localhost:5000
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>OLA Laundry Master</title>
    ...
```

### **Logs:**
```bash
npm run logs
0|olalaundry | ✅ Connected to PostgreSQL database
0|olalaundry | 🚀 OLA Laundry Master server running on 0.0.0.0:5000
0|olalaundry | 🌐 Environment: production
0|olalaundry | 🔗 Domain: your-domain.com
0|olalaundry | ✅ Production server ready at https://your-domain.com
```

## **Troubleshooting:**

### **If Server Won't Start:**
```bash
# Check what's using the port
sudo lsof -i :5000

# Check for errors in logs
npm run logs | tail -20

# Try manual start to see errors
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" node dist/index.js
```

### **If Build Fails:**
```bash
# Check Node.js version
node --version

# If v18.x.x, update to v20:
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Try build again
npm run build
```

### **If PM2 Issues:**
```bash
# Reinstall PM2
npm uninstall -g pm2
npm install -g pm2

# Start fresh
pm2 startup
pm2 save
```

## **Final Verification:**

### **1. Server Health Check:**
```bash
curl -f http://localhost:5000 && echo "✅ Server OK" || echo "❌ Server Failed"
```

### **2. Application Features:**
```bash
# Test login page
curl http://localhost:5000/login

# Test API
curl http://localhost:5000/api/auth/user
```

### **3. External Access:**
```bash
# Test from outside (replace with your domain)
curl http://your-domain.com
```

## **Success Indicators:**
- ✅ PM2 shows "online" status
- ✅ curl returns HTML content
- ✅ Logs show "server running on 0.0.0.0:5000"
- ✅ No "EADDRINUSE" errors
- ✅ Application accessible from browser