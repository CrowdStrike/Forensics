SELECT 	AppPoolName,
	COUNT(*) AS Total
FROM *.etl
WHERE EventTypeName = 'Deliver'
GROUP BY AppPoolName
ORDER BY Total DESC