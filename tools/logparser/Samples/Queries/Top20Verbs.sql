SELECT TOP 20 	cs-method, 
		COUNT(*) AS Total, 
		MAX(time-taken) AS MaxTime, 
		AVG(time-taken) AS AvgTime, 
		AVG(sc-bytes) AS AvgBytesSent 
FROM ex*.log 
GROUP BY cs-method 
ORDER BY Total DESC

