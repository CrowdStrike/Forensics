SELECT 	Path,
	Size
FROM C:\*.*
WHERE NOT Attributes LIKE '%D%' AND Attributes LIKE '%H%'
ORDER BY Size DESC
