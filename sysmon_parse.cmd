@echo off
CLS
REM ------------------------------------------------------------------------------------------------------------------------
REM Sysmon_Parse v0.1
REM by Matt Churchill (matt.churchill@crowdstrike.com)
REM
REM About:
REM Script to automate parsing of the event log for Microsoft's Sysinternal tool Sysmon.
REM Sysmon Download and Info: http://technet.microsoft.com/en-us/sysinternals/dn798348
REM 
REM System Requirements: Python 2.7, .NET 4.5
REM 
REM Additional Tools Needed:
REM Microsoft Log Parser, http://www.microsoft.com/en-us/download/details.aspx?id=24659
REM TekCollect.py, http://www.tekdefense.com/tekcollect/
REM IPNetInfo, http://www.nirsoft.net/utils/ipnetinfo.html
REM virustotalchecker, http://www.woanware.co.uk/forensics/virustotalchecker.html
REM 
REM Folder Structure:
REM		- Main Directory containing sysmon_parse.cmd and sysmon_keywords.txt
REM			- tools
REM				- ipnetinfo
REM				- logparser
REM				- tekcollect
REM				- virustotalchecker
REM ------------------------------------------------------------------------------------------------------------------------
REM Syntax:
REM sysmon_parse.cmd (file name optional)
REM
REM If no file name is supplied, the script will copy the Sysmon Event Log from the current running system.
REM The Sysmon Event Log is stored here: C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx
REM The option to supply an event log is given to parse logs from other machines.
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Setup:
REM Set base folder, set input source file if needed, and make Results directory.
SET scriptlocation=%~dp0
SET src=%1
SET dtstamp=%date:~-4%%date:~4,2%%date:~7,2%
mkdir Results_%dtstamp%
IF EXIST %src% GOTO parse
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Copy Sysmon Event Log from running system.
for /f %%i in (hosts.txt) do copy \\%%i\c$\Windows\System32\winevt\Logs\*sysmon*.evtx %scriptlocation%Results_%dtstamp%\%%i_*.evtx
SET src=%scriptlocation%Results_%dtstamp%\*.evtx
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Parse Sysmon Event Log to flat text file.
CLS
:parse
REM Parse Sysmon Event Log using Microsoft's Logparser
REM http://www.microsoft.com/en-us/download/details.aspx?id=24659
ECHO Sysmon Log Copied, Now Parsing
tools\logparser\logparser -i:evt -o:csv "Select RecordNumber,TO_UTCTIME(TimeGenerated),EventID,SourceName,ComputerName,SID,Strings from %src% WHERE EventID in ('1';'2';'3';'4';'5';'6';'7';'8')" >> Results_%dtstamp%\sysmon_parsed.txt
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Remove copied Sysmon Event Log as it is no longer needed.
REM del %scriptlocation%Results_%dtstamp%\*.evtx
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Extract Information from text file using TekDefense's tekcollect.py tool.
REM http://www.tekdefense.com/tekcollect/
ECHO ..Log Parsed, Now Extracting Data
cd tools\tekcollect
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t MD5 >> %scriptlocation%Results_%dtstamp%\MD5Hashes.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t SHA1 >> %scriptlocation%Results_%dtstamp%\Sha1Hashes.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t SHA256 >> %scriptlocation%Results_%dtstamp%\SHA256Hashes.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t domain >> %scriptlocation%Results_%dtstamp%\Domains.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t url >> %scriptlocation%Results_%dtstamp%\URL.txt
ECHO begin > %scriptlocation%Results_%dtstamp%\IPs.txt
ECHO verbose >> %scriptlocation%Results_%dtstamp%\IPs.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t ip4 >> %scriptlocation%Results_%dtstamp%\IPs.txt
ECHO end >> %scriptlocation%Results_%dtstamp%\IPs.txt
python tekcollect.py -f %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt -t exe >> %scriptlocation%Results_%dtstamp%\Executables.txt
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM This section uses a list of terms contained in "sysmon_keywords.txt" to search the parsed Sysmon results 
REM and add them to a separate CSV file. Add any extra terms to sysmon_keywords.txt in order to search for them here. 
cd %scriptlocation%
Echo ....Searching for Keywords
findstr /G:sysmon_keywords.txt %scriptlocation%Results_%dtstamp%\sysmon_parsed.txt >> %scriptlocation%Results_%dtstamp%\Keywords.csv
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Begin some automated analysis on extracted data
ECHO ......Launching Analysis Tools
REM ------------------------------------------------------------------------------------------------------------------------
REM This section left in script for those who want to send lookups through Cymru. The results will be faster, stored in a text file, but not as robust as with IPNetInfo.
REM https://www.team-cymru.org/Services/ip-to-asn.html#whois
REM Results are saved to delimited file and can be sorted by Country, Owner Name, Resolved Name, etc.
REM cd %scriptlocation%tools\nc
REM ncat.exe whois.cymru.com 43 < %scriptlocation%Results_%dtstamp%\IPs.txt >> %scriptlocation%Results_%dtstamp%\Whois_Results.txt
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Using NirSoft's IPNetInfo GUI Tool for bulk Whois
REM http://www.nirsoft.net/utils/ipnetinfo.html
REM A large number of IPs on intial import may cause the tool to abort and lookups need to be completed manually by breaking into sections or reverting to using the above WhoIs lookup tool.
REM Results can be saved to CSV and sorted by Country, Owner Name, Resolved Name, etc.
START %scriptlocation%tools\ipnetinfo\ipnetinfo.exe /ipfile %scriptlocation%Results_%dtstamp%\IPs.txt
REM
REM ------------------------------------------------------------------------------------------------------------------------
REM Using woanware's virustotalchecker
REM http://www.woanware.co.uk/forensics/virustotalchecker.html
REM Remember to add your VirusTotal API Key to the Settings.xml file.
REM Sysmon can track MD5, SHA1, or SHA256 hashes. Be sure to pick the hash file Sysmon is using. In this example it is SHA256.
REM cd %scriptlocation%tools\virustotalchecker
REM START virustotalchecker.exe -m c -f %scriptlocation%Results_%dtstamp%\MD5Hashes.txt -o %scriptlocation%Results_%dtstamp%
REM
REM ------------------------------------------------------------------------------------------------------------------------
cd %scriptlocation%
REM End script
ECHO ........Check Parsing Output!
ECHO Analysis Tip: Open "sysmon_parsed.txt" with Excel, delimited file by "," and "|".
ECHO For Event Type 1 (New Process Created), check Column K for Command Line used.
