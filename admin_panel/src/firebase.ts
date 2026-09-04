import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  projectId: "creatortools-admin-mj-2026",
  appId: "1:366899182369:web:a3c3889ceab93a36bf1c60",
  storageBucket: "creatortools-admin-mj-2026.firebasestorage.app",
  apiKey: "AIzaSyDx-QBhFeki_EIFvL-ndddP6jH9Cfo82t0",
  authDomain: "creatortools-admin-mj-2026.firebaseapp.com",
  messagingSenderId: "366899182369",
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
