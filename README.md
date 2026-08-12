# mackenziewedding.co.uk

Two-sided wedding site served by GitHub Pages at
[mackenziewedding.co.uk](https://mackenziewedding.co.uk).

**Guest side** (`/`): the invitation — order of the day, venue, menu, and an
RSVP form with per-guest menu choices and allergy declarations.

**Couple side** (`/admin/`): a login-protected dashboard showing every RSVP
as it arrives — headcounts, per-dish tallies for the caterers, an allergy
report, CSV export — plus editors for the menu and all guest-facing content.

The two sides feed each other through a free [Supabase](https://supabase.com)
database: guests' submissions appear on the dashboard instantly, and edits
made on the dashboard (menu, dates, venue, schedule…) go live on the guest
site immediately — no code changes needed after setup.

```
Guests → index.html ──write RSVPs──→ ┌──────────┐ ←──read/manage── admin/ ← You two
                     ←──read menu──  │ Supabase │
                       & site text   └──────────┘
```

## One-time setup (~5 minutes)

1. Create a free project at [supabase.com](https://supabase.com).
2. In the project's **SQL Editor**, paste the contents of [`setup.sql`](setup.sql)
   and **Run**. This creates the tables and the security rules (guests can
   only submit an RSVP; only signed-in users can read or edit anything).
3. **Authentication → Users → Add user**: create a login for each of you.
4. **Authentication → Sign In / Up**: turn **off** "Allow new users to sign up".
5. **Project Settings → API**: copy the **Project URL** and **anon public** key
   into [`config.js`](config.js) and commit.

Until setup is done, the guest site runs standalone with built-in content and
an email-based RSVP fallback, and `/admin/` shows these setup steps.

## Security model

- The anon key in `config.js` is public by design; all protection is
  row-level security in Postgres (see `setup.sql`).
- Anonymous visitors can **insert** RSVPs and **read** site content — never
  read, edit, or delete responses.
- Signed-in users (just the two of you) have full access.
- `/admin/` is noindexed and useless without a login.

## Hosting

- GitHub Pages from `main`, `/ (root)`; custom domain via `CNAME`.
- DNS (GoDaddy): apex A records `185.199.108.153` / `.109.` / `.110.` / `.111.`,
  CNAME `www` → `primarycodingleague.github.io`.
