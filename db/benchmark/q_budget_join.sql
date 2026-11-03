-- "Per-budget totals for one account" — join budgets -> transactions + aggregate.
\set aid random(1, 50000)
SELECT b.name, count(t.id), coalesce(sum(t.amount), 0)
FROM budgets b
LEFT JOIN transactions t ON t.budget_id = b.id
WHERE b.account_id = :aid
GROUP BY b.id, b.name;
