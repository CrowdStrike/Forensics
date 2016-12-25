SELECT 	Text,
	COUNT(*) AS Total
FROM C:\*.txt
GROUP BY Text
ORDER BY Total DESC