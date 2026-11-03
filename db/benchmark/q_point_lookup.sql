-- "List my transactions" — the most common API read.
-- Filters by account_id (indexed) then sorts newest-first.
\set aid random(1, 50000)
SELECT id, name, amount, transaction_type, created_at
FROM transactions
WHERE account_id = :aid
ORDER BY created_at DESC
LIMIT 25;
@myhobbiesin