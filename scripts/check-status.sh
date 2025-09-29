#!/bin/bash

# ============================================================================
# CHECK STATUS SCRIPT
# ============================================================================
# This script checks the current status of all services
# ============================================================================

echo "🔍 ============================================================================"
echo "🔍 CHECKING CURRENT STATUS"
echo "🔍 ============================================================================"

APP_DIR="/var/www/olalaundry"
APP_USER="olalaundry"

# ============================================================================
# 1. CHECK PM2 STATUS
# ============================================================================
echo "📊 Step 1: Checking PM2 status..."
echo ""
sudo -u $APP_USER pm2 list
echo ""

# ============================================================================
# 2. CHECK PROCESSES AND PORTS
# ============================================================================
echo "🌐 Step 2: Checking ports and processes..."
echo ""
echo "Processes on port 3000:"
sudo netstat -tlnp | grep :3000 || echo "No process on port 3000"
echo ""
echo "Processes on port 80:"
sudo netstat -tlnp | grep :80 || echo "No process on port 80"
echo ""

# ============================================================================
# 3. CHECK NGINX STATUS
# ============================================================================
echo "🌐 Step 3: Checking Nginx status..."
echo ""
sudo systemctl status nginx --no-pager -l
echo ""

# ============================================================================
# 4. CHECK NGINX CONFIGURATION
# ============================================================================
echo "📝 Step 4: Checking Nginx configuration..."
echo ""
echo "Nginx config test:"
sudo nginx -t
echo ""
echo "Active Nginx configs:"
ls -la /etc/nginx/conf.d/
echo ""
if [ -f "/etc/nginx/conf.d/olalaundry.conf" ]; then
    echo "OLA Laundry Nginx config:"
    cat /etc/nginx/conf.d/olalaundry.conf
else
    echo "❌ OLA Laundry Nginx config not found"
fi
echo ""

# ============================================================================
# 5. TEST DIRECT ACCESS
# ============================================================================
echo "🧪 Step 5: Testing direct access..."
echo ""

echo "Testing Node.js app directly on port 3000:"
curl -v http://localhost:3000/ 2>&1 | head -20
echo ""

echo "Testing health endpoint on port 3000:"
curl -v http://localhost:3000/api/health 2>&1 | head -10
echo ""

echo "Testing through Nginx on port 80:"
curl -v http://localhost/ 2>&1 | head -20
echo ""

# ============================================================================
# 6. CHECK LOGS
# ============================================================================
echo "📝 Step 6: Checking logs..."
echo ""

echo "PM2 logs (last 10 lines):"
sudo -u $APP_USER pm2 logs --lines 10
echo ""

echo "Nginx error logs (last 10 lines):"
sudo tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx error logs"
echo ""

echo "System journal for Nginx (last 5 entries):"
sudo journalctl -u nginx --no-pager -n 5
echo ""

# ============================================================================
# 7. CHECK FILES
# ============================================================================
echo "📁 Step 7: Checking files..."
echo ""

cd $APP_DIR

echo "Server file exists:"
ls -la dist/server/index.js 2>/dev/null || echo "❌ Server file missing"
echo ""

echo "Ecosystem config exists:"
ls -la ecosystem.config.js 2>/dev/null || echo "❌ Ecosystem config missing"
echo ""

echo "Package.json type:"
grep -i "type" package.json || echo "No type specified in package.json"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "📋 ============================================================================"
echo "📋 STATUS SUMMARY"
echo "📋 ============================================================================"
echo ""

# Check if PM2 process is running
if sudo -u $APP_USER pm2 list | grep -q "online"; then
    echo "✅ PM2 process is running"
else
    echo "❌ PM2 process is not running"
fi

# Check if port 3000 is listening
if sudo netstat -tlnp | grep -q ":3000"; then
    echo "✅ Port 3000 is listening"
else
    echo "❌ Port 3000 is not listening"
fi

# Check if Nginx is running
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi

# Check if port 80 is listening
if sudo netstat -tlnp | grep -q ":80"; then
    echo "✅ Port 80 is listening"
else
    echo "❌ Port 80 is not listening"
fi

echo ""
echo "🎯 NEXT STEPS:"
echo ""

if ! sudo -u $APP_USER pm2 list | grep -q "online"; then
    echo "1. Start PM2 process: sudo -u $APP_USER pm2 start ecosystem.config.js"
fi

if ! sudo systemctl is-active --quiet nginx; then
    echo "2. Start Nginx: sudo systemctl start nginx"
fi

if ! sudo netstat -tlnp | grep -q ":3000"; then
    echo "3. Check server file and start manually: node dist/server/index.js"
fi

echo ""
echo "🔧 TROUBLESHOOTING COMMANDS:"
echo "- Restart PM2: sudo -u $APP_USER pm2 restart olalaundry"
echo "- Restart Nginx: sudo systemctl restart nginx"
echo "- View PM2 logs: sudo -u $APP_USER pm2 logs"
echo "- View Nginx logs: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "============================================================================"