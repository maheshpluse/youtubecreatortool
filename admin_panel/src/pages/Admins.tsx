import { useEffect, useState, type FormEvent } from 'react';
import { auth } from '../firebase';
import { apiFetch } from '../lib/api';
import { logAudit } from '../lib/auditLog';
import { UserPlus, ShieldCheck, ShieldOff, Ban, CheckCircle } from 'lucide-react';

interface AdminUser {
  uid: string;
  email: string | null;
  disabled: boolean;
  admin: boolean;
  created_at: string | null;
  last_sign_in: string | null;
}

export default function Admins() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [busyUid, setBusyUid] = useState<string | null>(null);

  const [inviteEmail, setInviteEmail] = useState('');
  const [invitePassword, setInvitePassword] = useState('');
  const [inviting, setInviting] = useState(false);

  const currentUid = auth.currentUser?.uid;

  const fetchUsers = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await apiFetch<{ users: AdminUser[] }>('/api/admin/users');
      setUsers(data.users);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load users.');
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleInvite = async (e: FormEvent) => {
    e.preventDefault();
    setInviting(true);
    setError('');
    try {
      await apiFetch('/api/admin/users/invite', {
        method: 'POST',
        body: JSON.stringify({ email: inviteEmail, password: invitePassword }),
      });
      await logAudit('Admins', `Invited ${inviteEmail} as admin`);
      setInviteEmail('');
      setInvitePassword('');
      await fetchUsers();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to invite admin.');
    }
    setInviting(false);
  };

  const toggleAdmin = async (user: AdminUser) => {
    setBusyUid(user.uid);
    setError('');
    try {
      await apiFetch('/api/admin/users/set-role', {
        method: 'POST',
        body: JSON.stringify({ uid: user.uid, admin: !user.admin }),
      });
      await logAudit('Admins', `Set admin=${!user.admin} for ${user.email}`);
      await fetchUsers();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update role.');
    }
    setBusyUid(null);
  };

  const toggleDisabled = async (user: AdminUser) => {
    setBusyUid(user.uid);
    setError('');
    try {
      await apiFetch('/api/admin/users/set-disabled', {
        method: 'POST',
        body: JSON.stringify({ uid: user.uid, disabled: !user.disabled }),
      });
      await logAudit('Admins', `Set disabled=${!user.disabled} for ${user.email}`);
      await fetchUsers();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update account.');
    }
    setBusyUid(null);
  };

  return (
    <div className="space-y-6 max-w-4xl animate-fade-in-up">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Admins</h2>
        <p className="mt-1 text-sm text-gray-500">
          Manage who can sign in to this dashboard. Only accounts with admin access can read or change anything here.
        </p>
      </div>

      {error && <div className="p-4 rounded-md text-sm font-medium bg-red-50 text-red-700">{error}</div>}

      <div className="bg-white shadow-sm border border-gray-200 rounded-lg p-6 space-y-4">
        <h3 className="text-sm font-semibold text-gray-900">Invite a new admin</h3>
        <form onSubmit={handleInvite} className="flex flex-col sm:flex-row gap-3">
          <input
            type="email"
            required
            placeholder="email@example.com"
            value={inviteEmail}
            onChange={(e) => setInviteEmail(e.target.value)}
            className="flex-1 rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
          />
          <input
            type="password"
            required
            minLength={6}
            placeholder="Temporary password"
            value={invitePassword}
            onChange={(e) => setInvitePassword(e.target.value)}
            className="flex-1 rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
          />
          <button
            type="submit"
            disabled={inviting}
            className="flex items-center justify-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
          >
            <UserPlus size={16} />
            {inviting ? 'Inviting...' : 'Invite'}
          </button>
        </form>
      </div>

      <div className="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-gray-500">Loading admins...</div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {users.map((user) => {
                const isSelf = user.uid === currentUid;
                const isBusy = busyUid === user.uid;
                return (
                  <tr key={user.uid}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {user.email} {isSelf && <span className="text-xs text-gray-400">(you)</span>}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {user.admin ? 'Admin' : 'No access'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {user.disabled ? 'Disabled' : 'Active'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                      <button
                        onClick={() => toggleAdmin(user)}
                        disabled={isBusy || (isSelf && user.admin)}
                        title={isSelf && user.admin ? "You can't remove your own admin access" : undefined}
                        className="inline-flex items-center gap-1 text-blue-600 hover:text-blue-900 disabled:opacity-40 disabled:cursor-not-allowed"
                      >
                        {user.admin ? <ShieldOff size={14} /> : <ShieldCheck size={14} />}
                        {user.admin ? 'Revoke admin' : 'Make admin'}
                      </button>
                      <button
                        onClick={() => toggleDisabled(user)}
                        disabled={isBusy || (isSelf && !user.disabled)}
                        title={isSelf && !user.disabled ? "You can't disable your own account" : undefined}
                        className="inline-flex items-center gap-1 text-red-600 hover:text-red-900 disabled:opacity-40 disabled:cursor-not-allowed"
                      >
                        {user.disabled ? <CheckCircle size={14} /> : <Ban size={14} />}
                        {user.disabled ? 'Enable' : 'Disable'}
                      </button>
                    </td>
                  </tr>
                );
              })}
              {users.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-6 py-8 text-center text-gray-500">No users found.</td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
