SELECT ObjectPath
FROM IIS://localhost/W3SVC
WHERE BIT_AND(AccessFlags, 0x02) <> 0
