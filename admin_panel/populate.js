import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyByjWWY6sCj6zVKgnJgctbrDwSqoMVVxJ0",
  authDomain: "creatortools-cf7e6.firebaseapp.com",
  projectId: "creatortools-cf7e6",
  storageBucket: "creatortools-cf7e6.firebasestorage.app",
  messagingSenderId: "635137014380",
  appId: "1:635137014380:web:33718f7204e35d13327649"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

const blogPosts = [
  {
    slug: 'rank-higher-youtube-search',
    title: 'How to Rank Higher on YouTube Search: A 9-Step Optimization Workflow',
    category: 'SEO',
    date: 'September 1, 2026',
    readMinutes: 7,
  },
  {
    slug: 'improve-youtube-click-through-rate',
    title: 'How to Improve Your YouTube Click-Through Rate Without Clickbait',
    category: 'Analytics',
    date: 'August 27, 2026',
    readMinutes: 6,
  },
  {
    slug: 'youtube-monetization-requirements-guide',
    title: 'YouTube Monetization Requirements: The Complete Eligibility Guide',
    category: 'Monetization',
    date: 'August 22, 2026',
    readMinutes: 6,
  },
  {
    slug: 'how-to-increase-youtube-rpm',
    title: 'How to Increase Your YouTube RPM: 11 Levers That Actually Move Revenue',
    category: 'Monetization',
    date: 'August 18, 2026',
    readMinutes: 6,
  },
  {
    slug: 'youtube-keyword-research-tools',
    title: 'YouTube Keyword Research: Finding Search Terms Your Channel Can Actually Rank For',
    category: 'SEO',
    date: 'August 13, 2026',
    readMinutes: 7,
  },
  {
    slug: 'high-cpc-keywords-youtube-niches',
    title: 'High CPC Keywords and the YouTube Niches That Attract Them',
    category: 'Monetization',
    date: 'August 8, 2026',
    readMinutes: 6,
  },
  {
    slug: 'youtube-analytics-metrics-that-matter',
    title: 'The 8 YouTube Analytics Metrics That Actually Predict Growth',
    category: 'Analytics',
    date: 'August 4, 2026',
    readMinutes: 6,
  },
  {
    slug: 'how-youtube-algorithm-works',
    title: 'How the YouTube Algorithm Works (and What an Algorithm Update Really Changes)',
    category: 'Strategy',
    date: 'July 30, 2026',
    readMinutes: 6,
  },
  {
    slug: 'youtube-competitor-analysis-guide',
    title: 'YouTube Competitor Analysis: A Repeatable 6-Step Teardown',
    category: 'Strategy',
    date: 'July 25, 2026',
    readMinutes: 6,
  },
  {
    slug: 'youtube-engagement-rate-calculation',
    title: 'Video Engagement Rate: How to Calculate It and What Counts as Good',
    category: 'Analytics',
    date: 'July 21, 2026',
    readMinutes: 5,
  }
];

async function populate() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.error(
      "Missing credentials. Run as: ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=... node populate.js"
    );
    process.exit(1);
  }

  try {
    console.log("Logging in...");
    await signInWithEmailAndPassword(auth, email, password);
    console.log("Logged in successfully. Inserting posts...");
    
    for (const post of blogPosts) {
      await setDoc(doc(db, "blog_posts", post.slug), post);
      console.log(`Inserted: ${post.title}`);
    }
    
    console.log("Finished populating database!");
    process.exit(0);
  } catch (err) {
    console.error("Error:", err);
    process.exit(1);
  }
}

populate();
