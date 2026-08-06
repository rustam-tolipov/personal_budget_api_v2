-- ============================================================================
-- Benchmark data generator for personal_budget_api_v2
-- ----------------------------------------------------------------------------
-- Generates a large, realistic dataset using SET-BASED SQL (generate_series +
-- INSERT...SELECT). This is THE lesson: millions of rows in seconds, vs hours
-- if you looped row-by-row through ActiveRecord.
--
-- Run:  psql "$DSN" -v ON_ERROR_STOP=1 -f db/benchmark/01_generate_data.sql
-- Tune the counts below with -v, e.g.:  -v n_tx=10000000
--
-- WARNING: this TRUNCATEs all app tables first (clean, repeatable benchmark).
-- ============================================================================

\timing on
\set ON_ERROR_STOP on

-- ---- Tunable row counts (override with -v name=value) ----------------------
\if :{?n_accounts} \else \set n_accounts 50000   \endif
\if :{?n_groups}   \else \set n_groups   10000   \endif
\if :{?n_budgets}  \else \set n_budgets  30000   \endif
\if :{?n_invites}  \else \set n_invites  20000   \endif
\if :{?n_tx}       \else \set n_tx       5000000 \endif

\echo 'Wiping existing data...'
TRUNCATE transactions, invitations, budgets, family_group_memberships,
         family_groups, accounts
  RESTART IDENTITY CASCADE;

-- ---- 1. accounts -----------------------------------------------------------
-- ids become 1..n_accounts (fresh serial). encrypted_password is a fixed dummy
-- bcrypt hash: these accounts can't log in via the API, but that's irrelevant
-- for DB-level query benchmarking.
\echo 'Inserting accounts...'
INSERT INTO accounts (email, encrypted_password, jti, username, first_name, last_name, created_at, updated_at)
SELECT
  'user' || g || '@example.com',
  '$2a$12$0000000000000000000000000000000000000000000000000000o',  -- dummy hash
  md5('jti' || g),
  'user' || g,
  (ARRAY['Alex','Sam','Jordan','Taylor','Casey','Morgan','Riley','Jamie'])[1 + (g % 8)],
  (ARRAY['Lee','Kim','Patel','Garcia','Smith','Chen','Khan','Nguyen'])[1 + (g % 8)],
  now() - (random() * interval '730 days'),
  now()
FROM generate_series(1, :n_accounts) AS g;

-- ---- 2. family_groups (owner = random account) ----------------------------
\echo 'Inserting family_groups...'
INSERT INTO family_groups (name, owner_id, created_at, updated_at)
SELECT
  'Family Group ' || g,
  1 + floor(random() * :n_accounts)::int,
  now() - (random() * interval '730 days'),
  now()
FROM generate_series(1, :n_groups) AS g;

-- ---- 3. give every account an active group + a membership row -------------
-- One membership per account => guaranteed unique (group, account) pairs,
-- while groups still end up with many members (realistic fan-out).
\echo 'Assigning active groups + memberships...'
UPDATE accounts
   SET active_family_group_id = 1 + floor(random() * :n_groups)::int;

INSERT INTO family_group_memberships (family_group_id, account_id, role, created_at, updated_at)
SELECT active_family_group_id, id, (id % 5 = 0)::int, now(), now()
FROM accounts;

-- ---- 4. budgets (always tied to an account; ~half also to a group) --------
-- Satisfies the CHECK (family_group_id IS NOT NULL OR account_id IS NOT NULL).
\echo 'Inserting budgets...'
INSERT INTO budgets (name, budget_type, "limit", start_date, end_date, account_id, family_group_id, created_at, updated_at)
SELECT
  'Budget ' || g,
  g % 4,                                              -- personal/family/savings/expense
  round((random() * 9000 + 100)::numeric, 2),
  (now() - (random() * interval '365 days'))::date,
  (now() + (random() * interval '365 days'))::date,
  1 + floor(random() * :n_accounts)::int,
  CASE WHEN g % 2 = 0 THEN 1 + floor(random() * :n_groups)::int ELSE NULL END,
  now(), now()
FROM generate_series(1, :n_budgets) AS g;

-- ---- 5. invitations --------------------------------------------------------
\echo 'Inserting invitations...'
INSERT INTO invitations (family_group_id, inviter_id, invitation_email, token, expiration_date, invitation_accepted, created_at, updated_at)
SELECT
  1 + floor(random() * :n_groups)::int,
  1 + floor(random() * :n_accounts)::int,
  'invitee' || g || '@example.com',
  md5('token' || g) || md5('salt' || g),              -- unique token
  now() + (random() * interval '14 days'),
  (g % 3 = 0),
  now(), now()
FROM generate_series(1, :n_invites) AS g;

-- ---- 6. transactions (THE hot table) --------------------------------------
-- account_id NOT NULL; budget_id sometimes NULL. created_at spread over 2 years
-- so we can practice time-range queries (and watch them seq-scan without an index).
\echo 'Inserting transactions (this is the big one)...'
INSERT INTO transactions (name, amount, transaction_type, account_id, budget_id, created_at, updated_at)
SELECT
  (ARRAY['Groceries','Rent','Salary','Coffee','Fuel','Utilities','Dining','Refund','Bonus','Subscription'])[1 + (g % 10)],
  round((random() * 1000 + 1)::numeric, 2),           -- > 0
  (g % 2),                                            -- debit/credit
  1 + floor(random() * :n_accounts)::int,
  CASE WHEN g % 4 = 0 THEN NULL ELSE 1 + floor(random() * :n_budgets)::int END,
  now() - (random() * interval '730 days'),
  now()
FROM generate_series(1, :n_tx) AS g;

-- ---- Update planner statistics (CRUCIAL) ----------------------------------
-- Lesson: the query planner makes decisions from table statistics. After a bulk
-- load, stats are stale -> bad plans. ANALYZE fixes that.
\echo 'Running ANALYZE...'
ANALYZE accounts, family_groups, family_group_memberships, budgets, invitations, transactions;

\echo 'Done. Row counts:'
SELECT 'accounts' AS table, count(*) FROM accounts
UNION ALL SELECT 'family_groups', count(*) FROM family_groups
UNION ALL SELECT 'family_group_memberships', count(*) FROM family_group_memberships
UNION ALL SELECT 'budgets', count(*) FROM budgets
UNION ALL SELECT 'invitations', count(*) FROM invitations
UNION ALL SELECT 'transactions', count(*) FROM transactions;
