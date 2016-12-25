SELECT 	STRCAT(	EXTRACT_TOKEN(	Strings,
				1,
				'|'),
		STRCAT(	'\\',
			EXTRACT_TOKEN(	Strings,
					0,
					'|'
					)
			)
		) AS User,
		COUNT(*) AS Total 
FROM Security 
WHERE EventType = 16 AND EventCategory = 2 
GROUP BY User 
ORDER BY Total DESC
