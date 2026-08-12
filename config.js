/* ============================================================
   Site configuration — the one file to edit after setup.

   1. Create a free project at https://supabase.com
   2. In the SQL Editor, run the contents of setup.sql (in this repo)
   3. In Authentication → Users, add accounts for each of you
      (and turn OFF public sign-ups in Authentication → Providers)
   4. Paste your project's URL and anon/public key below
      (Settings → API in the Supabase dashboard)

   The anon key is designed to be public — all real protection is
   done by the row-level security policies in setup.sql.

   Until this is filled in, the guest site runs in fallback mode
   (built-in content, RSVP via pre-filled email) and the admin
   dashboard shows setup instructions.
   ============================================================ */
window.WEDDING_CONFIG = {
  SUPABASE_URL: "",       // e.g. "https://abcdefgh.supabase.co"
  SUPABASE_ANON_KEY: "",  // long "anon public" key
  RSVP_EMAIL: "charlie@primarycodingleague.co.uk", // fallback + contact
};
