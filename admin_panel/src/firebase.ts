import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyByjWWY6sCj6zVKgnJgctbrDwSqoMVVxJ0",
  authDomain: "creatortools-cf7e6.firebaseapp.com",
  projectId: "creatortools-cf7e6",
  storageBucket: "creatortools-cf7e6.firebasestorage.app",
  messagingSenderId: "635137014380",
  appId: "1:635137014380:web:33718f7204e35d13327649",
  measurementId: "G-YPSYWRRFGX"
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
