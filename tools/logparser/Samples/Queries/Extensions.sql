SELECT  EXTRACT_EXTENSION( cs-uri-stem ) AS Extension, 
	COUNT(*) AS Total 
FROM ex*.log 
GROUP BY Extension 
ORDER BY Total DESC
