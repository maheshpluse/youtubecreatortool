import { addDoc, collection, serverTimestamp } from 'firebase/firestore';
import { auth, db } from '../firebase';

// Records an admin action to the same 'system_logs' collection the backend
// writes errors to (see SystemLogs.tsx), tagged type: 'audit' so the two
// kinds of entries can be told apart and filtered. firestore.rules requires
// `actor` to match the signed-in user's own email, so this can't be spoofed.
export async function logAudit(location: string, message: string, details = '') {
  const actor = auth.currentUser?.email ?? 'unknown';
  try {
    await addDoc(collection(db, 'system_logs'), {
      location,
      message,
      details,
      type: 'audit',
      actor,
      timestamp: serverTimestamp(),
    });
  } catch (e) {
    console.error('Failed to write audit log:', e);
  }
}
