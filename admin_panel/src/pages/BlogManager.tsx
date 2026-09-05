import { useState, useEffect, type FormEvent } from 'react';
import { collection, getDocs, doc, setDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { logAudit } from '../lib/auditLog';
import { X, Plus } from 'lucide-react';

interface BlogPost {
  id: string;
  slug: string;
  title: string;
  url: string;
  category: string;
  date: string;
  readMinutes: number;
}

const EMPTY_FORM = { slug: '', title: '', url: '', category: '', date: '', readMinutes: 5 };

export default function BlogManager() {
  const [posts, setPosts] = useState<BlogPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [modalOpen, setModalOpen] = useState(false);
  const [editingPost, setEditingPost] = useState<BlogPost | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);

  const fetchPosts = async () => {
    setLoading(true);
    try {
      const querySnapshot = await getDocs(collection(db, "blog_posts"));
      const fetchedPosts: BlogPost[] = [];
      querySnapshot.forEach((d) => {
        fetchedPosts.push({ id: d.id, ...d.data() } as BlogPost);
      });
      setPosts(fetchedPosts);
      setError('');
    } catch (e) {
      console.error(e);
      setError('Failed to load blog posts.');
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  const openCreateModal = () => {
    setEditingPost(null);
    setForm(EMPTY_FORM);
    setModalOpen(true);
  };

  const openEditModal = (post: BlogPost) => {
    setEditingPost(post);
    setForm({
      slug: post.slug ?? post.id,
      title: post.title ?? '',
      url: post.url ?? '',
      category: post.category ?? '',
      date: post.date ?? '',
      readMinutes: post.readMinutes ?? 5,
    });
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingPost(null);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    const slug = form.slug.trim();
    if (!slug || !form.title.trim()) {
      setError('Slug and title are required.');
      return;
    }

    setSaving(true);
    setError('');
    try {
      const data = {
        slug,
        title: form.title.trim(),
        url: form.url.trim(),
        category: form.category.trim(),
        date: form.date.trim(),
        readMinutes: Number(form.readMinutes) || 0,
      };

      // Document id is the slug (see admin_panel/populate.js). If the slug
      // changed on an edit, that means a new document id, so move the doc.
      if (editingPost && editingPost.id !== slug) {
        await deleteDoc(doc(db, 'blog_posts', editingPost.id));
      }
      await setDoc(doc(db, 'blog_posts', slug), data);

      await logAudit(
        'Blog Manager',
        editingPost ? `Updated post "${data.title}"` : `Created post "${data.title}"`,
        `slug=${slug}`
      );

      closeModal();
      await fetchPosts();
    } catch (err) {
      console.error(err);
      setError('Failed to save post.');
    }
    setSaving(false);
  };

  const handleDelete = async (post: BlogPost) => {
    if (!confirm(`Delete "${post.title}"? This cannot be undone.`)) return;
    try {
      await deleteDoc(doc(db, 'blog_posts', post.id));
      await logAudit('Blog Manager', `Deleted post "${post.title}"`, `slug=${post.id}`);
      await fetchPosts();
    } catch (err) {
      console.error(err);
      setError('Failed to delete post.');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-bold text-gray-900">Blog Posts</h2>
        <button
          onClick={openCreateModal}
          className="flex items-center gap-2 bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700"
        >
          <Plus size={16} />
          Add New Post
        </button>
      </div>

      {error && <div className="p-4 rounded-md text-sm font-medium bg-red-50 text-red-700">{error}</div>}

      <div className="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
        {loading ? (
          <div className="p-8 text-center text-gray-500">Loading posts...</div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {posts.map((post) => (
                <tr key={post.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{post.title}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{post.category}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{post.date}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button onClick={() => openEditModal(post)} className="text-blue-600 hover:text-blue-900 mr-4">Edit</button>
                    <button onClick={() => handleDelete(post)} className="text-red-600 hover:text-red-900">Delete</button>
                  </td>
                </tr>
              ))}
              {posts.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-6 py-8 text-center text-gray-500">No blog posts found.</td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>

      {modalOpen && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={closeModal}>
          <div
            className="bg-white rounded-lg shadow-xl max-w-lg w-full max-h-[85vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-bold text-gray-900">{editingPost ? 'Edit Post' : 'Add New Post'}</h3>
              <button onClick={closeModal} className="text-gray-400 hover:text-gray-600">
                <X size={20} />
              </button>
            </div>
            <form onSubmit={handleSubmit} className="px-6 py-4 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  required
                  value={form.title}
                  onChange={(e) => setForm({ ...form, title: e.target.value })}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Slug</label>
                <input
                  type="text"
                  required
                  value={form.slug}
                  onChange={(e) => setForm({ ...form, slug: e.target.value })}
                  placeholder="how-to-rank-higher-on-youtube"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Category</label>
                  <input
                    type="text"
                    value={form.category}
                    onChange={(e) => setForm({ ...form, category: e.target.value })}
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Read Minutes</label>
                  <input
                    type="number"
                    min={1}
                    value={form.readMinutes}
                    onChange={(e) => setForm({ ...form, readMinutes: Number(e.target.value) })}
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Date</label>
                <input
                  type="text"
                  value={form.date}
                  onChange={(e) => setForm({ ...form, date: e.target.value })}
                  placeholder="September 5, 2026"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">URL</label>
                <input
                  type="text"
                  value={form.url}
                  onChange={(e) => setForm({ ...form, url: e.target.value })}
                  placeholder="/blog/how-to-rank-higher-on-youtube"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-red-500 focus:outline-none focus:ring-1 focus:ring-red-500"
                />
              </div>
              <div className="pt-2 flex justify-end gap-3">
                <button type="button" onClick={closeModal} className="px-4 py-2 rounded-md font-medium text-sm text-gray-700 hover:bg-gray-50">
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-red-600 text-white px-4 py-2 rounded-md font-medium text-sm hover:bg-red-700 disabled:opacity-50"
                >
                  {saving ? 'Saving...' : 'Save Post'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
