'
'
'This script enables IIS Debug Tracing and uses Log Parser to parse the real-time trace and filter out 
' "Successful Authentication" events.
'
'Whenever a "Successful Authentication" event is published, the script prints out the authenticated user name.
'
'Please note that enabling real-time tracing will slow down the performance of the IIS server.
'
'

Dim strSessionName
Dim strProviderGUID

Dim objWbemLocator
Dim objWbemServicesWMI
Dim objRunningSession
Dim objTraceLogger

Dim objLogParser
Dim objETWInputFormat
Dim objRecordset
Dim objRecord
Dim strQuery

'Name of the ETW tracing session used for monitoring
strSessionName = "LogonMonitorSession"

'GUID of the "IIS: WWW Server" ETW provider
strProviderGUID = "{3a2a4e84-4c21-4981-ae10-3fda0d9b0f83}"

' ----------- Start the event session ----------

Set objWbemLocator = CreateObject("WbemScripting.SWbemLocator")
Set objWbemServicesWMI = objWbemLocator.ConnectServer("", "root\wmi")

' Check if there is already a running session
Set objRunningSession = objWbemServicesWMI.Get("TraceLogger.Name='" & strSessionName & "'")
If Not IsNull(objRunningSession.LogFileName) Then
	WScript.Echo "Another " & strSessionName & " is running; please stop it by running the following command:"
	WScript.Echo "logman stop " & strSessionName & " -ets"
	WScript.Quit -1
End If


' Create a new tracelogger instance
Set objTraceLogger = objWbemServicesWMI.Get("TraceLogger").SpawnInstance_()
objTraceLogger.Name = strSessionName

' Set the TraceLogger properties
objTraceLogger.LogFileMode = "RealTime"
objTraceLogger.Guid = Array(strProviderGUID)
objTraceLogger.EnableFlags = Array(2) 'IISAuthentication
objTraceLogger.Level = Array(4)

' Start session
objWbemServicesWMI.Put objTraceLogger, 2

WScript.Echo "Tracing session """ & strSessionName & """ started."
WScript.Echo "To stop the session, type the following command in a command-line window:"
WScript.Echo "logman stop " & strSessionName & " -ets"



' ----- Start monitoring the event session -----

' Create the main Log Parser COM object
Set objLogParser = CreateObject("MSUtil.LogQuery")

' Create the ETW Input Format object
Set objETWInputFormat = CreateObject("MSUtil.LogQuery.ETWInputFormat")

' Tell the ETW Input Format to use the "full mode" fields, since we need direct access to the fields of the events
objETWInputFormat.fMode = "full"

' Tell the ETW Input Format to just care about the "IIS: WWW Server" provider
objETWInputFormat.providers = strProviderGUID


' Create the query text.
' We only want 'AUTH_SUCCEEDED' events for non-Anonymous logons
strQuery = 	"SELECT AuthUserName FROM " & strSessionName & _
		" WHERE EventTypeName = 'AUTH_SUCCEEDED' AND STRLEN(AuthUserName) > 0"
	

' Execute the query
Set objRecordset = objLogParser.Execute(strQuery, objETWInputFormat)
While Not objRecordset.atEnd()

	' A new "AUTH_SUCCEEDED" event has been published

	' Get the record
	Set objRecord = objRecordset.getRecord()

	' Execute our action
	ExecuteAction objRecord 

	objRecordset.moveNext()
Wend

objRecordset.close()


' This function contains the implementation of the action to be executed when the specified event is published
Sub ExecuteAction(objRecord)

	' Just print out the username
	WScript.Echo "Successful logon: " & objRecord.getValue(0)
End Sub
