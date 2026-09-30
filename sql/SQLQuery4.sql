-- 11. Which factories have the highest carbon footprint or water usage per unit right now?
SELECT TOP 3 factory_id, carbon_footprint
FROM Sust_Metrics
WHERE time_period = (SELECT MAX(time_period) FROM Sust_Metrics)
ORDER BY carbon_footprint DESC

-- 12. Which factories are missing an active certification altogether?
SELECT factory_id, active_cert
FROM Sust_Metrics
WHERE active_cert != 'Certified'
ORDER BY factory_id

-- 13. Has any factory's renewable energy usage or waste recycling gotten worse over the last few quarters?
SELECT 
	factory_id, 
	time_period,
	renewable_energy,
	LAG (renewable_energy) OVER (PARTITION BY factory_id ORDER BY time_period) AS previous_score,
	renewable_energy - LAG (renewable_energy) OVER (PARTITION BY factory_id ORDER BY time_period) AS diff
FROM Sust_Metrics
