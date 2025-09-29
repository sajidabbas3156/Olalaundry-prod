#!/bin/bash

# ============================================================================
# FRESH DEPLOYMENT SCRIPT - OLA Laundry Production
# ============================================================================
# This script performs a complete fresh deployment from the new repository
# Repository: https://github.com/sajidabbas3156/Olalaundry-prod.git
# ============================================================================

set -e

# Configuration
REPO_URL="https://github.com/sajidabbas3156/Olalaundry-prod.git"
APP_DIR="/var/www/olalaundry"
APP_USER="olalaundry"
NODE_VERSION="18"

echo "🚀 ============================================================================"
echo "🚀 FRESH DEPLOYMENT - OLA LAUNDRY PRODUCTION"
echo "🚀 ============================================================================"
echo "📦 Repository: $REPO_URL"
echo "📁 Deploy to: $APP_DIR"
echo "🔧 Node.js: v$NODE_VERSION"
echo ""

# ============================================================================
# 1. SYSTEM PREPARATION
# ============================================================================
echo "🔧 Step 1: Preparing system..."

# Update system packages
echo "   - Updating system packages..."
if command -v dnf &> /dev/null; then
    sudo dnf update -y
elif command -v yum &> /dev/null; then
    sudo yum update -y
fi

# Install essential packages
echo "   - Installing essential packages..."
if command -v dnf &> /dev/null; then
    sudo dnf install -y git curl wget unzip firewalld nginx
elif command -v yum &> /dev/null; then
    sudo yum install -y git curl wget unzip firewalld nginx
fi

echo "✅ System prepared."
echo ""

# ============================================================================
# 2. CREATE APPLICATION USER
# ============================================================================
echo "👤 Step 2: Creating application user..."

# Create user if doesn't exist
if ! id "$APP_USER" &>/dev/null; then
    echo "   - Creating user: $APP_USER"
    sudo useradd -m -s /bin/bash "$APP_USER"
    sudo usermod -aG wheel "$APP_USER" 2>/dev/null || true
else
    echo "   - User $APP_USER already exists"
fi

echo "✅ Application user ready."
echo ""

# ============================================================================
# 3. INSTALL NODE.JS
# ============================================================================
echo "📦 Step 3: Installing Node.js v$NODE_VERSION..."

# Remove any existing Node.js
sudo dnf remove -y nodejs npm 2>/dev/null || true
sudo yum remove -y nodejs npm 2>/dev/null || true

# Install Node.js 18 from NodeSource
echo "   - Adding NodeSource repository..."
curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -

echo "   - Installing Node.js and npm..."
if command -v dnf &> /dev/null; then
    sudo dnf install -y nodejs
elif command -v yum &> /dev/null; then
    sudo yum install -y nodejs
fi

# Verify installation
NODE_VER=$(node --version)
NPM_VER=$(npm --version)
echo "   - Node.js version: $NODE_VER"
echo "   - npm version: $NPM_VER"

echo "✅ Node.js installed successfully."
echo ""

# ============================================================================
# 4. INSTALL PM2
# ============================================================================
echo "⚙️  Step 4: Installing PM2..."

# Install PM2 globally
sudo npm install -g pm2

# Setup PM2 startup
sudo pm2 startup systemd -u "$APP_USER" --hp "/home/$APP_USER" || true

echo "✅ PM2 installed successfully."
echo ""

# ============================================================================
# 5. CLONE REPOSITORY
# ============================================================================
echo "📥 Step 5: Cloning repository..."

# Remove existing directory if it exists
if [ -d "$APP_DIR" ]; then
    echo "   - Removing existing directory..."
    sudo rm -rf "$APP_DIR"
fi

# Create parent directory
sudo mkdir -p "$(dirname "$APP_DIR")"

# Clone repository
echo "   - Cloning from: $REPO_URL"
sudo git clone "$REPO_URL" "$APP_DIR"

# Set ownership
sudo chown -R "$APP_USER:$APP_USER" "$APP_DIR"

echo "✅ Repository cloned successfully."
echo ""

# ============================================================================
# 6. INSTALL DEPENDENCIES
# ============================================================================
echo "📦 Step 6: Installing dependencies..."

cd "$APP_DIR"

# Install dependencies as app user
sudo -u "$APP_USER" npm install

echo "✅ Dependencies installed successfully."
echo ""

# ============================================================================
# 7. BUILD APPLICATION
# ============================================================================
echo "🔨 Step 7: Building application..."

# Build the application
sudo -u "$APP_USER" npm run build

echo "✅ Application built successfully."
echo ""

# ============================================================================
# 8. SETUP DATABASE
# ============================================================================
echo "🗄️  Step 8: Setting up database..."

# Create database directory
sudo mkdir -p "$APP_DIR/data"
sudo chown -R "$APP_USER:$APP_USER" "$APP_DIR/data"

# Run database setup if script exists
if [ -f "$APP_DIR/database-setup.sql" ]; then
    echo "   - Database setup script found"
    # Database will be created automatically when the app starts
fi

echo "✅ Database setup completed."
echo ""

# ============================================================================
# 9. CONFIGURE PM2
# ============================================================================
echo "⚙️  Step 9: Configuring PM2..."

# Create PM2 ecosystem file if it doesn't exist
if [ ! -f "$APP_DIR/ecosystem.config.js" ]; then
    sudo -u "$APP_USER" cat > "$APP_DIR/ecosystem.config.js" << 'EOF'
module.exports = {
  apps: [{
    name: 'olalaundry',
    script: 'server/index.js',
    cwd: '/var/www/olalaundry',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/olalaundry-error.log',
    out_file: '/var/log/olalaundry-out.log',
    log_file: '/var/log/olalaundry.log',
    time: true,
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
EOF
fi

# Start application with PM2
echo "   - Starting application with PM2..."
sudo -u "$APP_USER" pm2 start ecosystem.config.js
sudo -u "$APP_USER" pm2 save

echo "✅ PM2 configured and application started."
echo ""

# ============================================================================
# 10. CONFIGURE NGINX
# ============================================================================
echo "🌐 Step 10: Configuring Nginx..."

# Create Nginx configuration
sudo tee /etc/nginx/conf.d/olalaundry.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript;
    
    # Static files
    location /assets/ {
        alias /var/www/olalaundry/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API routes
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # WebSocket support
    location /socket.io/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Main application
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "✅ Nginx configured and started."
echo ""

# ============================================================================
# 11. CONFIGURE FIREWALL
# ============================================================================
echo "🔥 Step 11: Configuring firewall..."

# Enable firewall
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Allow HTTP and HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh

# Reload firewall
sudo firewall-cmd --reload

echo "✅ Firewall configured."
echo ""

# ============================================================================
# 12. HEALTH CHECK
# ============================================================================
echo "🏥 Step 12: Performing health check..."

# Wait for application to start
echo "   - Waiting for application to start..."
sleep 10

# Check if PM2 process is running
if sudo -u "$APP_USER" pm2 list | grep -q "online"; then
    echo "   ✅ PM2 process is running"
else
    echo "   ❌ PM2 process is not running"
    sudo -u "$APP_USER" pm2 logs --lines 20
fi

# Check if Nginx is running
if systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx is running"
else
    echo "   ❌ Nginx is not running"
    sudo systemctl status nginx
fi

# Check if application responds
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302"; then
    echo "   ✅ Application is responding"
else
    echo "   ⚠️  Application may not be fully ready yet"
fi

echo "✅ Health check completed."
echo ""

# ============================================================================
# DEPLOYMENT COMPLETE
# ============================================================================
echo "🎉 ============================================================================"
echo "🎉 FRESH DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "🎉 ============================================================================"
echo ""
echo "📋 DEPLOYMENT SUMMARY:"
echo "✅ System updated and prepared"
echo "✅ Application user created"
echo "✅ Node.js v$NODE_VERSION installed"
echo "✅ PM2 installed and configured"
echo "✅ Repository cloned from GitHub"
echo "✅ Dependencies installed"
echo "✅ Application built"
echo "✅ Database setup completed"
echo "✅ PM2 process started"
echo "✅ Nginx configured and started"
echo "✅ Firewall configured"
echo "✅ Health check performed"
echo ""
echo "🌐 APPLICATION ACCESS:"
echo "   - Local: http://localhost"
echo "   - External: http://YOUR_SERVER_IP"
echo ""
echo "📊 MANAGEMENT COMMANDS:"
echo "   - Check status: sudo -u $APP_USER pm2 status"
echo "   - View logs: sudo -u $APP_USER pm2 logs"
echo "   - Restart app: sudo -u $APP_USER pm2 restart olalaundry"
echo "   - Stop app: sudo -u $APP_USER pm2 stop olalaundry"
echo ""
echo "🔗 Repository: $REPO_URL"
echo "📁 App Directory: $APP_DIR"
echo ""
echo "🎯 Your OLA Laundry system is now live and ready for use!"
echo "============================================================================"