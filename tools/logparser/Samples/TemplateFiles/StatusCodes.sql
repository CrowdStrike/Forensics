SELECT 	STRCAT(TO_STRING(sc-status), REPLACE_IF_NOT_NULL(TO_STRING(sc-substatus), STRCAT('.',TO_STRING(sc-substatus)))) AS Status, 
	COUNT(*) AS Total 
FROM ex*.log 
TO StatusCodes.html
GROUP BY Status 
ORDER BY Status ASC