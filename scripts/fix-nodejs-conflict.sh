#!/bin/bash

# ============================================================================
# FIX NODE.JS CONFLICT SCRIPT
# ============================================================================
# This script fixes Node.js package conflicts on AlmaLinux
# ============================================================================

set -e

echo "🔧 ============================================================================"
echo "🔧 FIXING NODE.JS PACKAGE CONFLICTS"
echo "🔧 ============================================================================"

# 1. Remove all existing Node.js packages completely
echo "🗑️  Step 1: Removing all existing Node.js packages..."

# Stop any running Node.js processes
sudo pkill -f node || true
sudo pkill -f npm || true

# Remove all Node.js related packages with force
echo "   - Removing nodejs packages..."
sudo dnf remove -y nodejs* npm* 2>/dev/null || true
sudo yum remove -y nodejs* npm* 2>/dev/null || true

# Remove with --allowerasing to handle conflicts
echo "   - Force removing with --allowerasing..."
sudo dnf remove -y --allowerasing nodejs nodejs-full-i18n nodejs-libs nodejs-docs 2>/dev/null || true

# Clean package cache
echo "   - Cleaning package cache..."
sudo dnf clean all
sudo rm -rf /var/cache/dnf/*

echo "✅ All Node.js packages removed."
echo ""

# 2. Remove any existing NodeSource repositories
echo "🗂️  Step 2: Cleaning NodeSource repositories..."

# Remove NodeSource repo files
sudo rm -f /etc/yum.repos.d/nodesource*.repo
sudo rm -f /etc/yum.repos.d/nodejs*.repo

# Remove GPG keys
sudo rpm -e --allmatches gpg-pubkey-* 2>/dev/null || true

echo "✅ NodeSource repositories cleaned."
echo ""

# 3. Update system
echo "🔄 Step 3: Updating system..."
sudo dnf update -y

echo "✅ System updated."
echo ""

# 4. Install Node.js 18 fresh
echo "📦 Step 4: Installing Node.js 18 fresh..."

# Add NodeSource repository
echo "   - Adding NodeSource repository..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -

# Install Node.js
echo "   - Installing Node.js..."
sudo dnf install -y nodejs

# Verify installation
NODE_VER=$(node --version 2>/dev/null || echo "Not installed")
NPM_VER=$(npm --version 2>/dev/null || echo "Not installed")

echo "   - Node.js version: $NODE_VER"
echo "   - npm version: $NPM_VER"

if [[ "$NODE_VER" == "Not installed" ]]; then
    echo "❌ Node.js installation failed!"
    exit 1
fi

echo "✅ Node.js installed successfully."
echo ""

# 5. Install PM2
echo "⚙️  Step 5: Installing PM2..."
sudo npm install -g pm2

echo "✅ PM2 installed successfully."
echo ""

echo "🎉 ============================================================================"
echo "🎉 NODE.JS CONFLICT FIXED SUCCESSFULLY!"
echo "🎉 ============================================================================"
echo ""
echo "✅ All conflicting packages removed"
echo "✅ NodeSource repository cleaned and re-added"
echo "✅ Node.js v18 installed fresh"
echo "✅ PM2 installed"
echo ""
echo "📋 VERSIONS:"
echo "   - Node.js: $(node --version)"
echo "   - npm: $(npm --version)"
echo "   - PM2: $(pm2 --version)"
echo ""
echo "🚀 You can now run the fresh deployment script!"
echo "============================================================================"