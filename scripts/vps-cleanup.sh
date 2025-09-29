#!/bin/bash

# ============================================================================
# VPS CLEANUP SCRIPT - Complete System Reset
# ============================================================================
# This script completely cleans your VPS and prepares it for fresh deployment
# WARNING: This will remove ALL existing applications and configurations
# ============================================================================

set -e

echo "🧹 ============================================================================"
echo "🧹 VPS CLEANUP SCRIPT - COMPLETE SYSTEM RESET"
echo "🧹 ============================================================================"
echo "⚠️  WARNING: This will remove ALL existing applications and configurations!"
echo "⚠️  This action is IRREVERSIBLE!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed with complete VPS cleanup? (type 'YES' to confirm): " confirm
if [ "$confirm" != "YES" ]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo ""
echo "🚀 Starting VPS cleanup process..."
echo ""

# ============================================================================
# 1. STOP ALL SERVICES
# ============================================================================
echo "🛑 Step 1: Stopping all services..."

# Stop PM2 processes
if command -v pm2 &> /dev/null; then
    echo "   - Stopping PM2 processes..."
    pm2 kill || true
    pm2 delete all || true
fi

# Stop Nginx
if systemctl is-active --quiet nginx; then
    echo "   - Stopping Nginx..."
    sudo systemctl stop nginx || true
    sudo systemctl disable nginx || true
fi

# Stop Apache if running
if systemctl is-active --quiet httpd; then
    echo "   - Stopping Apache..."
    sudo systemctl stop httpd || true
    sudo systemctl disable httpd || true
fi

# Stop MySQL/MariaDB if running
if systemctl is-active --quiet mysqld; then
    echo "   - Stopping MySQL..."
    sudo systemctl stop mysqld || true
    sudo systemctl disable mysqld || true
fi

if systemctl is-active --quiet mariadb; then
    echo "   - Stopping MariaDB..."
    sudo systemctl stop mariadb || true
    sudo systemctl disable mariadb || true
fi

echo "✅ All services stopped."
echo ""

# ============================================================================
# 2. REMOVE APPLICATION DIRECTORIES
# ============================================================================
echo "🗂️  Step 2: Removing application directories..."

# Common application directories
DIRS_TO_REMOVE=(
    "/var/www/olalaundry"
    "/var/www/html"
    "/var/www/ola-laundry"
    "/var/www/laundry"
    "/opt/olalaundry"
    "/home/*/olalaundry"
    "/root/olalaundry"
)

for dir in "${DIRS_TO_REMOVE[@]}"; do
    if [ -d "$dir" ]; then
        echo "   - Removing $dir..."
        sudo rm -rf "$dir" || true
    fi
done

echo "✅ Application directories removed."
echo ""

# ============================================================================
# 3. REMOVE NODE.JS AND NPM
# ============================================================================
echo "📦 Step 3: Removing Node.js and NPM..."

# Remove Node.js installed via package manager
sudo dnf remove -y nodejs npm || true
sudo yum remove -y nodejs npm || true

# Remove Node.js installed via NodeSource
if [ -f "/etc/yum.repos.d/nodesource-el8.repo" ]; then
    sudo rm -f /etc/yum.repos.d/nodesource-el*.repo
fi

# Remove NVM if installed
if [ -d "$HOME/.nvm" ]; then
    echo "   - Removing NVM..."
    rm -rf "$HOME/.nvm"
fi

# Remove global npm packages directory
if [ -d "$HOME/.npm" ]; then
    echo "   - Removing npm cache..."
    rm -rf "$HOME/.npm"
fi

# Remove node_modules in common locations
find /var/www -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find /opt -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true

echo "✅ Node.js and NPM removed."
echo ""

# ============================================================================
# 4. REMOVE PM2
# ============================================================================
echo "⚙️  Step 4: Removing PM2..."

# Remove PM2 globally
npm uninstall -g pm2 2>/dev/null || true

# Remove PM2 directories
rm -rf "$HOME/.pm2" 2>/dev/null || true
sudo rm -rf /root/.pm2 2>/dev/null || true

echo "✅ PM2 removed."
echo ""

# ============================================================================
# 5. CLEAN NGINX CONFIGURATION
# ============================================================================
echo "🌐 Step 5: Cleaning Nginx configuration..."

if command -v nginx &> /dev/null; then
    # Remove custom configurations
    sudo rm -f /etc/nginx/conf.d/olalaundry.conf || true
    sudo rm -f /etc/nginx/conf.d/laundry.conf || true
    sudo rm -f /etc/nginx/sites-available/olalaundry || true
    sudo rm -f /etc/nginx/sites-enabled/olalaundry || true
    
    # Reset to default configuration
    if [ -f "/etc/nginx/nginx.conf.backup" ]; then
        sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf || true
    fi
fi

echo "✅ Nginx configuration cleaned."
echo ""

# ============================================================================
# 6. CLEAN FIREWALL RULES
# ============================================================================
echo "🔥 Step 6: Cleaning firewall rules..."

if command -v firewall-cmd &> /dev/null; then
    # Remove custom ports
    sudo firewall-cmd --permanent --remove-port=3000/tcp 2>/dev/null || true
    sudo firewall-cmd --permanent --remove-port=5000/tcp 2>/dev/null || true
    sudo firewall-cmd --permanent --remove-port=8080/tcp 2>/dev/null || true
    sudo firewall-cmd --reload 2>/dev/null || true
fi

echo "✅ Firewall rules cleaned."
echo ""

# ============================================================================
# 7. CLEAN DATABASES
# ============================================================================
echo "🗄️  Step 7: Cleaning databases..."

# Remove SQLite databases
find /var/www -name "*.db" -type f -delete 2>/dev/null || true
find /opt -name "*.db" -type f -delete 2>/dev/null || true
find /home -name "*.db" -type f -delete 2>/dev/null || true

echo "✅ Databases cleaned."
echo ""

# ============================================================================
# 8. CLEAN LOGS
# ============================================================================
echo "📝 Step 8: Cleaning logs..."

# Clean application logs
sudo rm -rf /var/log/olalaundry* 2>/dev/null || true
sudo rm -rf /var/log/pm2* 2>/dev/null || true

# Clean nginx logs (keep system logs)
sudo truncate -s 0 /var/log/nginx/access.log 2>/dev/null || true
sudo truncate -s 0 /var/log/nginx/error.log 2>/dev/null || true

echo "✅ Logs cleaned."
echo ""

# ============================================================================
# 9. CLEAN TEMPORARY FILES
# ============================================================================
echo "🧽 Step 9: Cleaning temporary files..."

# Clean package manager cache
sudo dnf clean all 2>/dev/null || true
sudo yum clean all 2>/dev/null || true

# Clean temporary directories
sudo rm -rf /tmp/npm-* 2>/dev/null || true
sudo rm -rf /tmp/node-* 2>/dev/null || true

echo "✅ Temporary files cleaned."
echo ""

# ============================================================================
# 10. UPDATE SYSTEM
# ============================================================================
echo "🔄 Step 10: Updating system packages..."

# Update package lists and upgrade system
if command -v dnf &> /dev/null; then
    sudo dnf update -y
elif command -v yum &> /dev/null; then
    sudo yum update -y
fi

echo "✅ System updated."
echo ""

# ============================================================================
# CLEANUP COMPLETE
# ============================================================================
echo "🎉 ============================================================================"
echo "🎉 VPS CLEANUP COMPLETED SUCCESSFULLY!"
echo "🎉 ============================================================================"
echo ""
echo "✅ All services stopped"
echo "✅ Application directories removed"
echo "✅ Node.js and NPM removed"
echo "✅ PM2 removed"
echo "✅ Nginx configuration cleaned"
echo "✅ Firewall rules cleaned"
echo "✅ Databases cleaned"
echo "✅ Logs cleaned"
echo "✅ Temporary files cleaned"
echo "✅ System updated"
echo ""
echo "🚀 Your VPS is now clean and ready for fresh deployment!"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Run the fresh deployment script"
echo "2. Clone the new repository"
echo "3. Deploy the application"
echo ""
echo "🔗 Repository: https://github.com/sajidabbas3156/Olalaundry-prod.git"
echo ""
echo "============================================================================"