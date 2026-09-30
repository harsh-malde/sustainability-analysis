-- 5. Is each factory's score getting better or worse over the last few audits?
SELECT 
	factory_id, previous_score, current_score, audit_date,
	CASE WHEN current_score - previous_score > 0 THEN 'IMPROVING' 
		 WHEN current_score - previous_score = 0 THEN 'STABLE'
		 ELSE 'DECLINING'
	END
FROM(
	SELECT 
		factory_id, audit_date,
		overall_rating current_score,
		LAG (overall_rating, 1, overall_rating) OVER (PARTITION BY factory_id ORDER BY audit_date) previous_score
	FROM Compl_Audits)t

-- 6. Which factories had a score drop by more than X points between two consecutive audits?
SELECT 
	factory_id, 
	current_score - previous_score AS score_drop
FROM(
	SELECT 
		factory_id, 
		overall_rating current_score,
		LAG (overall_rating, 1, overall_rating) OVER (PARTITION BY factory_id ORDER BY audit_date) previous_score
	FROM Compl_Audits)t
WHERE (previous_score - current_score) > 1

-- 7. How many violations per factory over the last year, and is that number increasing?

SELECT 
    factory_id,
    audit_year,
    audit_quarter,
    quarterly_violations,
    LAG(quarterly_violations, 1, quarterly_violations) 
        OVER (PARTITION BY factory_id ORDER BY audit_year, audit_quarter) AS previous_quarter_violations,
    quarterly_violations - LAG(quarterly_violations, 1, quarterly_violations) 
        OVER (PARTITION BY factory_id ORDER BY audit_year, audit_quarter) AS violation_change
FROM (
    SELECT 
        factory_id,
        DATEPART(YEAR, audit_date) AS audit_year,
        DATEPART(QUARTER, audit_date) AS audit_quarter,
        SUM(violations) AS quarterly_violations
    FROM Compl_Audits
    WHERE audit_date >= DATEADD(YEAR, -1, GETDATE())   -- last year only
    GROUP BY factory_id, DATEPART(YEAR, audit_date), DATEPART(QUARTER, audit_date)
) AS quarterly
ORDER BY factory_id, audit_year, audit_quarter;

