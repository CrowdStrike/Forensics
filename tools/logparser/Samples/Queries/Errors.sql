SELECT 	STRCAT(	cs-uri-stem, 
		REPLACE_IF_NOT_NULL(cs-uri-query, STRCAT('?',cs-uri-query))
		) AS Request, 
	STRCAT(	TO_STRING(sc-status), 		
		STRCAT(	'.',
			COALESCE(TO_STRING(sc-substatus), '?' )
			)
		) AS Status, 
	COUNT(*) AS Total 
FROM ex*.log 
WHERE (sc-status >= 400) 
GROUP BY Request, Status 
ORDER BY Total DESC
