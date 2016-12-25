/*
This script parses all the IIS-related log files (IIS log files, HTTPError log files, UrlScan log files) looking for 'suspicious' Url's 
 that might have been sent to compromise the server.
The "HackerScan.txt" file contains a sample of the 'patterns' to search for in Url's. You can add your own patterns to the text file in
 order to look for more specific patterns.
*/



//Create the main Log Parser Query object
var g_LogParser=new ActiveXObject("MSUtil.LogQuery");
	

//Initialize the global counter of hacker attempts
var g_nAttempts=0;

//Check the HTTP Error log files first
DoHTTPERRScan();

//Check the URLScan log files now
DoUrlscanScan();

//Load the HackerScan.txt file
WScript.Echo("Loading the HackerScan file...");
var objFS=new ActiveXObject("Scripting.FileSystemObject");
try
{
	var objFile=objFS.OpenTextFile("HackerScan.txt",1);
	var g_szUrlHackConditions=objFile.ReadAll();
	objFile.Close();
	WScript.Echo("...succesfully loaded.");

	//Check if Centralized Binary Logging is enabled
	var bCentralizedBinaryLogging=false;
	var objW3SVC=GetObject("IIS://localhost/W3SVC");
	try
	{
		bCentralizedBinaryLogging=objW3SVC.CentralBinaryLoggingEnabled;
	}
	catch(e)
	{
		//Most probably this is not IIS6.0
	}

	if(!bCentralizedBinaryLogging)
	{
		//Navigate through all the IIS sites, and query their log files
		try
		{
			for(	var objIISSites=new Enumerator(objW3SVC);
				!objIISSites.atEnd();
				objIISSites.moveNext())
	    		{
				var objIIS=objIISSites.item();
				if (objIIS.Class == "IIsWebServer")
				{
					//Scan this site
					DoSiteScan(objIIS.Name);
				}
			}
		}
		catch(e)
		{
			WScript.Echo("Cannot enumerate the IIS sites on this machine: " + e.description);
		}
	}
	else
	{
		//Scan the IIS Centralized Binary log files
		DoCentralizedBinaryScan();
	}
}
catch(e)
{
	WScript.Echo("Unexpected error: " + e.description);
	WScript.Quit(-1);
}

//Print final report
WScript.Echo(g_nAttempts + " suspicious attempts found.");


//Exit
WScript.Quit(0);


//-------------------------------------------------------------------------------------------------------

function DoHTTPERRScan()
{
	//Create the query text
	var szQuery="SELECT c-ip AS ClientIP, cs-uri AS UriStem, NULL AS UriQuery, sc-status AS StatusCode, COUNT(*) AS Total FROM HTTPERR WHERE s-reason='Url' GROUP BY ClientIP, UriStem, StatusCode";
	try
	{
		WScript.Echo("Scanning HTTPError log files...");

		var recordSet=g_LogParser.Execute(szQuery);
		var nAttempts=0;
		for(;!recordSet.atEnd();recordSet.moveNext())
		{
			var record=recordSet.getRecord();
		 	Output(record);
			nAttempts+=record.getValue(4);
		}

		WScript.Echo("...HTTPError log files scanned. " + nAttempts + " suspicious requests found.");
		recordSet.close();
	}
	catch(e)
	{
		if(e.number!=-2147024894) //File not found
		 WScript.Echo("Unexpected error while scanning the HTTPError log files: " + e.description + " (" + e.number + ")");
		else
		 WScript.Echo("There are no HTTPError log files to scan on this machine.");
	}
}

function DoUrlscanScan()
{
	//Create the query text
	var szQuery="SELECT ClientIP, Url AS UriStem, NULL AS UriQuery, NULL AS StatusCode, COUNT(*) AS Total FROM URLSCAN WHERE Comment LIKE 'URL%' GROUP BY ClientIP, UriStem, StatusCode";
	try
	{
		WScript.Echo("Scanning URLScan log files...");

		var recordSet=g_LogParser.Execute(szQuery);
		var nAttempts=0;
		for(;!recordSet.atEnd();recordSet.moveNext())
		{
			var record=recordSet.getRecord();
		 	Output(record);
			nAttempts+=record.getValue(4);
		}

		WScript.Echo("...URLScan log files scanned. " + nAttempts + " suspicious requests found.");
		recordSet.close();
	}
	catch(e)
	{
		if(e.number!=-2147024894) //File not found
		 WScript.Echo("Unexpected error while scanning the URLScan log files: " + e.description + " (" + e.number + ")");
		else
		 WScript.Echo("There are no URLScan log files to scan on this machine.");
	}
}

function DoCentralizedBinaryScan()
{
	//Create the query text
	var szQuery="SELECT ClientIpAddress AS ClientIP, UriStem, UriQuery, ProtocolStatus, COUNT(*) AS Total FROM %windir%\\system32\\logfiles\\W3SVC\\ra*.ibl WHERE " + g_szUrlHackConditions + " GROUP BY ClientIP, UriStem, UriQuery, ProtocolStatus";

	try
	{
		WScript.Echo("Scanning Centralized Binary log files...");

		var recordSet=g_LogParser.Execute(szQuery);
		var nAttempts=0;
		for(;!recordSet.atEnd();recordSet.moveNext())
		{
			var record=recordSet.getRecord();
		 	Output(record);
			nAttempts+=record.getValue(4);
		}

		WScript.Echo("...Centralized Binary log files scanned. " + nAttempts + " suspicious requests found.");
		recordSet.close();
	}
	catch(e)
	{
		if(e.number!=-2147024894) //File not found
		 WScript.Echo("Unexpected error while scanning the Centralized Binary log files: " + e.description + " (" + e.number + ")");
		else
		 WScript.Echo("There are no Centralized Binary log files to scan on this machine.");
	}
}

function DoSiteScan(szSiteID)
{
	//Get the site object
	var objSite=GetObject("IIS://localhost/W3SVC/" + szSiteID);

	//Get the current log format of this site
	var szLogPluginCLSId=objSite.LogPluginCLSId;

	//Create the SELECT clause text
	var szSelectClause="SELECT ";
	switch(szLogPluginCLSId.toUpperCase())
	{
		case "{FF160663-DE82-11CF-BC0A-00AA006111E0}":	{
									//W3C Format
									szSelectClause+="c-ip AS ClientIP, cs-uri-stem AS UriStem, cs-uri-query AS UriQuery, sc-status AS StatusCode";
									break;
								}

		case "{FF16065F-DE82-11CF-BC0A-00AA006111E0}":	{
									//NCSA Format
									WScript.Echo("NCSA log format is not supported - aborting scan for site " + szSiteID);
									return;
								}

		case "{FF160657-DE82-11CF-BC0A-00AA006111E0}":	{
									//IIS Format
									szSelectClause+="UserIP AS ClientIP, Target AS UriStem, Parameters AS UriQuery, StatusCode";
									break;
								}

		case "{FF16065B-DE82-11CF-BC0A-00AA006111E0}":	{
									//ODBC Format
									szSelectClause+="ClientHost AS ClientIP, Target AS UriStem, Parameters AS UriQuery, ServiceStatus AS StatusCode";
									break;
								}

		default:					{
									WScript.Echo("Unknown log format " + szLogPluginCLSId);
									return;
								}
	}

	//Create the whole query text
	var szQuery=szSelectClause + ", COUNT(*) AS Total FROM <" + szSiteID + "> WHERE " + g_szUrlHackConditions + " GROUP BY ClientIP, UriStem, UriQuery, StatusCode";
	try
	{
		WScript.Echo("Scanning IIS Site " + szSiteID + " log files ...");

		var recordSet=g_LogParser.Execute(szQuery);
		var nAttempts=0;
		for(;!recordSet.atEnd();recordSet.moveNext())
		{
			var record=recordSet.getRecord();
		 	Output(record);
			nAttempts+=record.getValue(4);
		}

		WScript.Echo("...IIS Site " + szSiteID + " log files scanned. " + nAttempts + " suspicious requests found.");
		recordSet.close();
	}
	catch(e)
	{
		if(e.number!=-2147024894) //File not found
		 WScript.Echo("Unexpected error while scanning the IIS Site " + szSiteID + " log files: " + e.description + " (" + e.number + ")");
		else
		 WScript.Echo("There are no IIS Site " + szSiteID + " log files to scan on this machine.");
	}
}



function Output(record)
{
	WScript.Echo(" !!! Client " + record.getValue(0) + ":");
	WScript.Echo("      " + record.getValue(1) + (record.isNull(2)?"":("?" + record.getValue(2))));
	var nAttempts=record.getValue(4);
	WScript.Echo("      Requested " + record.getValue(4) + " time" + (nAttempts>1?"s":"") + (record.isNull(3)?(""):(", rejected with " + record.getValue(3))));

	g_nAttempts+=nAttempts;
}
