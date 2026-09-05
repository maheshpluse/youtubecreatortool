import { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import type { User } from 'firebase/auth';
import { auth } from './firebase';

import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import BlogManager from './pages/BlogManager';
import ApiSettings from './pages/ApiSettings';
import SystemLogs from './pages/SystemLogs';
import Admins from './pages/Admins';
import Layout from './components/Layout';

function App() {
  const [user, setUser] = useState<User | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const [authError, setAuthError] = useState('');

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
      if (!u) {
        setUser(null);
        setIsAdmin(false);
        setLoading(false);
        return;
      }

      try {
        // Force a refresh so a claim granted moments ago (e.g. right after
        // create_admin.py runs) is picked up without a stale cached token.
        const tokenResult = await u.getIdTokenResult(true);
        if (tokenResult.claims.admin === true) {
          setUser(u);
          setIsAdmin(true);
          setAuthError('');
        } else {
          setAuthError('This account does not have admin access.');
          await signOut(auth);
          setUser(null);
          setIsAdmin(false);
        }
      } catch (err) {
        console.error('Failed to verify admin claim:', err);
        setAuthError('Could not verify admin access. Please try again.');
        await signOut(auth);
        setUser(null);
        setIsAdmin(false);
      }

      setLoading(false);
    });
    return unsubscribe;
  }, []);

  if (loading) return <div className="flex h-screen items-center justify-center">Loading...</div>;

  const authorized = !!user && isAdmin;

  return (
    <BrowserRouter basename="/adminx">
      <Routes>
        <Route path="/login" element={!authorized ? <Login error={authError} /> : <Navigate to="/" />} />
        <Route path="/" element={authorized ? <Layout /> : <Navigate to="/login" />}>
          <Route index element={<Dashboard />} />
          <Route path="blogs" element={<BlogManager />} />
          <Route path="settings" element={<ApiSettings />} />
          <Route path="logs" element={<SystemLogs />} />
          <Route path="admins" element={<Admins />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
