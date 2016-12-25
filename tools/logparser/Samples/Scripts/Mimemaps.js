/*
This script parses the supplied log file and finds all the requests rejected with 404.2.
For each rejected requests, if the file extension doesn't match any mimemap currently set for the web server, the user
 is warned that a corresponding mimemap entry should be added to the MimeMaps property.
*/

//Parse arguments first
var szInputLogFilename=null;
var szArgs = WScript.Arguments;

if(szArgs.length<1)
{
	WScript.Echo("Usage:");
	WScript.Echo(" -log:<log_filename>");
	WScript.Quit(-2);
}

for (var i=0; i < 1; i++)
{
	if(szArgs(i).substr(0,5).toLowerCase()=="-log:")
	{
		szInputLogFilename=szArgs(i).substr(5);
	}
	else
	{
		WScript.Echo("Unrecognized argument: " + szArgs(i));
		WScript.Quit(-1);
	}
}

if( szInputLogFilename==null )
{
	WScript.Echo("Not all the parameters have been specified");
	WScript.Quit(-1);
}


//Load the mimemaps
var g_szEnabledExtensions=new ActiveXObject("Scripting.Dictionary");
LoadMimemaps();


//Create the main Log Parser Query object
var myQuery=new ActiveXObject("MSUtil.LogQuery");

//Create the text of the query
//
var szQuery = 	"SELECT  DISTINCT SUBSTR(cs-uri-stem, LAST_INDEX_OF(cs-uri-stem,'.'), STRLEN(cs-uri-stem)) AS Extension," +
		"sc-substatus " +
		"FROM " + szInputLogFilename + " WHERE (sc-status = 404) AND (sc-substatus IS NULL OR sc-substatus=2) ";


//Execute the query and get a recordset
var recordSet=myQuery.Execute(szQuery);

//Walk thru the recordset
var bWarningEmit=false;
for(; !recordSet.atEnd(); recordSet.moveNext())
{
	var record=recordSet.getRecord();

	if(!record.isNull(0))
	{
		var szExtension=record.getValue(0);

		//Check if this extension is in the Mimemaps
		if(!g_szEnabledExtensions.Exists(szExtension))
		{
			WScript.Echo("The extension \"" + szExtension + "\" is not in the server's MimeMap list.");
			bWarningEmit=true;
		}
	}
}

if(!bWarningEmit)
 WScript.Echo("All extensions are in the MimeMap list.");





function LoadMimemaps()
{
	try
	{ 
		var objMimeMap=GetObject("IIS://localhost/MimeMap").Mimemap;
		var arrayMimeMap=(new VBArray(objMimeMap)).toArray();

		for(var m=0;m<arrayMimeMap.length;m++)
		 g_szEnabledExtensions.Add(arrayMimeMap[m].Extension,1);
	}
	catch(e)
	{ 
		WScript.Echo("Error loading the Mimemaps: " + e.description);
		WScript.Quit(-1);
	}
}
