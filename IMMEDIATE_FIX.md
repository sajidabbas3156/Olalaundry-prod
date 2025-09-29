# 🚨 IMMEDIATE FIX - Copy These Commands Exactly

## **Your Issues:**
1. ❌ Vite command not found (missing dev dependencies)
2. ❌ Git merge conflicts (local changes)
3. ❌ Build failing (no dist folder created)
4. ❌ Server can't start (no built files)

## **EXACT FIX COMMANDS - Copy & Paste:**

### **1. Fix Git Conflicts (Force Pull)**
```bash
cd /var/www/olalaundry
git reset --hard HEAD
git clean -fd
git pull origin main
```

### **2. Complete Process Cleanup**
```bash
pm2 delete all
pm2 kill
pkill -f "node"
```

### **3. Install ALL Dependencies (Including Dev)**
```bash
rm -rf node_modules package-lock.json dist
npm install
```

### **4. Set Environment Variables**
```bash
export NODE_ENV=production
export PORT=5000
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"
```

### **5. Build Application**
```bash
npm run build
```

### **6. Verify Build Output**
```bash
ls -la dist/
```

### **7. Start Server**
```bash
npm run start:prod
```

### **8. Test Server**
```bash
curl http://localhost:5000
npm run logs
```

---

## **If Build Still Fails, Use Manual Build:**

### **Manual Build Method:**
```bash
# Create dist directory
mkdir -p dist

# Build server only (skip vite for now)
npx esbuild server/index.ts --platform=node --packages=external --bundle --format=esm --outdir=dist

# Start manually
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" nohup node dist/index.js > app.log 2>&1 &

# Test
curl http://localhost:5000
tail -f app.log
```

---

## **Alternative: Skip Build, Use Development Mode:**

### **If All Else Fails:**
```bash
# Install tsx for TypeScript execution
npm install -g tsx

# Run directly from TypeScript
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" nohup tsx server/index.ts > app.log 2>&1 &

# Test
curl http://localhost:5000
tail -f app.log
```

---

## **Expected Success Output:**

### **After `npm run build`:**
```
✓ built in 1.23s
dist/index.js created
```

### **After `ls -la dist/`:**
```
-rw-r--r-- 1 root root 123456 Sep 29 05:45 index.js
```

### **After `curl http://localhost:5000`:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>OLA Laundry Master</title>
    ...
```

### **After `npm run logs`:**
```
0|olalaundry | 🚀 OLA Laundry Master server running on 0.0.0.0:5000
0|olalaundry | ✅ Production server ready
```

---

## **Quick Verification Commands:**
```bash
# Check if vite is installed
npx vite --version

# Check if build files exist
ls -la dist/

# Check what's running on port 5000
sudo lsof -i :5000

# Check environment variables
echo $NODE_ENV $PORT $JWT_SECRET
```