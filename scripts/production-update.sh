#!/bin/bash

# OLA Laundry Master - Production Update Script
# Automated deployment of latest changes to production server

set -e

# Configuration
PRODUCTION_DIR="/var/www/olalaundry"
BACKUP_DIR="/var/www/backups"
LOG_FILE="/var/log/olalaundry/deployment.log"
SERVICE_NAME="olalaundry"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root or with sudo"
   exit 1
fi

# Create necessary directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log "🚀 Starting OLA Laundry Master production update..."

# Step 1: Create backup
BACKUP_NAME="olalaundry-backup-$(date +%Y%m%d-%H%M%S)"
log "📦 Creating backup: $BACKUP_NAME"

if [ -d "$PRODUCTION_DIR" ]; then
    cp -r "$PRODUCTION_DIR" "$BACKUP_DIR/$BACKUP_NAME"
    log "✅ Backup created successfully"
else
    log_warning "Production directory not found, skipping backup"
fi

# Step 2: Navigate to production directory
log "📁 Navigating to production directory"
cd "$PRODUCTION_DIR" || {
    log_error "Failed to navigate to production directory"
    exit 1
}

# Step 3: Pull latest changes
log "📥 Pulling latest changes from main branch"
git fetch origin
git pull origin main || {
    log_error "Failed to pull latest changes"
    exit 1
}

# Show latest commits
log "📋 Latest commits:"
git log --oneline -5

# Step 4: Install/update dependencies
log "📦 Installing/updating dependencies"
npm ci --production || {
    log_error "Failed to install dependencies"
    exit 1
}

# Step 5: Build application
log "🔨 Building application"
npm run build || {
    log_error "Failed to build application"
    exit 1
}

# Verify build output
if [ -d "dist" ] && [ -f "dist/index.js" ]; then
    log "✅ Build completed successfully"
else
    log_error "Build output not found"
    exit 1
fi

# Step 6: Update environment configuration
log "⚙️ Updating environment configuration"
if [ -f ".env.production" ]; then
    cp .env.production .env
    log "✅ Environment configuration updated"
else
    log_warning "Production environment file not found"
fi

# Step 7: Database migrations
log "🗄️ Running database migrations"
npm run db:push || log_warning "Database migration failed - may need manual intervention"

# Step 8: Restart PM2 services
log "🔄 Restarting PM2 services"
pm2 restart "$SERVICE_NAME" || {
    log_error "Failed to restart PM2 service"
    exit 1
}

# Wait for service to start
sleep 5

# Step 9: Verify deployment
log "✅ Verifying deployment"

# Check PM2 status
pm2 status "$SERVICE_NAME" || {
    log_error "PM2 service not running properly"
    exit 1
}

# Health check
log "🏥 Performing health check"
if curl -f -s http://localhost:5000/api/health > /dev/null; then
    log "✅ Health check passed"
else
    log_warning "Health check failed - application may still be starting"
fi

# Step 10: Update Nginx configuration if needed
log "🌐 Checking Nginx configuration"
if [ -f "nginx.conf" ]; then
    if ! cmp -s nginx.conf /etc/nginx/sites-available/www.olalaundry.com; then
        log "📝 Updating Nginx configuration"
        cp nginx.conf /etc/nginx/sites-available/www.olalaundry.com
        nginx -t && systemctl reload nginx
        log "✅ Nginx configuration updated"
    else
        log "✅ Nginx configuration is up to date"
    fi
fi

# Step 11: Cleanup old backups (keep last 5)
log "🧹 Cleaning up old backups"
cd "$BACKUP_DIR"
ls -t | tail -n +6 | xargs -r rm -rf
log "✅ Old backups cleaned up"

# Step 12: Final verification
log "🔍 Final verification"
cd "$PRODUCTION_DIR"

# Check application logs
log "📋 Recent application logs:"
pm2 logs "$SERVICE_NAME" --lines 10 --nostream

# Display deployment summary
log "🎉 Production update completed successfully!"
log "📊 Deployment Summary:"
log "   - Backup created: $BACKUP_NAME"
log "   - Latest commit: $(git log --oneline -1)"
log "   - Build status: ✅ Success"
log "   - Service status: $(pm2 jlist | jq -r '.[] | select(.name=="'$SERVICE_NAME'") | .pm2_env.status')"
log "   - Application URL: https://www.olalaundry.com"

# Save deployment info
echo "$(date): Deployment completed - $(git log --oneline -1)" >> /var/log/olalaundry/deployments.log

log "🌐 Your application is now updated and running at: https://www.olalaundry.com"
log "📝 Deployment log saved to: $LOG_FILE"

# Optional: Send notification (uncomment if you have notification setup)
# curl -X POST "your-webhook-url" -d "OLA Laundry production update completed successfully"

exit 0