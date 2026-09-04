import { auth } from '../firebase';
import { API_BASE_URL } from '../config';

// Calls the FastAPI backend's /api/admin/* endpoints, which require the
// Firebase ID token of a user carrying the `admin` custom claim (see
// backend/main.py:verify_admin). Only used for actions the client Firestore
// SDK can't perform itself, like listing/creating Firebase Auth users.
export async function apiFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = await auth.currentUser?.getIdToken();
  if (!token) throw new Error('Not signed in.');

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...options.headers,
    },
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.detail || `Request failed (${response.status})`);
  }

  return response.json();
}
