# 🔧 Build Configuration Fix

## **Issues Fixed:**

### **1. Port Configuration**
- ✅ Fixed ecosystem.config.js to use PORT 5000 instead of 3000
- ✅ Added JWT_SECRET to PM2 environment

### **2. ES Module Issues**
The build errors are related to ES modules. Here's how to fix them:

## **Complete Fix Commands:**

### **1. Update Ecosystem Config (Already Fixed)**
The ecosystem.config.js now has the correct port:
```javascript
env_production: {
  NODE_ENV: 'production',
  PORT: 5000,  // Changed from 3000
  HOST: '0.0.0.0',
  JWT_SECRET: process.env.JWT_SECRET || 'OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS'
}
```

### **2. Clean Build Process**
```bash
# 1. Stop all processes
pm2 delete all
pm2 kill

# 2. Clean everything
rm -rf node_modules package-lock.json dist

# 3. Set environment variables
export NODE_ENV=production
export PORT=5000
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"

# 4. Install with legacy peer deps (for Node.js v18 compatibility)
npm install --legacy-peer-deps

# 5. Build with proper environment
NODE_ENV=production npm run build

# 6. Start production server
npm run start:prod
```

### **3. Alternative Build Method (if main build fails)**
```bash
# Skip Vite build and build server only
npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist

# Start manually
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" node dist/index.js
```

### **4. Manual Start (if PM2 continues to fail)**
```bash
# Start without PM2
nohup NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" node dist/index.js > app.log 2>&1 &

# Check if running
curl http://localhost:5000
tail -f app.log
```

## **Verification Steps:**

### **1. Check Build Output**
```bash
ls -la dist/
# Should contain index.js
```

### **2. Test Server**
```bash
curl http://localhost:5000
# Should return HTML, not connection refused
```

### **3. Check Logs**
```bash
npm run logs
# Should show: "🚀 OLA Laundry Master server running on 0.0.0.0:5000"
```

### **4. Check PM2 Status**
```bash
pm2 status
# Should show olalaundry as "online"
```

## **Expected Success Output:**
```
pm2 status
┌─────┬──────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id  │ name         │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├─────┼──────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0   │ olalaundry   │ default     │ 1.0.0   │ cluster │ 12345    │ 5s     │ 0    │ online    │ 0%       │ 50.0mb   │ root     │ disabled │
└─────┴──────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘

curl http://localhost:5000
<!DOCTYPE html>
<html lang="en">
...
```

## **If Still Having Issues:**

### **Check Node.js Version:**
```bash
node --version
# If still v18.x.x, update to v20:
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
```

### **Force Install Dependencies:**
```bash
npm install --legacy-peer-deps --force
npm config set engine-strict false
```