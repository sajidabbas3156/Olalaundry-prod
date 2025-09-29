#!/bin/bash

# OLA Laundry Production Fix Script
echo "🔧 Fixing OLA Laundry Production Issues..."

# 1. Fix git repository ownership
echo "1. Fixing git repository ownership..."
git config --global --add safe.directory /var/www/olalaundry

# 2. Pull latest changes
echo "2. Pulling latest changes..."
git pull origin main

# 3. Kill existing processes
echo "3. Stopping existing processes..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true
pkill -f "node.*3000" 2>/dev/null || true
pkill -f "node.*5000" 2>/dev/null || true
pkill -f "node.*olalaundry" 2>/dev/null || true

# 4. Set environment variables
echo "4. Setting environment variables..."
export NODE_ENV=production
export PORT=5000
export HOST=0.0.0.0
export JWT_SECRET="OLA-LAUNDRY-PRODUCTION-SECRET-KEY-2024-SECURE-MINIMUM-32-CHARACTERS"

# 5. Clean install
echo "5. Clean installing dependencies..."
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps

# 6. Build application
echo "6. Building application..."
npm run build

# 7. Start production server
echo "7. Starting production server..."
npm run start:prod

# 8. Wait and test
echo "8. Testing server..."
sleep 5
curl -f http://localhost:5000 && echo "✅ Server is running!" || echo "❌ Server failed to start"

echo "🎉 Production fix complete!"
echo "Check logs with: npm run logs"
echo "Test URL: http://your-domain.com"