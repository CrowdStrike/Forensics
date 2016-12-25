SELECT TOP 100
	'%EventLog%' AS %EventLog%, /* Title of the page */
	RecordNumber,
	ComputerName AS Computer,
        CASE TO_UPPERCASE(SUBSTR(EventTypeName,0,4))
	   WHEN 'ERRO' THEN 'ERROR'
	   ELSE TO_UPPERCASE(SUBSTR(EventTypeName,0,4))
	END AS Type,
	TO_STRING(TimeGenerated, 'dddd, MMMM d, yyyy') AS LongTimeStamp,
	TO_STRING(TimeGenerated, 'M/d hh:mm:ss') AS ShortTimeStamp,
	SourceName,
	EventCategoryName AS Category,
	EventID,
	COALESCE(SID, 'N/A') AS LongUser,
	COALESCE( REPLACE_STR( REPLACE_STR(SID,'NT AUTHORITY\\',''),'%USERDOMAIN%\\',''), 'N/A') AS ShortUser,
	Message
INTO %EventLog%EventLog.htm
FROM %EventLog%

