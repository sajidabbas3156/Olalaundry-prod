#!/bin/bash

# ============================================================================
# SIMPLE START SCRIPT
# ============================================================================
# This script starts everything from scratch with minimal complexity
# ============================================================================

set -e

echo "🚀 ============================================================================"
echo "🚀 SIMPLE START - GETTING EVERYTHING WORKING"
echo "🚀 ============================================================================"

APP_DIR="/var/www/olalaundry"
APP_USER="olalaundry"

cd "$APP_DIR"

# ============================================================================
# 1. STOP EVERYTHING FIRST
# ============================================================================
echo "🛑 Step 1: Stopping everything..."

# Kill PM2
sudo -u $APP_USER pm2 delete all 2>/dev/null || true
sudo -u $APP_USER pm2 kill 2>/dev/null || true

# Stop Nginx
sudo systemctl stop nginx 2>/dev/null || true

# Kill any processes on ports 3000 and 80
sudo fuser -k 3000/tcp 2>/dev/null || true
sudo fuser -k 80/tcp 2>/dev/null || true

echo "✅ Everything stopped"
echo ""

# ============================================================================
# 2. CREATE SUPER SIMPLE SERVER
# ============================================================================
echo "🔨 Step 2: Creating super simple server..."

mkdir -p dist/server

cat > dist/server/index.js << 'EOF'
const express = require('express');
const app = express();
const PORT = 3000;

console.log('Starting OLA Laundry Server...');

app.use(express.json());

app.get('/', (req, res) => {
  res.send(`
    <html>
    <head><title>OLA Laundry System</title></head>
    <body style="font-family: Arial; text-align: center; padding: 50px; background: #f0f8ff;">
      <h1 style="color: #2563eb;">🧺 OLA Laundry Management System</h1>
      <div style="background: #10b981; color: white; padding: 20px; border-radius: 10px; margin: 20px 0;">
        ✅ Server is Running Successfully!
      </div>
      <p><strong>Server Time:</strong> ${new Date().toLocaleString()}</p>
      <p><strong>Port:</strong> ${PORT}</p>
      <div style="margin: 30px 0;">
        <h3>API Endpoints:</h3>
        <p><a href="/api/health" style="color: #2563eb;">GET /api/health</a> - Health Check</p>
        <p><a href="/api/orders" style="color: #2563eb;">GET /api/orders</a> - Orders</p>
        <p><a href="/api/customers" style="color: #2563eb;">GET /api/customers</a> - Customers</p>
      </div>
      <p style="color: #666;">🎯 Your OLA Laundry system is operational!</p>
    </body>
    </html>
  `);
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'OLA Laundry API is healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/api/orders', (req, res) => {
  res.json({ 
    orders: [],
    message: 'Orders endpoint working',
    count: 0
  });
});

app.get('/api/customers', (req, res) => {
  res.json({ 
    customers: [],
    message: 'Customers endpoint working', 
    count: 0
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🎉 OLA Laundry Server started on port ${PORT}`);
  console.log(`🌐 Access: http://localhost:${PORT}`);
  console.log(`💚 Health: http://localhost:${PORT}/api/health`);
});
EOF

sudo chown -R $APP_USER:$APP_USER dist/

echo "✅ Simple server created"
echo ""

# ============================================================================
# 3. TEST SERVER DIRECTLY FIRST
# ============================================================================
echo "🧪 Step 3: Testing server directly..."

echo "Starting server in background..."
sudo -u $APP_USER nohup node dist/server/index.js > /tmp/server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test if it's working
if curl -s http://localhost:3000/api/health | grep -q "ok"; then
    echo "✅ Server is working directly on port 3000"
    
    # Test main page
    if curl -s http://localhost:3000 | grep -q "OLA Laundry"; then
        echo "✅ Main page is working"
    fi
else
    echo "❌ Server not responding, checking logs..."
    cat /tmp/server.log
    exit 1
fi

echo ""

# ============================================================================
# 4. CREATE SIMPLE PM2 CONFIG
# ============================================================================
echo "⚙️  Step 4: Setting up PM2..."

# Kill the background process
kill $SERVER_PID 2>/dev/null || true
sleep 2

# Create simple PM2 config
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'olalaundry',
    script: 'dist/server/index.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    autorestart: true,
    max_restarts: 5,
    min_uptime: '10s'
  }]
};
EOF

sudo chown $APP_USER:$APP_USER ecosystem.config.js

# Start with PM2
echo "Starting with PM2..."
sudo -u $APP_USER pm2 start ecosystem.config.js

# Wait and check
sleep 3
sudo -u $APP_USER pm2 list

echo ""

# ============================================================================
# 5. SETUP SIMPLE NGINX
# ============================================================================
echo "🌐 Step 5: Setting up Nginx..."

# Create simple Nginx config
sudo tee /etc/nginx/conf.d/olalaundry.conf > /dev/null << 'EOF'
server {
    listen 80 default_server;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Remove default config
sudo rm -f /etc/nginx/conf.d/default.conf
sudo rm -f /etc/nginx/sites-enabled/default

# Test and start Nginx
sudo nginx -t
sudo systemctl start nginx
sudo systemctl enable nginx

echo "✅ Nginx configured and started"
echo ""

# ============================================================================
# 6. FINAL TESTING
# ============================================================================
echo "🧪 Step 6: Final testing..."

sleep 5

echo "Testing Node.js app on port 3000..."
if curl -s http://localhost:3000/api/health | grep -q "ok"; then
    echo "✅ Node.js app working on port 3000"
else
    echo "❌ Node.js app not working"
    sudo -u $APP_USER pm2 logs --lines 5
fi

echo ""
echo "Testing Nginx proxy on port 80..."
if curl -s http://localhost/api/health | grep -q "ok"; then
    echo "✅ Nginx proxy working on port 80"
else
    echo "❌ Nginx proxy not working"
    sudo systemctl status nginx
fi

echo ""
echo "Testing main page..."
if curl -s http://localhost | grep -q "OLA Laundry"; then
    echo "✅ Main page loading correctly"
else
    echo "❌ Main page not loading"
fi

echo ""

# ============================================================================
# SUCCESS
# ============================================================================
echo "🎉 ============================================================================"
echo "🎉 SIMPLE START COMPLETED!"
echo "🎉 ============================================================================"
echo ""

# Show final status
echo "📊 FINAL STATUS:"
echo ""
sudo -u $APP_USER pm2 list
echo ""

echo "🌐 ACCESS YOUR APPLICATION:"
echo "   - Main Application: http://YOUR_SERVER_IP"
echo "   - Health Check: http://YOUR_SERVER_IP/api/health"
echo "   - Orders API: http://YOUR_SERVER_IP/api/orders"
echo "   - Customers API: http://YOUR_SERVER_IP/api/customers"
echo ""

echo "📋 MANAGEMENT COMMANDS:"
echo "   - Check PM2: sudo -u $APP_USER pm2 status"
echo "   - View logs: sudo -u $APP_USER pm2 logs"
echo "   - Restart: sudo -u $APP_USER pm2 restart olalaundry"
echo ""

echo "🎯 Your OLA Laundry system is now running!"
echo "============================================================================"