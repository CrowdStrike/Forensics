SELECT DISTINCT	cs(Referer) as Referer,
		cs-uri-stem as Url
INTO ReferBrokenLinks.html
FROM ex*.log
WHERE cs(Referer) IS NOT NULL AND sc-status=404 AND (sc-substatus IS NULL OR sc-substatus=0)

