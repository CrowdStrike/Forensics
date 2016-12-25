SELECT
	COUNT(EventID) AS TotalLogonFailures,
	TO_LOWERCASE(EXTRACT_TOKEN(Strings,0,'|')) AS User,
	TO_LOWERCASE(EXTRACT_TOKEN(Strings,1,'|')) AS Domain,
	TO_LOWERCASE(EXTRACT_TOKEN(Strings,5,'|')) AS WorkStation,
	CASE TO_INT(EXTRACT_TOKEN(Strings,2,'|')) 
		WHEN 2 THEN  'Interactive - Intended for users who will be interactively using the machine, such as a user being logged on by a terminal server, remote shell, or similar process.'
		WHEN 3 THEN  'Network - Intended for high performance servers to authenticate clear text passwords. LogonUser does not cache credentials for this logon type.'
		WHEN 4 THEN  'Batch - Intended for batch servers, where processes may be executing on behalf of a user without their direct intervention; or for higher performance servers that process many clear-text authentication attempts at a time, such as mail or web servers. LogonUser does not cache credentials for this logon type.'
		WHEN 5 THEN  'Service - Indicates a service-type logon. The account provided must have the service privilege enabled.'
		WHEN 6 THEN  'Proxy - Indicates a proxy-type logon.'
		WHEN 7 THEN  'Unlock - This logon type is intended for GINA DLLs logging on users who will be interactively using the machine. This logon type allows a unique audit record to be generated that shows when the workstation was unlocked.'
		WHEN 8 THEN  'NetworkCleartext - Windows 2000; Windows XP and Windows Server 2003 family:  Preserves the name and password in the authentication packages, allowing the server to make connections to other network servers while impersonating the client. This allows a server to accept clear text credentials from a client, call LogonUser, verify that the user can access the system across the network, and still communicate with other servers.'
		WHEN 9 THEN  'NewCredentials - Windows 2000; Windows XP and Windows Server 2003 family:  Allows the caller to clone its current token and specify new credentials for outbound connections. The new logon session has the same local identity, but uses different credentials for other network connections.'
		WHEN 10 THEN 'RemoteInteractive - Terminal Server session that is both remote and interactive.'
		WHEN 11 THEN 'CachedInteractive - Attempt cached credentials without accessing the network.'
		WHEN 12 THEN 'CachedRemoteInteractive - Same as RemoteInteractive. This is used for internal auditing.'
		WHEN 13 THEN 'CachedUnlock - Workstation logon'
		ELSE EXTRACT_TOKEN(Strings,2,'|')
	END AS Type
INTO DATAGRID
FROM \\%machine%\security
WHERE EventID IN (529)
GROUP BY User,Domain,WorkStation,Type
ORDER BY TotalLogonFailures DESC