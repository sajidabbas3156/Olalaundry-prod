import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export type UserRole = 
  | 'superadmin'
  | 'org_owner'
  | 'branch_manager'
  | 'inventory_manager'
  | 'laundry_staff'
  | 'cashier'
  | 'delivery_agent'
  | 'customer';

export const USER_ROLES = {
  SUPERADMIN: 'superadmin' as const,
  ORG_OWNER: 'org_owner' as const,
  BRANCH_MANAGER: 'branch_manager' as const,
  INVENTORY_MANAGER: 'inventory_manager' as const,
  LAUNDRY_STAFF: 'laundry_staff' as const,
  CASHIER: 'cashier' as const,
  DELIVERY_AGENT: 'delivery_agent' as const,
  CUSTOMER: 'customer' as const,
};

interface User {
  id: number;
  email: string;
  firstName?: string;
  lastName?: string;
  phone?: string;
  role: UserRole;
  isActive: boolean;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  isLoading: boolean;
  role: UserRole | null;
  displayName: string;
  canAccessAdminDashboard: boolean;
  canAccessPOS: boolean;
  canAccessDelivery: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  hasRole: (roles: UserRole | UserRole[]) => boolean;
  hasPermission: (permission: string) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        setLoading(false);
        return;
      }

      const response = await fetch('/api/auth/user', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        const userData = await response.json();
        setUser(userData);
      } else {
        localStorage.removeItem('token');
      }
    } catch (error) {
      console.error('Auth check failed:', error);
      localStorage.removeItem('token');
    } finally {
      setLoading(false);
    }
  };

  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      if (response.ok) {
        const { token, user: userData } = await response.json();
        localStorage.setItem('token', token);
        setUser(userData);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login failed:', error);
      return false;
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    window.location.href = '/';
  };

  const hasRole = (roles: UserRole | UserRole[]): boolean => {
    if (!user) return false;
    const roleArray = Array.isArray(roles) ? roles : [roles];
    return roleArray.includes(user.role);
  };

  const hasPermission = (permission: string): boolean => {
    if (!user) return false;
    
    // Define role-based permissions
    const rolePermissions: Record<UserRole, string[]> = {
      superadmin: ['*'], // All permissions
      org_owner: ['manage_business', 'view_reports', 'manage_staff', 'manage_inventory', 'manage_orders'],
      branch_manager: ['manage_staff', 'manage_inventory', 'manage_orders', 'view_reports'],
      inventory_manager: ['manage_inventory', 'view_inventory_reports'],
      laundry_staff: ['process_orders', 'view_orders'],
      cashier: ['process_payments', 'view_orders'],
      delivery_agent: ['manage_deliveries', 'view_delivery_orders'],
      customer: ['place_orders', 'view_own_orders']
    };

    const userPermissions = rolePermissions[user.role] || [];
    return userPermissions.includes('*') || userPermissions.includes(permission);
  };

  const role = user?.role || null;
  const displayName = user ? `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.email : '';
  const canAccessAdminDashboard = hasRole(['superadmin', 'org_owner', 'branch_manager']);
  const canAccessPOS = hasRole(['superadmin', 'org_owner', 'branch_manager', 'cashier']);
  const canAccessDelivery = hasRole(['superadmin', 'org_owner', 'branch_manager', 'delivery_agent']);

  return (
    <AuthContext.Provider value={{ 
      user, 
      loading, 
      isLoading: loading,
      role,
      displayName,
      canAccessAdminDashboard,
      canAccessPOS,
      canAccessDelivery,
      login, 
      logout, 
      hasRole, 
      hasPermission 
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};