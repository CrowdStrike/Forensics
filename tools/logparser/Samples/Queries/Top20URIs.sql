SELECT TOP 20 	cs-uri-stem, 
		COUNT(*) AS Total, 
		MAX(time-taken) AS MaxTime, 
		AVG(time-taken) AS AvgTime, 
		AVG(sc-bytes) AS AvgBytesSent 
FROM ex*.log 
GROUP BY cs-uri-stem
ORDER BY Total DESC
