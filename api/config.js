// Gives the page the public Supabase settings (the anon key is meant to be public;
// the database is protected by the row-level security rules in supabase.sql).
module.exports = (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).json({
    url: process.env.SUPABASE_URL || null,
    anon: process.env.SUPABASE_ANON_KEY || null,
  });
};
