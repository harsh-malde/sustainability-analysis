-- 14. Overall, how many factories are non-compliant, and what's the total dollar exposure?
SELECT 
	COUNT(DISTINCT o.factory_id), 
	SUM(o.order_value) AS total_dollar_exposed
FROM Orders AS o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND ca.audit_date = (SELECT MAX(audit_date) FROM Compl_Audits WHERE factory_id = ca.factory_id)
WHERE b.comp_score_req > ca.overall_rating

-- 15. What's the average compliance score across all our factories?
SELECT AVG(overall_rating) AS avg_rating
FROM Compl_Audits AS ca
WHERE audit_date = (SELECT MAX(audit_date) FROM Compl_Audits WHERE factory_id = ca.factory_id)

-- 16. How many factories currently show 'Not certified' status?
SELECT COUNT(DISTINCT factory_id) AS not_certified
FROM Sust_Metrics AS sm
WHERE time_period = (SELECT MAX(time_period) FROM Sust_Metrics WHERE factory_id = sm.factory_id)
  AND active_cert = 'Not Certified'

