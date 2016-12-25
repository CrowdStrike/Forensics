SELECT TOP 10 
	EXTRACT_TOKEN(cs-uri-query,0,'|') AS Query,
	STRCAT(cs-uri-stem, REPLACE_IF_NOT_NULL(cs-uri-query,STRCAT('?',Query))) AS URI,
	sc-status AS STATUS,
	cs-method AS VERB,
	COUNT(*) AS TOTAL,
	SEQUENCE(1) AS UID 
INTO StressFile.ubr
FROM %windir%\system32\logfiles\w3svc1\ex*.log
WHERE (cs-method = 'GET')
GROUP BY URI, VERB, STATUS, Query
ORDER BY TOTAL DESC

