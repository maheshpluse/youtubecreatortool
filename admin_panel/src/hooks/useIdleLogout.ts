import { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { signOut } from 'firebase/auth';
import { auth } from '../firebase';
import { logAudit } from '../lib/auditLog';

const IDLE_LIMIT_MS = 30 * 60 * 1000; // 30 minutes
const CHECK_INTERVAL_MS = 30 * 1000;
const ACTIVITY_EVENTS = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart'];

// Signs an idle admin out so a browser left open on a shared machine doesn't
// stay logged in indefinitely.
export function useIdleLogout() {
  const navigate = useNavigate();
  const lastActivity = useRef(0);

  useEffect(() => {
    const markActive = () => {
      lastActivity.current = Date.now();
    };
    markActive();
    ACTIVITY_EVENTS.forEach((evt) => window.addEventListener(evt, markActive, { passive: true }));

    const interval = setInterval(async () => {
      if (Date.now() - lastActivity.current > IDLE_LIMIT_MS && auth.currentUser) {
        await logAudit('Session', 'Signed out automatically after 30 minutes of inactivity');
        await signOut(auth);
        navigate('/login');
      }
    }, CHECK_INTERVAL_MS);

    return () => {
      ACTIVITY_EVENTS.forEach((evt) => window.removeEventListener(evt, markActive));
      clearInterval(interval);
    };
  }, [navigate]);
}
