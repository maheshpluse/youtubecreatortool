const firebaseConfig = {
  apiKey: "AIzaSyByjWWY6sCj6zVKgnJgctbrDwSqoMVVxJ0",
  authDomain: "creatortools-cf7e6.firebaseapp.com",
  projectId: "creatortools-cf7e6",
  storageBucket: "creatortools-cf7e6.firebasestorage.app",
  messagingSenderId: "635137014380",
  appId: "1:635137014380:web:33718f7204e35d13327649"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
auth.useDeviceLanguage();

window.recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-element', {
  'size': 'invisible'
});

// Global bridge object for Jaspr
window.CTAuth = {
  currentUser: null,
  
  signInWithGoogle: async function() {
    try {
      const provider = new firebase.auth.GoogleAuthProvider();
      const result = await auth.signInWithPopup(provider);
      return { success: true, user: result.user };
    } catch (error) {
      console.error("Google Sign-in Error", error);
      return { success: false, error: error.message };
    }
  },
  
  signInWithEmail: async function(email, password) {
    try {
      const result = await auth.signInWithEmailAndPassword(email, password);
      return { success: true, user: result.user };
    } catch (error) {
      console.error("Email Sign-in Error", error);
      return { success: false, error: error.message };
    }
  },

  signUpWithEmail: async function(email, password) {
    try {
      const result = await auth.createUserWithEmailAndPassword(email, password);
      return { success: true, user: result.user };
    } catch (error) {
      console.error("Email Sign-up Error", error);
      return { success: false, error: error.message };
    }
  },
  
  signOut: async function() {
    await auth.signOut();
  },
  
  // This callback will be provided by Jaspr
  onAuthStateChangedCallback: null,
  
  setAuthListener: function(callback) {
    this.onAuthStateChangedCallback = callback;
  }
};

// Listen to auth state and notify Jaspr
auth.onAuthStateChanged((user) => {
  if (user) {
    window.CTAuth.currentUser = {
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL
    };
  } else {
    window.CTAuth.currentUser = null;
  }
  
  if (window.CTAuth.onAuthStateChangedCallback) {
    // We pass stringified JSON to make it easy for Dart to parse
    window.CTAuth.onAuthStateChangedCallback(
      window.CTAuth.currentUser ? JSON.stringify(window.CTAuth.currentUser) : null
    );
  }
});
