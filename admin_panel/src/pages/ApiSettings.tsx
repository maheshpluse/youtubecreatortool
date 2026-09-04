import { useState, useEffect } from 'react';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { Save } from 'lucide-react';

export default function ApiSettings() {
  // Field name must stay in sync with backend/main.py:get_anthropic_client(),
  // which reads app_settings/api_keys.anthropic_api_key.
  const [anthropicKey, setAnthropicKey] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    setLoading(true);
    try {
      const docRef = doc(db, "app_settings", "api_keys");
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setAnthropicKey(docSnap.data().anthropic_api_key || '');
      }
    } catch (e) {
      console.error(e);
    }
    setLoading(false);
  };

  const handleSave = async () => {
    setSaving(true);
    setMessage('');
    try {
      await setDoc(doc(db, "app_settings", "api_keys"), {
        anthropic_api_key: anthropicKey
      }, { merge: true });
      setMessage('Settings saved successfully!');
    } catch (e) {
      setMessage('Error saving settings.');
    }
    setSaving(false);
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

      <div className="bg-white shadow-sm border border-gray-200 rounded-lg p-6 space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Anthropic API Key</label>
          <p className="text-xs text-gray-500 mb-2">Used for Title Generator, Thumbnails, SEO analysis, and Earnings RPM lookup.</p>
          <input
            type="password"
            value={anthropicKey}
            onChange={(e) => setAnthropicKey(e.target.value)}
            className="block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
            placeholder="sk-ant-..."
          />
        </div>
        
        <div className="pt-4 border-t border-gray-100 flex justify-end">
          <button
            onClick={handleSave}
            disabled={saving}
            className="flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
          >
            <Save size={16} />
            {saving ? 'Saving...' : 'Save Settings'}
          </button>
        </div>
      </div>
    </div>
  );
}
