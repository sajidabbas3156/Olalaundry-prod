# 🔧 Node.js Version Fix for Production

## **Current Issue:**
- Your server has Node.js v18.20.8
- Some packages require Node.js v20+
- This is causing build and runtime issues

## **Solution Options:**

### **Option 1: Update Node.js to v20 (Recommended)**
```bash
# Install Node.js v20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show v10.x.x
```

### **Option 2: Use Node Version Manager (Alternative)**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

# Install and use Node.js v20
nvm install 20
nvm use 20
nvm alias default 20
```

### **Option 3: Force Install with Current Node.js (Quick Fix)**
```bash
# Use legacy peer deps to bypass version checks
npm install --legacy-peer-deps --force

# Set npm to ignore engine checks
npm config set engine-strict false
```

## **After Node.js Update, Run:**
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Build
npm run build

# Start
npm run start:prod
```

## **Verify Node.js Version:**
```bash
node --version
npm --version
which node
which npm
```

## **Expected Output:**
```
node --version
v20.x.x

npm --version  
v10.x.x
```