/*
This script generates a report containing all the hits received by any IIS VDir in the specified site.
The optional 'maxdepth' parameter specifies the maximum search depth in the IIS VDir tree.

The script works by basically mapping logged Url's to their corresponding Virtual Directories.
*/


//Parse arguments first
var szSiteID=null;
var nMaxDepth=-1;
var szServerName="localhost";
var szArgs = WScript.Arguments;

if(szArgs.length<1)
{
	WScript.Echo("Usage:");
	WScript.Echo(" -site:<site_id>");
	WScript.Echo(" [ -maxdepth:<max_depth> ]");
	WScript.Echo(" [ -servername:<server_name> ]");
	WScript.Quit(-2);
}

for (var i=0; i < szArgs.length; i++)
{
	if(szArgs(i).substr(0,6).toLowerCase()=="-site:")
	{
		szSiteID=szArgs(i).substr(6);
	}
	else
	if(szArgs(i).substr(0,10).toLowerCase()=="-maxdepth:")
	{
		nMaxDepth=parseInt(szArgs(i).substr(10));
	}
	else
	if(szArgs(i).substr(0,12).toLowerCase()=="-servername:")
	{
		szServerName=szArgs(i).substr(12);
	}
	else
	{
		WScript.Echo("Unrecognized argument: " + szArgs(i));
		WScript.Quit(-1);
	}
}

if( szSiteID==null || nMaxDepth==null )
{
	WScript.Echo("Not all the parameters have been specified");
	WScript.Quit(-1);
}


//Create VDir tree
WScript.Echo("Storing current VDir tree for site /" + szServerName + "/" + szSiteID + "...");
var g_tree=new Array(0);
var szRootPath="IIS://" + szServerName + "/W3SVC/" + szSiteID + "/ROOT";
var objRoot=GetObject(szRootPath);
CreateTree(g_tree, objRoot, 0, nMaxDepth);
WScript.Echo("...done.");

//Do the work
DoQuery(szServerName, szSiteID);

//Dump the tree count result
WScript.Echo("\r\nHit results:");
DumpTree(g_tree, " ");

//Exit
WScript.Quit(0);



/*
This function stores an in-memory representation of the IIS virtual directories and web directories tree.
Each 'node' in the tree is an array structured in the following way:
	0 	- Node name
	1 	- Hits received by this node 
	2..N 	- Child nodes of this node
*/
function CreateTree(tree, objVDir, nDepth, nMaxDepth)
{
	var szIndent=" ";
	for(var d=0;d<nDepth;d++)
	 szIndent+=" ";
	WScript.Echo(szIndent + "Storing child VDir \"" + objVDir.Name + "\"");

	//Save node name
	tree[0]=objVDir.Name;

	//Init hit counter
	tree[1]=0;

	if(nMaxDepth==-1 || nDepth<nMaxDepth)
	{
		//Get all child VDirs and recursively add them to the tree

		for(	var objChildNodes=new Enumerator(objVDir);
			!objChildNodes.atEnd();
			objChildNodes.moveNext())
		{
			var objChildNode=objChildNodes.item();
			if ( objChildNode.Class == "IIsWebVirtualDir" ||
			     objChildNode.Class == "IIsWebDirectory" )
			{
				//Store this child node
				var child=new Array();
				CreateTree(child, objChildNode, nDepth+1, nMaxDepth);
				tree[tree.length]=child;
			}
		}
	}
}

function DoQuery(szServerName, szSiteID)
{
	//Create the main Log Parser Query object
	var myQuery=new ActiveXObject("MSUtil.LogQuery");

	//Get the site object
	var objSite=GetObject("IIS://" + szServerName + "/W3SVC/" + szSiteID);

	//Get the current log format of this site
	var szLogPluginCLSId=objSite.LogPluginCLSId;

	//Create the SELECT clause text
	var szSelectClause="SELECT ";
	var szWhereClause="WHERE ";
	switch(szLogPluginCLSId.toUpperCase())
	{
		case "{FF160663-DE82-11CF-BC0A-00AA006111E0}":	{
									//W3C Format
									szSelectClause+="cs-uri-stem AS UriStem";
									szWhereClause+="sc-status<400 AND cs-uri-stem IS NOT NULL";
									break;
								}

		case "{FF16065F-DE82-11CF-BC0A-00AA006111E0}":	{
									//NCSA Format
									WScript.Echo("NCSA log format is not supported - aborting query for site " + szSiteID);
									return;
								}

		case "{FF160657-DE82-11CF-BC0A-00AA006111E0}":	{
									//IIS Format
									szSelectClause+="Target AS UriStem";
									szWhereClause+="StatusCode<400 AND Target IS NOT NULL";
									break;
								}

		case "{FF16065B-DE82-11CF-BC0A-00AA006111E0}":	{
									//ODBC Format
									szSelectClause+="Target AS UriStem";
									szWhereClause+="ServiceStatus<400 AND Target IS NOT NULL";
									break;
								}

		default:					{
									WScript.Echo("Unknown log format " + szLogPluginCLSId);
									return;
								}
	}


	WScript.Echo("\r\nQuerying the log files for site /" + szServerName + "/" + szSiteID + "...");

	try
	{
		//Execute the query and get a recordset
		var recordSet=myQuery.Execute(szSelectClause + ", COUNT(*) AS Total FROM </" + szServerName + "/W3SVC/" + szSiteID + "> " + szWhereClause + " GROUP BY UriStem");

		//Walk thru the recordset
		for(; !recordSet.atEnd(); recordSet.moveNext())
		{
			var record=recordSet.getRecord();

			try
			{
				//Break the url into components
				var szUrlComponents=record.getValue(0).split("/");

				//Update the tree count
				UpdateTreeCount(g_tree, 0, szUrlComponents, record.getValue(1));
			}
			catch(e)
			{
				WScript.Echo("Unexpected error processing Url \"" + record.getValue(0) + "\": " + e.description);
			}
		}

		recordSet.close();		
		WScript.Echo("...done.");
	}
	catch(e)
	{
		WScript.Echo("Error querying the log files: " + e.description);
		WScript.Quit(-1);
	}
}


/* 
This function finds the node corresponding to the requested Url, and updates its Hit count.
*/
function UpdateTreeCount(tree, nDepth, szUrlComponents, nCount)
{
	//Check if it's a child node
	for(var c=2; c<tree.length; c++)
	{
		if(szUrlComponents[nDepth+1].toLowerCase()==tree[c][0].toLowerCase())
	 	{
			//It's for this child node...
			UpdateTreeCount(tree[c], nDepth+1, szUrlComponents, nCount);

			break;
	 	}
	}

	if(c==tree.length)
	{
		//It's for this node...update the count
		tree[1]+=nCount;
	}
}

function DumpTree(tree, szIndent)
{
	WScript.Echo(szIndent + "/" + tree[0] + ":   " + tree[1]);

	//Dump child nodes
	for(var c=2;c<tree.length;c++)
	 DumpTree(tree[c], szIndent + "/" + tree[0]);
}