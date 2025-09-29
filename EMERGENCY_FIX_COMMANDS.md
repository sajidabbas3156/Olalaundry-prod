# 🚨 EMERGENCY PRODUCTION FIX - Copy & Paste Commands

## **Run these commands in your VPS terminal:**

### **1. Fix Git Repository Issue**
```bash
git config --global --add safe.directory /var/www/olalaundry
```

### **2. Pull Latest Code**
```bash
git pull origin main
```

### **3. Kill All Existing Processes**
```bash
pm2 delete all
pm2 kill
pkill -f "node"
```

### **4. Set Environment Variables**
```bash
export NODE_ENV=production
export PORT=5000
export HOST=0.0.0.0
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"
```

### **5. Clean Install Dependencies**
```bash
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

### **6. Build Application**
```bash
npm run build
```

### **7. Start Production Server**
```bash
npm run start:prod
```

### **8. Test Server**
```bash
curl http://localhost:5000
npm run logs
```

---

## **If Node.js Version Issues Persist:**

### **Update to Node.js v20:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
node --version
```

---

## **Alternative Manual Start (if PM2 fails):**
```bash
# Kill everything
pkill -f "node"

# Start manually
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" nohup node dist/index.js > app.log 2>&1 &

# Check if running
curl http://localhost:5000
tail -f app.log
```

---

## **Quick Test Commands:**
```bash
# Check if server is running
curl http://localhost:5000

# Check logs
npm run logs

# Check process status
pm2 status

# Check what's running on ports
netstat -tulpn | grep -E ":3000|:5000"
```

---

## **Expected Success Output:**
- ✅ `curl http://localhost:5000` should return HTML
- ✅ `npm run logs` should show "OLA Laundry Master server running"
- ✅ No "EADDRINUSE" errors
- ✅ Server running on port 5000 (not 3000)

---

## **If Still Having Issues:**
1. Check the logs: `npm run logs`
2. Verify environment variables: `printenv | grep -E "(NODE_ENV|PORT|JWT_SECRET)"`
3. Check if port is free: `netstat -tulpn | grep :5000`
4. Try manual start method above