SELECT 	SourceName,
	Message,
	COUNT(*) as Total
FROM System
TO Output.xml
WHERE EventTypeName='Error event'
GROUP BY SourceName, Message
ORDER by Total DESC

	
