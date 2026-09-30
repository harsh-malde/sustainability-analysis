-- Compliance and Risk
-- 1. Which of our factories are currently failing to meet a buyer's required compliance score?

SELECT 
	b.buyer_name,
	b.comp_score_req,
	f.factory_name,
	ca.audit_date AS latest_date,
	ca.overall_rating AS latest_score
FROM Orders AS o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Factories AS f
ON o.factory_id = f.factory_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND ca.audit_date = (
									SELECT MAX(audit_date) 
									FROM Compl_Audits 
									WHERE factory_id = ca.factory_id)		
WHERE ca.overall_rating < b.comp_score_req
GROUP BY b.buyer_name, b.comp_score_req, f.factory_name, 
         ca.overall_rating, ca.audit_date;

-- 2. For each buyer, how many of the factories we use for them are below that buyer's threshold?
SELECT 
	b.buyer_name,
	Count (DISTINCT (CASE WHEN ca.overall_rating < b.comp_score_req THEN f.factory_id END))
FROM Orders AS o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Factories AS f
ON o.factory_id = f.factory_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND ca.audit_date = (
									SELECT MAX(audit_date) 
									FROM Compl_Audits 
									WHERE factory_id = ca.factory_id)		
GROUP BY b.buyer_name;

-- 3. How much of our order value is sitting with factories that don't meet 
-- the required compliance score?

SELECT SUM(total_value) AS overall_value_at_risk
FROM (
   
SELECT 
	f.factory_name,
	SUM(o.order_value) AS total_value
FROM Orders AS o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Factories AS f
ON o.factory_id = f.factory_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND ca.audit_date = (
									SELECT MAX(audit_date) 
									FROM Compl_Audits 
									WHERE factory_id = ca.factory_id)		
WHERE ca.overall_rating < b.comp_score_req
GROUP BY f.factory_name

) AS sub;

-- 4. Which factory is our single biggest compliance risk, in dollar terms?
SELECT TOP 1
	f.factory_name,
	SUM(o.order_value) AS total_value
FROM Orders AS o
LEFT JOIN Buyers AS b
ON o.buyer_id = b.buyer_id
LEFT JOIN Factories AS f
ON o.factory_id = f.factory_id
LEFT JOIN Compl_Audits AS ca
ON o.factory_id = ca.factory_id AND ca.audit_date = (
									SELECT MAX(audit_date) 
									FROM Compl_Audits 
									WHERE factory_id = ca.factory_id)		
WHERE ca.overall_rating < b.comp_score_req
GROUP BY f.factory_name
