SELECT 	QUANTIZE(DateTime, 1) AS Second, 
	SUM(FrameBytes)
FROM myCapture.cap
GROUP BY Second
