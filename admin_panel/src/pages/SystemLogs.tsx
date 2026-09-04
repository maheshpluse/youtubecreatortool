import { useEffect, useMemo, useState } from 'react';
import { collection, query, orderBy, limit, getDocs, Timestamp } from 'firebase/firestore';
import { db } from '../firebase';
import { AlertCircle, Clock, Server, FileText, X, Search } from 'lucide-react';

interface SystemLog {
  id: string;
  location: string;
  message: string;
  details: string;
  actor?: string;
  type?: 'error' | 'audit';
  timestamp?: Timestamp;
}

type FilterType = 'all' | 'error' | 'audit';

export default function SystemLogs() {
  const [logs, setLogs] = useState<SystemLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<FilterType>('all');
  const [selectedLog, setSelectedLog] = useState<SystemLog | null>(null);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      // Fetch latest 50 logs
      const q = query(
        collection(db, 'system_logs'),
        orderBy('timestamp', 'desc'),
        limit(50)
      );
      const querySnapshot = await getDocs(q);
      const fetchedLogs: SystemLog[] = [];
      querySnapshot.forEach((doc) => {
        fetchedLogs.push({ id: doc.id, ...doc.data() } as SystemLog);
      });
      setLogs(fetchedLogs);
      setError(null);
    } catch (err) {
      console.error("Error fetching logs:", err);
      setError("Failed to load system logs.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, []);

  const filteredLogs = useMemo(() => {
    const term = search.trim().toLowerCase();
    return logs.filter((log) => {
      const type = log.type ?? 'error';
      if (filter !== 'all' && type !== filter) return false;
      if (!term) return true;
      return (
        log.location?.toLowerCase().includes(term) ||
        log.message?.toLowerCase().includes(term) ||
        log.actor?.toLowerCase().includes(term)
      );
    });
  }, [logs, search, filter]);

  if (loading) {
    return <div className="flex h-full items-center justify-center">Loading logs...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 tracking-tight">System Logs</h2>
          <p className="mt-1 text-sm text-gray-500">
            Backend errors and admin audit entries, newest first. Errors are automatic; audit entries record who did what.
          </p>
        </div>
        <button
          onClick={fetchLogs}
          className="px-4 py-2 bg-white border border-gray-300 text-sm font-medium rounded-md text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors"
        >
          Refresh Logs
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3 sm:items-center">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search by location, message, or actor..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 rounded-md border border-gray-300 text-sm shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
          />
        </div>
        <div className="flex gap-2">
          {(['all', 'error', 'audit'] as FilterType[]).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-3 py-2 text-sm font-medium rounded-md border ${
                filter === f
                  ? 'bg-gray-900 text-white border-gray-900'
                  : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'
              }`}
            >
              {f === 'all' ? 'All' : f === 'error' ? 'Errors' : 'Admin Actions'}
            </button>
          ))}
        </div>
      </div>

      {error && (
        <div className="p-4 bg-red-50 text-red-700 rounded-lg flex items-start gap-3">
          <AlertCircle className="w-5 h-5 shrink-0 mt-0.5" />
          <p>{error}</p>
        </div>
      )}

      <div className="bg-white shadow rounded-lg overflow-hidden border border-gray-200">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Timestamp
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Location
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Message
                </th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Details
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredLogs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-sm text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <Server className="w-8 h-8 text-gray-300" />
                      <p>No matching logs found.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredLogs.map((log) => {
                  const type = log.type ?? 'error';
                  return (
                    <tr key={log.id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <div className="flex items-center gap-2">
                          <Clock className="w-4 h-4 text-gray-400" />
                          {log.timestamp?.toDate ? log.timestamp.toDate().toLocaleString() : 'N/A'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <span
                          className={`inline-flex px-2 py-0.5 rounded-full text-xs font-medium ${
                            type === 'audit' ? 'bg-blue-50 text-blue-700' : 'bg-red-50 text-red-700'
                          }`}
                        >
                          {type === 'audit' ? 'Admin Action' : 'Error'}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                        <div className="flex items-center gap-2">
                          <Server className="w-4 h-4 text-red-400" />
                          {log.location}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {log.message}
                        {log.actor && <span className="block text-xs text-gray-400">by {log.actor}</span>}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500 max-w-xs truncate" title={log.details}>
                        <button
                          onClick={() => setSelectedLog(log)}
                          className="flex items-center gap-2 hover:text-gray-900"
                        >
                          <FileText className="w-4 h-4 text-gray-400 shrink-0" />
                          <span className="truncate">{log.details || 'No details'}</span>
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {selectedLog && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={() => setSelectedLog(null)}>
          <div
            className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-bold text-gray-900">{selectedLog.location}</h3>
              <button onClick={() => setSelectedLog(null)} className="text-gray-400 hover:text-gray-600">
                <X size={20} />
              </button>
            </div>
            <div className="px-6 py-4 overflow-y-auto space-y-3">
              <p className="text-sm text-gray-900">{selectedLog.message}</p>
              {selectedLog.actor && <p className="text-xs text-gray-500">Performed by {selectedLog.actor}</p>}
              <pre className="whitespace-pre-wrap wrap-break-word text-xs bg-gray-50 rounded-md p-3 text-gray-700 border border-gray-100">
                {selectedLog.details || 'No details recorded.'}
              </pre>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
