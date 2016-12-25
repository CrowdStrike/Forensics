SELECT  EXTRACT_TOKEN(FullUri, 0, '|') AS Uri,
        EXTRACT_TOKEN(cs-uri-query, -1, '|') AS ErrorMsg,
        EXTRACT_TOKEN(cs-uri-query, 1, '|') AS LineNo,
        COUNT(*) AS Total 
USING   STRCAT( cs-uri-stem,
                REPLACE_IF_NOT_NULL(cs-uri-query, STRCAT('?', cs-uri-query))
        ) AS FullUri
FROM ex*.log 
WHERE (sc-status = 500) AND (cs-uri-stem LIKE '%.asp') 
GROUP BY Uri, ErrorMsg, LineNo
ORDER BY Total DESC
