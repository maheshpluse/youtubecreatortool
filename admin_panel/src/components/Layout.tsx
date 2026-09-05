import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { signOut } from 'firebase/auth';
import { auth } from '../firebase';
import { logAudit } from '../lib/auditLog';
import { useIdleLogout } from '../hooks/useIdleLogout';
import { LayoutDashboard, LogOut, Settings, FileText, ServerCrash, ShieldCheck } from 'lucide-react';

const NAV_ITEMS = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/blogs', label: 'Blog Posts', icon: FileText },
  { to: '/settings', label: 'API Settings', icon: Settings },
  { to: '/logs', label: 'System Logs', icon: ServerCrash },
  { to: '/admins', label: 'Admins', icon: ShieldCheck },
];

export default function Layout() {
  const navigate = useNavigate();
  const location = useLocation();
  useIdleLogout();

  const handleLogout = async () => {
    const email = auth.currentUser?.email;
    if (email) await logAudit('Logout', `${email} signed out`);
    await signOut(auth);
    navigate('/login');
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-gray-200 flex flex-col">
        <div className="h-16 flex items-center px-6 border-b border-gray-200">
          <span className="text-xl font-bold text-red-600 tracking-tight">CreatorTools Admin</span>
        </div>
        <nav className="flex-1 overflow-y-auto py-4">
          <ul className="space-y-1 px-3">
            {NAV_ITEMS.map(({ to, label, icon: Icon, end }) => {
              const active = end ? location.pathname === to : location.pathname.startsWith(to);
              return (
                <li key={to}>
                  <Link
                    to={to}
                    className={`flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-md ${
                      active
                        ? 'text-gray-900 bg-gray-100'
                        : 'text-gray-700 hover:text-gray-900 hover:bg-gray-50'
                    }`}
                  >
                    <Icon size={18} className={active ? 'text-gray-500' : 'text-gray-400'} />
                    {label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>
        <div className="p-4 border-t border-gray-200 space-y-2">
          {auth.currentUser?.email && (
            <p className="px-3 text-xs text-gray-500 truncate" title={auth.currentUser.email}>
              Signed in as {auth.currentUser.email}
            </p>
          )}
          <button
            onClick={handleLogout}
            className="flex w-full items-center gap-3 px-3 py-2 text-sm font-medium rounded-md text-gray-700 hover:text-gray-900 hover:bg-gray-50"
          >
            <LogOut size={18} className="text-gray-400" />
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8">
          <h1 className="text-lg font-medium text-gray-900">Dashboard</h1>
        </header>
        <div className="flex-1 overflow-auto p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
