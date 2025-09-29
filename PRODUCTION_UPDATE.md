# 🚀 OLA Laundry Master - Production Update Guide

## 📋 Latest Changes Summary

### ✅ Recent Updates (September 29, 2025)
- ✅ **Security Fixes**: All duplicate function declarations resolved
- ✅ **TypeScript Errors**: Comprehensive type fixes applied
- ✅ **GitHub Actions**: Updated to latest versions (v4)
- ✅ **Authentication**: Enhanced auth system with proper role management
- ✅ **API Responses**: Fixed type safety for all API endpoints
- ✅ **Build System**: Zero compilation errors, production-ready
- ✅ **Dependencies**: Security updates merged from dependabot

## 🖥️ Production Update Steps

### 1. **Pre-Update Backup**
```bash
# SSH into your production server
ssh root@159.198.32.97

# Create backup of current version
cd /var/www/olalaundry
cp -r . ../olalaundry-backup-$(date +%Y%m%d-%H%M%S)

# Backup database (if using PostgreSQL)
pg_dump ola_laundry_production > ../backup_$(date +%Y%m%d).sql
```

### 2. **Pull Latest Changes**
```bash
# Navigate to application directory
cd /var/www/olalaundry

# Fetch latest changes from main branch
git fetch origin
git pull origin main

# Verify we have the latest commit
git log --oneline -5
```

### 3. **Install Dependencies**
```bash
# Install/update dependencies
npm ci --production

# Install any new dependencies
npm install express-rate-limit --save
```

### 4. **Build Application**
```bash
# Build the updated application
npm run build

# Verify build completed successfully
ls -la dist/
```

### 5. **Update Environment Configuration**
```bash
# Ensure production environment is properly configured
cp .env.production .env

# Update any new environment variables if needed
nano .env
```

### 6. **Database Updates**
```bash
# Run any pending database migrations
npm run db:push

# Verify database schema is up to date
npm run db:studio
```

### 7. **Restart Application**
```bash
# Restart PM2 processes
pm2 restart olalaundry

# Check application status
pm2 status
pm2 logs olalaundry --lines 50
```

### 8. **Verify Deployment**
```bash
# Check if application is running
curl -I http://localhost:5000

# Check application health
curl http://localhost:5000/api/health

# Verify domain access
curl -I https://www.olalaundry.com
```

## 🔧 Quick Update Script

Create and run this script for automated update:

```bash
#!/bin/bash
# quick-update.sh

set -e

echo "🚀 Starting OLA Laundry production update..."

# Backup
echo "📦 Creating backup..."
cp -r /var/www/olalaundry /var/www/olalaundry-backup-$(date +%Y%m%d-%H%M%S)

# Update code
echo "📥 Pulling latest changes..."
cd /var/www/olalaundry
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --production

# Build application
echo "🔨 Building application..."
npm run build

# Update database
echo "🗄️ Updating database..."
npm run db:push

# Restart services
echo "🔄 Restarting services..."
pm2 restart olalaundry

# Verify
echo "✅ Verifying deployment..."
sleep 5
pm2 status
curl -f http://localhost:5000/api/health || echo "⚠️ Health check failed"

echo "🎉 Production update completed!"
echo "🌐 Application available at: https://www.olalaundry.com"
```

## 🚨 Rollback Procedure (If Needed)

If the update causes issues:

```bash
# Stop current application
pm2 stop olalaundry

# Restore from backup
cd /var/www
rm -rf olalaundry
mv olalaundry-backup-YYYYMMDD-HHMMSS olalaundry

# Restore database (if needed)
psql ola_laundry_production < backup_YYYYMMDD.sql

# Restart application
cd olalaundry
pm2 start ecosystem.config.js

# Verify rollback
pm2 status
curl -f http://localhost:5000/api/health
```

## 📊 Post-Update Verification

### Application Health Checks
- [ ] Application starts without errors
- [ ] Database connections working
- [ ] API endpoints responding
- [ ] Authentication system functional
- [ ] Mobile apps accessible
- [ ] Admin dashboard working

### Performance Checks
- [ ] Response times acceptable
- [ ] Memory usage normal
- [ ] CPU usage stable
- [ ] No memory leaks detected

### Security Verification
- [ ] HTTPS working properly
- [ ] Authentication required for protected routes
- [ ] Demo token restricted to development only
- [ ] CORS properly configured

## 🔗 Important URLs

- **Production Site**: https://www.olalaundry.com
- **Admin Dashboard**: https://www.olalaundry.com/admin
- **Customer App**: https://www.olalaundry.com/customer
- **API Health**: https://www.olalaundry.com/api/health

## 📞 Support

If you encounter issues during the update:

1. Check PM2 logs: `pm2 logs olalaundry`
2. Check Nginx logs: `tail -f /var/log/nginx/error.log`
3. Check application logs: `tail -f /var/log/olalaundry/error.log`
4. Verify environment variables: `pm2 env olalaundry`

## 🎯 Next Steps

After successful update:
- [ ] Monitor application for 24 hours
- [ ] Update documentation if needed
- [ ] Schedule regular backups
- [ ] Plan next maintenance window