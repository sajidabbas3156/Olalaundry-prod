# 🚨 FINAL PRODUCTION FIX - Copy These Commands Exactly

## **Run these commands in your VPS terminal in order:**

### **1. Fix Git and Pull Latest Code**
```bash
git config --global --add safe.directory /var/www/olalaundry
git pull origin main
```

### **2. Complete Process Cleanup**
```bash
pm2 delete all
pm2 kill
pkill -f "node"
sudo lsof -ti:3000 | xargs kill -9 2>/dev/null || true
sudo lsof -ti:5000 | xargs kill -9 2>/dev/null || true
```

### **3. Set Environment Variables**
```bash
export NODE_ENV=production
export PORT=5000
export HOST=0.0.0.0
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"
```

### **4. Clean Install and Build**
```bash
rm -rf node_modules package-lock.json dist
npm install --legacy-peer-deps
npm run build
```

### **5. Start Production Server**
```bash
npm run start:prod
```

### **6. Test Server**
```bash
curl http://localhost:5000
npm run logs
```

---

## **Expected Success Output:**

### **After `npm run start:prod`:**
```
[PM2] Starting /var/www/olalaundry/ecosystem.config.js
[PM2] Done.
```

### **After `curl http://localhost:5000`:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>OLA Laundry Master</title>
    ...
```

### **After `npm run logs`:**
```
0|olalaundry | 🚀 OLA Laundry Master server running on 0.0.0.0:5000
0|olalaundry | 🌐 Environment: production
0|olalaundry | ✅ Production server ready
```

---

## **If You Get Errors:**

### **Node.js Version Error:**
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs
node --version
```

### **Still Port 3000 Error:**
```bash
sudo lsof -i :3000
sudo kill -9 [PID_FROM_ABOVE_COMMAND]
```

### **PM2 Won't Start:**
```bash
NODE_ENV=production PORT=5000 JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS" nohup node dist/index.js > app.log 2>&1 &
curl http://localhost:5000
tail -f app.log
```

---

## **✅ Success Checklist:**
- [ ] `git pull origin main` - No errors
- [ ] `npm run build` - Completes successfully
- [ ] `npm run start:prod` - Shows PM2 starting
- [ ] `curl http://localhost:5000` - Returns HTML
- [ ] `npm run logs` - Shows server running on port 5000
- [ ] Browser test: `http://your-domain.com` works

---

## **🎉 When Everything Works:**

Your OLA Laundry Master will be accessible at:
- **Homepage**: `http://your-domain.com`
- **Login**: `http://your-domain.com/login`
- **Customer App**: `http://your-domain.com/customer-app`
- **QR Order**: `http://your-domain.com/quick-order`
- **Admin Dashboard**: `http://your-domain.com/tenant/ola-laundry/dashboard`

**Demo Login**: `owner@laundrypro.bh` / `demo123`