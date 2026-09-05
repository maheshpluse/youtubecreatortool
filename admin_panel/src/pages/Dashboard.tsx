import { useEffect, useState } from 'react';
import { Users, FileText, Activity, History } from 'lucide-react';
import { collection, getCountFromServer, query, orderBy, limit, getDocs, Timestamp } from 'firebase/firestore';
import { db } from '../firebase';

interface AuditEntry {
  id: string;
  location: string;
  message: string;
  actor?: string;
  timestamp?: Timestamp;
}

export default function Dashboard() {
  const [stats, setStats] = useState({
    blogPosts: 0,
    systemLogs: 0,
    cachedKeywords: 0,
    loading: true
  });
  const [activity, setActivity] = useState<AuditEntry[]>([]);
  const [activityLoading, setActivityLoading] = useState(true);

  useEffect(() => {
    async function fetchStats() {
      try {
        const [blogSnap, logsSnap, keywordsSnap] = await Promise.all([
          getCountFromServer(collection(db, 'blog_posts')),
          getCountFromServer(collection(db, 'system_logs')),
          // Matches the collection backend/services/cache.py actually writes to.
          getCountFromServer(collection(db, 'keyword_cache'))
        ]);

        setStats({
          blogPosts: blogSnap.data().count,
          systemLogs: logsSnap.data().count,
          cachedKeywords: keywordsSnap.data().count,
          loading: false
        });
      } catch (error) {
        console.error("Failed to fetch dashboard stats:", error);
        setStats(s => ({ ...s, loading: false }));
      }
    }

    async function fetchActivity() {
      try {
        // Filtering client-side (rather than a `where('type','==','audit')`
        // query) avoids requiring a composite Firestore index just for this
        // widget - system_logs is small enough that scanning the most recent
        // batch is cheap.
        const q = query(
          collection(db, 'system_logs'),
          orderBy('timestamp', 'desc'),
          limit(20)
        );
        const snapshot = await getDocs(q);
        const entries: AuditEntry[] = [];
        snapshot.forEach((doc) => {
          const data = doc.data();
          if (data.type === 'audit') {
            entries.push({ id: doc.id, location: data.location, message: data.message, actor: data.actor, timestamp: data.timestamp });
          }
        });
        setActivity(entries.slice(0, 5));
      } catch (error) {
        console.error("Failed to fetch recent activity:", error);
      }
      setActivityLoading(false);
    }

    fetchStats();
    fetchActivity();
  }, []);

  return (
    <div className="space-y-6 animate-fade-in-up">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Stat Cards */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-blue-50 text-blue-600">
            <FileText size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Total Blog Posts</p>
            <h3 className="text-2xl font-bold text-gray-900">
              {stats.loading ? '...' : stats.blogPosts}
            </h3>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-green-50 text-green-600">
            <Activity size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Cached Keywords</p>
            <h3 className="text-2xl font-bold text-gray-900">
              {stats.loading ? '...' : stats.cachedKeywords}
            </h3>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-red-50 text-red-600">
            <Users size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">System Logs</p>
            <h3 className="text-2xl font-bold text-gray-900">
              {stats.loading ? '...' : stats.systemLogs}
            </h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center gap-2 mb-4">
          <History size={18} className="text-gray-400" />
          <h2 className="text-lg font-bold text-gray-900">Recent Admin Activity</h2>
        </div>
        {activityLoading ? (
          <p className="text-sm text-gray-500">Loading...</p>
        ) : activity.length === 0 ? (
          <p className="text-sm text-gray-500">No admin actions recorded yet.</p>
        ) : (
          <ul className="divide-y divide-gray-100">
            {activity.map((entry) => (
              <li key={entry.id} className="py-2 text-sm text-gray-700">
                <span className="font-medium text-gray-900">{entry.actor ?? 'system'}</span>{' '}
                &mdash; {entry.message}
                {entry.timestamp && (
                  <span className="text-gray-400"> ({entry.timestamp.toDate().toLocaleString()})</span>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
