import { Users, FileText, Activity } from 'lucide-react';

export default function Dashboard() {
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
            <h3 className="text-2xl font-bold text-gray-900">20</h3>
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-green-50 text-green-600">
            <Users size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Active Users</p>
            <h3 className="text-2xl font-bold text-gray-900">1,204</h3>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-purple-50 text-purple-600">
            <Activity size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">API Requests (Today)</p>
            <h3 className="text-2xl font-bold text-gray-900">4,392</h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-bold text-gray-900 mb-4">Welcome to CreatorTools Admin!</h2>
        <p className="text-gray-600">
          This dashboard allows you to manage the real-time data for the CreatorTools app. 
          Use the sidebar to navigate to Blog Management or API Settings.
        </p>
      </div>
    </div>
  );
}
