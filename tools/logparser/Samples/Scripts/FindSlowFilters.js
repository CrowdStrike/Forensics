/*
This script parses an IIS trace log generated on Windows Server 2003 RTM or Windows Server 2003 SP1, calculating
 the amount of milliseconds spent by requests in each ISAPI filter.
The script prints the name of those filters whose executions took longer than a specified number of milliseconds.
*/


//Parse arguments first

var args = WScript.Arguments;
if(args.length != 2)
{
	WScript.Echo("Usage: FindSlowFilters <etl_filename> <msec_threshold>\r\n");
	WScript.Quit(-1);
}

var szETLFile = args(0);
var nThreshold;
try
{
	nThreshold = parseInt(args(1));
}
catch(e)
{
	WScript.Echo("ERROR: invalid <msec_threshold>: " + args(1));
	WScript.Quit(-1);
}


//Create Log Parser main Query object
var objLogQuery = new ActiveXObject("MSUtil.LogQuery");

//Create ETW input format
var objETWInputFormat = new ActiveXObject("MSUtil.LogQuery.ETWInputFormat");

//Set 'compact' field mode
objETWInputFormat.fMode = "compact";

//Create query
var szQuery = "SELECT Timestamp, EXTRACT_TOKEN(UserData, 1, '|') AS FilterName, EventTypeName, EXTRACT_TOKEN(UserData, 0, '|') AS ContextID, EventNumber ";
szQuery += "FROM " + szETLFile;
szQuery += " WHERE (EventName='W3Filter' AND (EventTypeName='Start' OR EventTypeName='End')) OR (EventName='IISFilter' AND (EventTypeName='FILTER_START' OR EventTypeName='FILTER_END'))";
szQuery += " ORDER BY ContextID, EventNumber";

//Execute query
var objRecordSet = objLogQuery.Execute(szQuery, objETWInputFormat);

for(; !objRecordSet.atEnd(); )
{

	var objRecord1 = objRecordSet.getRecord();
	var szEventTypeName1 = objRecord1.getValue(2);
	if(szEventTypeName1=="Start" || szEventTypeName1=="FILTER_START")
	{
		//Get next record
		objRecordSet.moveNext();
		if(objRecordSet.atEnd())
		{
			break;
		}
		var objRecord2 = objRecordSet.getRecord();

		//Check if it's an 'END' event
		var szEventTypeName2 = objRecord2.getValue(2);
		if(szEventTypeName2 == "End" || szEventTypeName2 == "FILTER_END")
		{
			//Calculate milliseconds difference
			var deltaMS = new Date(objRecord2.getValue(0)).valueOf() - new Date(objRecord1.getValue(0)).valueOf();
			if(deltaMS>=nThreshold)
			{
				WScript.Echo(deltaMS + "ms: " + objRecord1.getValue(1));
			}
		}
	}
	else
	{
		objRecordSet.moveNext();
	}
}
