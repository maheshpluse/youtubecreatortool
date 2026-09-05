import { useState, useEffect } from 'react';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { logAudit } from '../lib/auditLog';
import { Save, Pencil } from 'lucide-react';

export default function ApiSettings() {
  const [hasGemini, setHasGemini] = useState(false);
  const [hasDataForSeo, setHasDataForSeo] = useState(false);
  
  const [editingGemini, setEditingGemini] = useState(false);
  const [editingDataForSeo, setEditingDataForSeo] = useState(false);
  
  const [geminiKey, setGeminiKey] = useState('');
  const [dataforseoKey, setDataforseoKey] = useState('');
  
  const [loading, setLoading] = useState(true);
  const [savingGemini, setSavingGemini] = useState(false);
  const [savingDataForSeo, setSavingDataForSeo] = useState(false);
  const [message, setMessage] = useState('');

  const fetchSettings = async () => {
    setLoading(true);
    try {
      const docRef = doc(db, "app_settings", "api_keys");
      const docSnap = await getDoc(docRef);
      setHasGemini(!!docSnap.exists() && !!docSnap.data().gemini_api_key);
      setHasDataForSeo(!!docSnap.exists() && !!docSnap.data().dataforseo_api_key);
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchSettings();
  }, []);

  const handleSaveGemini = async () => {
    setSavingGemini(true);
    setMessage('');
    try {
      await setDoc(doc(db, "app_settings", "api_keys"), {
        gemini_api_key: geminiKey
      }, { merge: true });
      await logAudit('API Settings', 'Updated the Gemini API key');
      setMessage('Gemini key saved successfully!');
      setHasGemini(!!geminiKey);
      setGeminiKey('');
      setEditingGemini(false);
    } catch {
      setMessage('Error saving Gemini key.');
    }
    setSavingGemini(false);
  };

  const handleSaveDataForSeo = async () => {
    setSavingDataForSeo(true);
    setMessage('');
    try {
      await setDoc(doc(db, "app_settings", "api_keys"), {
        dataforseo_api_key: dataforseoKey
      }, { merge: true });
      await logAudit('API Settings', 'Updated the DataForSEO API key');
      setMessage('DataForSEO key saved successfully!');
      setHasDataForSeo(!!dataforseoKey);
      setDataforseoKey('');
      setEditingDataForSeo(false);
    } catch {
      setMessage('Error saving DataForSEO key.');
    }
    setSavingDataForSeo(false);
  };

  if (loading) return <div className="text-gray-500">Loading settings...</div>;

  return (
    <div className="space-y-6 max-w-2xl animate-fade-in-up">
      <div>
        <h2 className="text-xl font-bold text-gray-900">API Settings</h2>
        <p className="mt-1 text-sm text-gray-500">Manage external API keys used by the CreatorTools backend.</p>
      </div>

      {message && (
        <div className={`p-4 rounded-md text-sm font-medium ${message.includes('Error') ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}`}>
          {message}
        </div>
      )}

      {/* Gemini API Key */}
      <div className="bg-white shadow-sm border border-gray-200 rounded-lg p-6 space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Google Gemini API Key</label>
          <p className="text-xs text-gray-500 mb-2">Used for Title Generator and Thumbnail Generator tools.</p>

          {!editingGemini ? (
            <div className="flex items-center justify-between rounded-md border border-gray-300 px-3 py-2">
              <span className="text-sm text-gray-500">
                {hasGemini ? 'A key is saved (hidden for security).' : 'No key saved yet.'}
              </span>
              <button
                onClick={() => setEditingGemini(true)}
                className="flex items-center gap-1 text-sm font-medium text-red-600 hover:text-red-700"
              >
                <Pencil size={14} />
                {hasGemini ? 'Change' : 'Set key'}
              </button>
            </div>
          ) : (
            <input
              type="password"
              value={geminiKey}
              onChange={(e) => setGeminiKey(e.target.value)}
              className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
              placeholder="AIzaSy..."
              autoFocus
            />
          )}
        </div>

        {editingGemini && (
          <div className="pt-4 border-t border-gray-100 flex justify-end gap-3">
            <button
              onClick={() => { setEditingGemini(false); setGeminiKey(''); }}
              className="px-4 py-2 rounded-md font-medium text-sm text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSaveGemini}
              disabled={savingGemini || !geminiKey}
              className="flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
            >
              <Save size={16} />
              {savingGemini ? 'Saving...' : 'Save Settings'}
            </button>
          </div>
        )}
      </div>

      {/* DataForSEO API Key */}
      <div className="bg-white shadow-sm border border-gray-200 rounded-lg p-6 space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">DataForSEO API Key (Base64)</label>
          <p className="text-xs text-gray-500 mb-2">Used for SEO Analyzer and real YouTube keyword data.</p>

          {!editingDataForSeo ? (
            <div className="flex items-center justify-between rounded-md border border-gray-300 px-3 py-2">
              <span className="text-sm text-gray-500">
                {hasDataForSeo ? 'A key is saved (hidden for security).' : 'No key saved yet.'}
              </span>
              <button
                onClick={() => setEditingDataForSeo(true)}
                className="flex items-center gap-1 text-sm font-medium text-red-600 hover:text-red-700"
              >
                <Pencil size={14} />
                {hasDataForSeo ? 'Change' : 'Set key'}
              </button>
            </div>
          ) : (
            <input
              type="password"
              value={dataforseoKey}
              onChange={(e) => setDataforseoKey(e.target.value)}
              className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
              placeholder="Base64 encoded string..."
            />
          )}
        </div>

        {editingDataForSeo && (
          <div className="pt-4 border-t border-gray-100 flex justify-end gap-3">
            <button
              onClick={() => { setEditingDataForSeo(false); setDataforseoKey(''); }}
              className="px-4 py-2 rounded-md font-medium text-sm text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSaveDataForSeo}
              disabled={savingDataForSeo || !dataforseoKey}
              className="flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
            >
              <Save size={16} />
              {savingDataForSeo ? 'Saving...' : 'Save Settings'}
            </button>
          </div>
        )}
      </div>

    </div>
  );
}
