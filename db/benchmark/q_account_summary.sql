-- "Dashboard balance" — aggregate one account's debits/credits.
\set aid random(1, 50000)
SELECT transaction_type, count(*), sum(amount)
FROM transactions
WHERE account_id = :aid
GROUP BY transaction_type;
