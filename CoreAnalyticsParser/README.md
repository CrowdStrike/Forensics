# CoreAnalyticsParser

## Purpose

This is a simple script that collates CoreAnalytics data (evidence of program execution) from .core_analytics files and aggregate files into CSV or JSON to make analysis of this artifact more efficient. 

## Requirements

This artifact only exists on macOS 10.13 and above. If you are attempting to test this script on your local machine, ensure that this OS requirement is met, and that you are running the script as sudo in order to capture aggregates data (which resides in /private/var/db/analyticsd/aggregates/). Please also ensure that pytz and dateutil have been installed on the system on which you are running the script.

## Compatibility

This script supports Python 2.7.

## Requirements

	- dateutil.parser
	- pytz

## Usage

At its simplest, you can run CoreAnalyticsParser against your local machine with the following invocation:
	
	sudo CoreAnalyticsParser.py -d 

The script will output a file named "CoreAnalyticsParser_output.csv" to the current working directory from which the script is called.

If you have collected these files and the aggregate files from an image, it is possible to point the script at a flat directory that contains all files you would like to analyze (both .core_analytics and aggregate files) with the -i/--input flag. The output directory can be specified with the -o/--outputdir flag.
	
	CoreAnalyticsParser.py -i /path/to/core_analytics_files -o /path/to/outputdir

If you would like the script to output JSON rather than CSV (the default), use the -j/--json flag. 

	sudo CoreAnalyticsParser.py -d -o /path/to/outputdir -j	

## Output

A JSON record from the script's output may appear as below. This record includes all fields that are included per record by default.

	{   'src_report': '/path/to/Analytics_2018-06-29-173717_ML-C02PA037R9QZ.core_analytics',
    	'diag_start': '2018-06-29T00:00:09Z',
    	'diag_end': '2018-06-30T00:37:17.660000Z',
    	'name': 'comappleosanalyticsappUsage',
    	'uuid': '4d7c9e4a-8c8c-4971-bce3-09d38d078849',
    	'processName': 'Google Chrome',
    	'appDescription': 'com.google.Chrome ||| 67.0.3396.87 (3396.87)',
    	'appName': 'com.google.Chrome',
    	'appVersion': '67.0.3396.87 (3396.87)',
    	'foreground': 'YES',
    	'uptime': '26110',
    	'uptime_parsed': '7:15:10',
    	'powerTime': '12537',
    	'powerTime_parsed': '3:28:57',
    	'activeTime': '4250',
    	'activeTime_parsed': '1:10:50',
    	'activations': '105',
    	'launches': '0',
    	'activityPeriods': '12',
    	'idleTimeouts': '4',
    	'overflow': ''}

