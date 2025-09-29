# OLA Laundry Master - Login Credentials & Features

## 🚀 Application Access

**Live Application URL**: [https://5000--019993cb-f343-7a2f-be58-7e85aa856954.eu-central-1-01.gitpod.dev](https://5000--019993cb-f343-7a2f-be58-7e85aa856954.eu-central-1-01.gitpod.dev)

## 🔐 Demo Login Credentials

All demo accounts use the password: **`demo123`**

### Admin/Staff Accounts

| Role | Email | Password | Access Level |
|------|-------|----------|--------------|
| **Super Admin** | `superadmin@laundrypro.com` | `demo123` | Platform-wide access |
| **Organization Owner** | `owner@laundrypro.bh` | `demo123` | Full business management |
| **Branch Manager** | `manager@laundrypro.bh` | `demo123` | Branch operations |
| **Inventory Manager** | `inventory@laundrypro.bh` | `demo123` | Inventory management |
| **Laundry Staff** | `staff@laundrypro.bh` | `demo123` | Order processing |
| **Cashier** | `cashier@laundrypro.bh` | `demo123` | Payment processing |
| **Delivery Agent** | `delivery@laundrypro.bh` | `demo123` | Delivery management |

### Customer Accounts

| Name | Email | Password | Type |
|------|-------|----------|------|
| **Sara Ahmed** | `sara.ahmed@gmail.com` | `demo123` | Customer |
| **Mohammed Hassan** | `mohammed.hassan@yahoo.com` | `demo123` | Customer |

## 📱 Application Features

### 1. **Customer Mobile App** 
- **URL**: `/customer-app`
- **Features**:
  - Browse laundry services
  - Place new orders
  - Track order status
  - Loyalty points system
  - Digital wallet
  - Account management

### 2. **QR Code Quick Order**
- **URL**: `/quick-order`
- **Features**:
  - Quick order placement via QR code
  - Customer authentication (phone number)
  - Service selection (Wash, Iron, Wash & Iron)
  - Item selection with pricing
  - Pickup/delivery scheduling
  - Payment options (Cash/Card)
  - Order confirmation

### 3. **Admin Dashboard**
- **URL**: `/tenant/ola-laundry/dashboard`
- **Features**:
  - Business analytics
  - Order management
  - Customer management
  - Inventory tracking
  - Financial reports
  - Staff management

### 4. **Delivery Driver App**
- **URL**: `/delivery-app`
- **Features**:
  - Route optimization
  - Order tracking
  - Customer communication
  - Delivery confirmation

### 5. **Vendor POS System**
- **URL**: `/vendor-pos`
- **Features**:
  - Point of sale interface
  - Order processing
  - Payment handling
  - Receipt generation

## 🧪 How to Test

### 1. **Test Customer App**
1. Go to the main page
2. Click "Try Customer App" button
3. Browse services and features
4. Test order placement flow

### 2. **Test QR Code Order**
1. Go to the main page
2. Click "QR Quick Order" button
3. Enter phone number: `+973-3311-5678`
4. Complete the order flow

### 3. **Test Admin Login**
1. Go to the main page
2. Click "Login" button
3. Use any admin credentials from the table above
4. Access the dashboard and management features

### 4. **Test Mobile Apps**
- Customer App: Fully functional mobile interface
- Delivery App: Driver-focused interface
- POS System: Staff point-of-sale interface

## 🌟 Key Features Implemented

✅ **Authentication System**
- Secure login with role-based access
- Demo token restricted to development only
- JWT-based authentication

✅ **Customer Experience**
- Mobile-first design
- Complete order flow
- Real-time order tracking
- Loyalty program integration

✅ **Business Management**
- Comprehensive admin dashboard
- Multi-role user system
- Inventory management
- Financial reporting

✅ **Security Fixes**
- Removed production authentication bypass
- Enforced JWT secret requirement
- Added security logging

## 🏢 Business Information

**OLA ORDERS LAUNDRY W.L.L**
- 📞 Phone: +973 37960004
- 🌐 Website: www.Olalaundry.com
- 📍 Address: Shop 1309A, Road 1819, Block 318, Hoora, Manama, Kingdom of Bahrain
- 🌱 100% Eco-friendly Operations
- 🎯 Serving Hoora, Manama with premium quality

## 🔧 Technical Notes

- **Environment**: Development mode with demo data
- **Database**: Seeded with Bahrain-specific demo data
- **Real-time**: WebSocket integration for live updates
- **PWA**: Progressive Web App capabilities
- **Responsive**: Mobile-first design approach

---

**Ready to test!** Visit the application URL and explore all the features using the provided credentials.