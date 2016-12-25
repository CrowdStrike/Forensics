SELECT 	cs-username, 
	sc-status, 
	COUNT(*) AS Total 
FROM ex*.log 
WHERE cs-username IS NOT NULL AND sc-status BETWEEN 401 AND 403
GROUP BY cs-username,sc-status 
ORDER BY Total DESC
