SELECT	EXTRACT_EXTENSION( cs-uri-stem ) AS Extension,
	MUL(PROPSUM(sc-bytes),100.0) AS Bytes
INTO Pie.gif
FROM <1>
GROUP BY Extension
ORDER BY Bytes DESC
