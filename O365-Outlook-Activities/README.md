# O365-Outlook-Activities

## Description

This tool leverages the [Office 365 Outlook Activities API](https://www.crowdstrike.com/blog/hiding-in-plain-sight-using-the-office-365-activities-api-to-investigate-business-email-compromises/). It will continuously fetch and write activities to a CSV file until all activities matching the specified criteria have been retrieved.

### Compatibility

This tool supports all versions of Python 3.

### Requirements

 - requests

### Installation

Download activities.py and retriever.py.

### Access token

This tool requires a valid OAuth 2.0 access token. For testing purposes, a token can be obtained from the [Outlook Dev Center - OAuth Sandbox](https://oauthplay.azurewebsites.net). Supply the token to the tool by setting an `OAUTH_TOKEN` environment variable (preferred method) or by including it as a command-line argument. 

### Usage

```
usage: retriever.py --user <username> --output <filename>
                   [--token <token>] [--start <timestamp>]
             	   [--end <timestamp>] [--types <type> [<type> ...]]
 
--user <username>			Target user (user principal name)
--output <filename>			CSV output filename
--token <token>				OAuth access token
--start <timestamp>			Start timestamp (ISO 8601)
--end <timestamp>			End timestamp (ISO 8601)
--types <type> [<type> ...]		Space-delimited list of activity types

```

### Examples

Example 1: Retrieve `MessageDelivered` activities that occurred after January 1:
```
python retriever.py --user victim@contoso.com --output activities.csv --types MessageDelivered --start 2018-01-01T00:00:00Z
```
Example 2: Retrieve `ServerLogon` and `SearchResult` activities that occurred in the month of May:
```
python retriever.py --user victim@contoso.com --output activities.csv --types ServerLogon SearchResult --start 2018-05-01T00:00:00Z --end 2018-05-31T23:59:59Z
```
Example 3: Retrieve the entire history of activities for a user. (NOTE: This may take a long time)
```
python retriever.py --user victim@contoso.com --output activities.csv
```


