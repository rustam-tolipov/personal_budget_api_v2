-- "Reporting: spending in the last 7 days across ALL accounts."
-- No index on created_at => full sequential scan of the 425 MB table EVERY time.
-- This is the deliberate bottleneck.
SELECT count(*), coalesce(sum(amount), 0)
FROM transactions
WHERE created_at >= now() - interval '7 days';
