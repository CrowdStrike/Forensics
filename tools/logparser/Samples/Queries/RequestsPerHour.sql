SELECT	QUANTIZE(TO_TIMESTAMP(date, time), 3600) AS Hour, 
	COUNT(*) AS Total,  
	SUM(sc-bytes) AS TotBytesSent 
FROM ex*.log 
GROUP BY Hour 
ORDER BY Hour
