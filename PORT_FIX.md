# 🔧 Port Configuration Fix

## **Issue Identified:**
- App is trying to start on port 3000 (causing EADDRINUSE error)
- Should be running on port 5000
- Port 3000 is already in use

## **Immediate Fix Commands:**

### **1. Kill All Processes on Both Ports**
```bash
# Kill processes on port 3000
sudo lsof -ti:3000 | xargs kill -9 2>/dev/null || true
pkill -f "node.*3000" 2>/dev/null || true

# Kill processes on port 5000
sudo lsof -ti:5000 | xargs kill -9 2>/dev/null || true
pkill -f "node.*5000" 2>/dev/null || true

# Kill all PM2 processes
pm2 delete all
pm2 kill
```

### **2. Set Correct Environment Variables**
```bash
# Set PORT to 5000 explicitly
export PORT=5000
export NODE_ENV=production
export HOST=0.0.0.0
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"

# Verify environment variables
echo "PORT: $PORT"
echo "NODE_ENV: $NODE_ENV"
```

### **3. Check What's Using the Ports**
```bash
# Check what's running on port 3000
sudo lsof -i :3000

# Check what's running on port 5000
sudo lsof -i :5000

# Check all listening ports
netstat -tulpn | grep LISTEN
```

### **4. Start Server with Explicit Port**
```bash
# Method 1: Using npm script
PORT=5000 NODE_ENV=production npm run start:prod

# Method 2: Direct node command
PORT=5000 NODE_ENV=production JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" node dist/index.js

# Method 3: Using nohup for background
nohup PORT=5000 NODE_ENV=production JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" node dist/index.js > app.log 2>&1 &
```

### **5. Test Server**
```bash
# Test on port 5000
curl http://localhost:5000

# Check if server is responding
curl -I http://localhost:5000

# Check logs
tail -f app.log
# or
npm run logs
```

## **Expected Success Output:**
```bash
curl http://localhost:5000
# Should return HTML content, not "Connection refused"

npm run logs
# Should show: "🚀 OLA Laundry Master server running on 0.0.0.0:5000"
```

## **If Port 3000 is Still Being Used:**

### **Find and Kill the Process:**
```bash
# Find what's using port 3000
sudo lsof -i :3000
# or
sudo netstat -tulpn | grep :3000

# Kill the specific process (replace PID with actual process ID)
sudo kill -9 PID_NUMBER
```

### **Permanent Fix - Update PM2 Config:**
```bash
# Edit ecosystem.config.js to ensure correct port
nano ecosystem.config.js

# Make sure it has:
# env_production: {
#   NODE_ENV: 'production',
#   PORT: 5000
# }
```

## **Verification Commands:**
```bash
# 1. Check server is running on correct port
curl http://localhost:5000

# 2. Check PM2 status
pm2 status

# 3. Check environment variables
pm2 env 0

# 4. Check logs for correct port message
npm run logs | grep "port\|PORT"
```