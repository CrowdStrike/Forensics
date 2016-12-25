/*
This script prints an HTML table containing all the single <Request, StatusCode> pairs and the number of times they appear 
	in the specified IIS W3C log file.
In order for this example to work properly, the IIS W3C log file must have been configured to log the sc-substatus field.
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


//Create the main Log Parser Query object
var myQuery=new ActiveXObject("MSUtil.LogQuery");

//Create the text of the query
var szQuery = 	"SELECT STRCAT(cs-uri-stem, REPLACE_IF_NOT_NULL(cs-uri-query, STRCAT('?', cs-uri-query))) AS Request, " +
		"STRCAT(TO_STRING(sc-status), STRCAT('.', TO_STRING(sc-substatus))) AS Status, COUNT(*) AS Total " +
		"FROM " + szInputLogFilename + " WHERE (sc-status >= 400) AND (sc-substatus IS NOT NULL) " +
		"GROUP BY Status, Request " +
		"ORDER BY Total DESC";


//Execute the query and get a recordset
var recordSet=myQuery.Execute(szQuery);


//Print out the HTML table header
WScript.Echo("<TABLE border=1><TR><TH colspan=4>Failures by statuscode</TH></TR>");
WScript.Echo("<TR><TH>Requested URL</TH><TH>Status Code</TH><TH>Status Description</TH><TH>Hits</TH></TR>");

//Walk thru the recordset
for(; !recordSet.atEnd(); recordSet.moveNext())
{
	//Retrieve the values

	var record=recordSet.getRecord();
	WScript.Echo("<TR>");
	WScript.Echo("<TD>" + record.GetValue(0) + "</TD>");
	WScript.Echo("<TD>" + record.GetValue(1) + "</TD>");
	WScript.Echo("<TD>" + StatusToDesc(record.GetValue(1)) + "</TD>");
	WScript.Echo("<TD>" + record.GetValue(2) + "</TD>");
	WScript.Echo("</TR>");
}

//Print out the HTML table footer
WScript.Echo("</TABLE>");









function StatusToDesc(status)
	{
	switch(status)
		{

		case "400.0": 
 			return "Bad Request:";

		case "401.1": 
 			return "Unauthorized:Logon failed";

		case "401.2": 
 			return "Unauthorized:Logon failed due to server configuration";

		case "401.3": 
 			return "Unauthorized:Unauthorized due to ACL on resource";

		case "401.4": 
 			return "Unauthorized:Authorization failed by filter";

		case "401.5": 
 			return "Unauthorized:Authorization failed by ISAPI/CGI app";

		case "401.7": 
 			return "Unauthorized:Denied due to URL Authorization policy";

		case "403.1": 
 			return "Forbidden:Execute access denied";

		case "403.2": 
 			return "Forbidden:Read access denied";

		case "403.3": 
 			return "Forbidden:Write access denied";

		case "403.4": 
 			return "Forbidden:SSL required";

		case "403.5": 
 			return "Forbidden:SSL128 required";

		case "403.6": 
 			return "Forbidden:IP address rejected";

		case "403.7": 
 			return "Forbidden:Client certificate required";

		case "403.8": 
 			return "Forbidden:Site access denied";

		case "403.9": 
 			return "Forbidden:Too many users";

		case "403.10": 
 			return "Forbidden:Invalid Configuration";

		case "403.11": 
 			return "Forbidden:Password Change";

		case "403.12": 
 			return "Forbidden:Mapper Denied Access";

		case "403.13": 
 			return "Forbidden:Client certificate revoked";

		case "403.14": 
 			return "Forbidden:Directory Listing Denied";

		case "403.15": 
 			return "Forbidden:Client Access Licenses Exceeded";

		case "403.16": 
 			return "Forbidden:Client certificate untrusted or ill-formed";

		case "403.17": 
 			return "Forbidden:Client certificate has expired or is not yet valid";

		case "403.18": 
 			return "Forbidden:Cannot execute request from this application pool";

		case "403.19": 
 			return "Forbidden:CGI Access denied";

		case "403.20": 
 			return "Forbidden:Passport Login failed";

		case "404.0": 
 			return "Not Found:";

		case "404.2": 
 			return "Not Found:Denied due to Lockdown Policy";

		case "404.3": 
 			return "Not Found:Denied due to MIMEMAP Policy";

		case "405.0": 
 			return "Method Not Allowed:";

		case "406.0": 
 			return "Not Acceptable:";

		case "407.0": 
 			return "Proxy Authentication Required:";

		case "412.0": 
 			return "Precondition Failed:";

		case "414.0": 
 			return "Request-URI Too Long:";

		case "415.0": 
 			return "Unsupported Media Type:";

		case "500.0": 
 			return "Internal Server Error:";

		case "500.12": 
 			return "Internal Server Error:Application restarting";

		case "500.13": 
 			return "Internal Server Error:Server too busy";

		case "500.15": 
 			return "Internal Server Error:Direct requests for GLOBAL.ASA forbidden";

		case "500.16": 
 			return "Internal Server Error:UNC Access Error";

		case "500.17": 
 			return "Internal Server Error:URL Authorization store not found";

		case "500.18": 
 			return "Internal Server Error:URL Authorization store cannot be opened";

		case "500.19": 
 			return "Internal Server Error:Bad file metadata";

		case "500.100": 
 			return "Internal Server Error:ASP error";

		case "501.0": 
 			return "Not Implemented:";

		case "502.0": 
 			return "Bad Gateway:";

		default:
			return "unknown";
		}
	}
