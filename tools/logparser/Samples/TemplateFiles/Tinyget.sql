SELECT TOP 10 
	cs-host AS HOST,
	EXTRACT_TOKEN(cs-uri-query,0,'|') AS Query,
	STRCAT(cs-uri-stem, REPLACE_IF_NOT_NULL(cs-uri-query,STRCAT('?',Query))) AS URI,
	sc-status AS STATUS,
	cs-method AS VERB,
	count(*) AS TOTAL
INTO Urls.txt
FROM %windir%\system32\logfiles\w3svc1\ex*.log
WHERE cs-method = 'GET' 
GROUP BY HOST, URI, VERB, STATUS, Query
HAVING TOTAL > 500
ORDER BY TOTAL DESC

