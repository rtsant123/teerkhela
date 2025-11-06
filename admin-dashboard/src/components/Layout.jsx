import { Outlet, Link, useLocation } from 'react-router-dom';
import { logout } from '../services/api';
import {
  LayoutDashboard,
  Users,
  TrendingUp,
  ClipboardList,
  Bell,
  LogOut
} from 'lucide-react';

const Layout = ({ onLogout }) => {
  const location = useLocation();

  const menuItems = [
    { path: '/', icon: LayoutDashboard, label: 'Dashboard' },
    { path: '/users', icon: Users, label: 'Users' },
    { path: '/predictions', icon: TrendingUp, label: 'Predictions' },
    { path: '/results', icon: ClipboardList, label: 'Results' },
    { path: '/notifications', icon: Bell, label: 'Notifications' },
  ];

  const handleLogout = () => {
    logout();
    onLogout();
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      {/* Sidebar */}
      <aside style={{
        width: '260px',
        backgroundColor: '#1f2937',
        color: 'white',
        padding: '24px 0',
        position: 'fixed',
        height: '100vh',
        overflowY: 'auto'
      }}>
        <div style={{ padding: '0 24px', marginBottom: '32px' }}>
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#7c3aed' }}>
            Teer Khela Admin
          </h1>
        </div>

        <nav>
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;

            return (
              <Link
                key={item.path}
                to={item.path}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  padding: '12px 24px',
                  color: isActive ? '#fff' : '#9ca3af',
                  backgroundColor: isActive ? '#7c3aed' : 'transparent',
                  textDecoration: 'none',
                  transition: 'all 0.2s',
                  borderLeft: isActive ? '4px solid #a78bfa' : '4px solid transparent'
                }}
              >
                <Icon size={20} style={{ marginRight: '12px' }} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div style={{ position: 'absolute', bottom: '24px', width: '100%', padding: '0 24px' }}>
          <button
            onClick={handleLogout}
            style={{
              display: 'flex',
              alignItems: 'center',
              width: '100%',
              padding: '12px',
              backgroundColor: '#374151',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px'
            }}
          >
            <LogOut size={20} style={{ marginRight: '12px' }} />
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main style={{ marginLeft: '260px', flex: 1, padding: '24px', backgroundColor: '#f5f5f5' }}>
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;
