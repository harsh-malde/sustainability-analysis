-- 8. Which buyers require certifications that a given factory doesn't currently hold?
SELECT DISTINCT
	b.buyer_name, o.factory_id, sm.cert_name, br.req_certification
FROM Orders as o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Sust_Metrics as sm
ON o.factory_id = sm.factory_id and sm.time_period = (SELECT MAX(time_period) 
        FROM Sust_Metrics 
        WHERE factory_id = sm.factory_id)
LEFT JOIN Buyer_Req as br
ON o.buyer_id = br.buyer_id
WHERE sm.cert_name IS NULL 
   OR sm.cert_name <> br.req_certification

-- 9. Are any EU buyers sourcing from factories that wouldn't pass their own standards?
/* CREATE VIEW vw_LatestAudit AS
SELECT factory_id, audit_date, overall_rating, labour_score, safety_score, env_score, violations
FROM Compl_Audits AS ca
WHERE audit_date = (SELECT MAX(audit_date) FROM Compl_Audits WHERE factory_id = ca.factory_id) */

SELECT DISTINCT b.buyer_name, f.factory_name, la.overall_rating, b.comp_score_req
FROM Orders AS o
LEFT JOIN Buyers AS b ON o.buyer_id = b.buyer_id
LEFT JOIN Factories AS f ON o.factory_id = f.factory_id
LEFT JOIN vw_LatestAudit AS la ON o.factory_id = la.factory_id
WHERE b.buyer_region = 'EU' AND la.overall_rating < b.comp_score_req
ORDER BY b.buyer_name;

-- 10. For each buyer, show their order value and their sourced factories' average compliance score, broken out by quarter.
SELECT b.buyer_name, AVG(DISTINCT overall_rating) AS avg_rate, 
DATEPART(YEAR, order_date)AS order_year,
DATEPART(QUARTER, order_date) AS order_quarter, SUM(order_value) AS avg_order
FROM Orders as o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND audit_date = (SELECT MAX(audit_date) FROM Compl_Audits WHERE factory_id = ca.factory_id)
GROUP BY b.buyer_name, DATEPART(YEAR, order_date), DATEPART(QUARTER, order_date)
ORDER BY b.buyer_name