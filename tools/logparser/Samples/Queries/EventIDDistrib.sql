SELECT	SourceName, 
	EventID, 
	MUL(PROPCOUNT(*) ON (SourceName), 100.0) AS Percent
FROM System
GROUP BY SourceName, EventID
ORDER BY SourceName, Percent DESC
