SELECT 	STRCAT(TO_STRING(sc-status), STRCAT('.', TO_STRING(sc-substatus))) AS Status, 
	COUNT(*) AS Total 
FROM ex*.log 
GROUP BY Status 
ORDER BY Total DESC
