#!/usr/bin/env python2

'''
@ author: Kshitij Kumar
@ email: kshitij.kumar@crowdstrike.com

'''
import sys
import json
import csv
import pytz
import glob
import argparse
import time
import os
import dateutil.parser as parser
from collections import OrderedDict


class data_writer:

    def __init__(self, name, headers, datatype, outputdir='./'):
        self.name = name
        self.datatype = datatype
        self.headers = headers
        self.output_filename = self.name+'.'+self.datatype
        self.data_file_name = os.path.join(outputdir, self.output_filename)

        if self.datatype == 'csv':
            with open(self.data_file_name, 'w') as data_file:
                writer = csv.writer(data_file)
                writer.writerow(headers)
        elif self.datatype == 'json':
            with open(self.data_file_name, 'w') as data_file:
                pass

    def write_entry(self, data):
        if self.datatype == 'csv':
            with open(self.data_file_name, 'a') as data_file:
                writer = csv.writer(data_file)
                writer.writerow(data)
        elif self.datatype == 'json':
            zipped_data = dict(zip(self.headers, data))
            with open(self.data_file_name, 'a') as data_file:
                json.dump(zipped_data, data_file)
                data_file.write('\n')


def stat(file):
    os.environ['TZ'] = 'UTC0'

    stat = os.lstat(file)
    mtime = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(stat.st_mtime))
    atime = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(stat.st_atime))
    ctime = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(stat.st_ctime))
    btime = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(stat.st_birthtime))

    return({'mtime': mtime, 'atime': atime, 'ctime': ctime, 'btime': btime})


def CoreAnalyticsParser():
    aparser = argparse.ArgumentParser(
        description="CoreAnalyticsParser.py: a script to parse core_analytics files to csv - \
        an artifact of Mach-O file execution that retains up to one month of data. This \
        artifact is only avalable on macOS 10.13 and higher."
        )
    mutu = aparser.add_mutually_exclusive_group(required=True)
    mutu.add_argument('-i', '--input', default='./', help='input file or directory containing \
                      core_analytics files and/or aggregate files', required=False)
    mutu.add_argument('-d', '--disk', default=False, help='parse all core_analytics files and \
                       aggregates on current disk', required=False, action='store_true')
    aparser.add_argument('-o', '--outputdir', default='./', help='output directory', required=False)
    aparser.add_argument('-j', '--json', default=False, help='produce output in JSON format',
                         required=False, action='store_true')
    args = aparser.parse_args()

    outfile_loc = os.path.join(args.outputdir, 'CoreAnalyticsParser_output')

    headers = ['src_report', 'diag_start', 'diag_end', 'name', 'uuid', 'processName',
               'appDescription', 'appName', 'appVersion', 'foreground', 'uptime',
               'uptime_parsed', 'powerTime', 'powerTime_parsed', 'activeTime', 'activeTime_parsed',
               'activations', 'launches', 'activityPeriods', 'idleTimeouts', 'Uptime',
               'Count', 'version', 'identifier', 'overflow']

    if args.json:
        fmt = 'json'
    else:
        fmt = 'csv'

    output = data_writer('CoreAnalyticsParser_output', headers, fmt, args.outputdir)

    if os.geteuid() != 0:
        print ("[!] Running script without sudo, but trying to parse files on local disk.")
        print ("    Parsing of aggregate files may fail!")

    # Parse .core_analytics files from input locaation or from their directory on disk.
    if args.disk:
        analytics_location = glob.glob('/Library/Logs/DiagnosticReports/Analytics*.core_analytics')
    elif args.input and not args.input.endswith('.core_analytics'):
        analytics_location = glob.glob(args.input+'/Analytics*.core_analytics')
    elif args.input and args.input.endswith('.core_analytics'):
        analytics_location = [args.input]

    if len(analytics_location) < 1:
        print ("[!] No .core_analytics files found.")
    else:
        print ("[+] Found {0} .core_analytics files to parse.".format(len(analytics_location)))

    counter = 0
    for file in analytics_location:
        data = open(file, 'r').read()
        data_lines = [json.loads(i) for i in data.split('\n') if i.startswith("{\"message\":")]

        try:
            diag_start = [json.loads(i) for i in data.split('\n') if
                          i.startswith("{\"_marker\":") and "end-of-file"
                          not in i][0]['startTimestamp']
        except ValueError:
            diag_start = "ERROR"

        try:
            diag_end = [json.loads(i) for i in data.split('\n') if
                        i.startswith("{\"timestamp\":")][0]['timestamp']
            diag_end = str(parser.parse(diag_end).astimezone(pytz.utc))
            diag_end = diag_end.replace(' ', 'T').replace('+00:00', 'Z')
        except ValueError:
            diag_end = "ERROR"

        for i in data_lines:
            record = OrderedDict((h, '') for h in headers)
            record['src_report'] = file
            record['diag_start'] = diag_start
            record['diag_end'] = diag_end
            record['name'] = i['name']
            record['uuid'] = i['uuid']

            # If any fields not currently recorded (based on the headers above) appear,
            # they will be added to overflow.
            record['overflow'] = {}

            for k, v in i['message'].items():
                if k in record.keys():
                    record[k] = i['message'][k]
                else:
                    record['overflow'].update({k: v})

            if len(record['overflow']) == 0:
                record['overflow'] = ''

            if record['uptime'] != '':
                record['uptime_parsed'] = time.strftime("%H:%M:%S",
                                                        time.gmtime(record['uptime']))

            if record['activeTime'] != '':
                record['activeTime_parsed'] = time.strftime("%H:%M:%S",
                                                            time.gmtime(record['activeTime']))

            if record['powerTime'] != '':
                record['powerTime_parsed'] = time.strftime("%H:%M:%S",
                                                           time.gmtime(record['powerTime']))

            if record['appDescription'] != '':
                record['appName'] = record['appDescription'].split(' ||| ')[0]
                record['appVersion'] = record['appDescription'].split(' ||| ')[1]

            line = record.values()
            output.write_entry(line)
            counter += 1

    # Parse aggregate files either from input location or from their directory on disk.
    if args.disk:
        agg_location = glob.glob('/private/var/db/analyticsd/aggregates/*')
    elif args.input:
        agg_location = [i for i in glob.glob(args.input+'/*-*-*-*') if '.' not in i]

    if len(agg_location) < 1:
        print ("[!] No aggregate files found.")
    else:
        print ("[+] Found {0} aggregate files to parse.".format(len(agg_location)))

    for aggregate in agg_location:
        data = open(aggregate, 'r').read()
        data_lines = json.loads(data)

        diag_start = stat(aggregate)['btime']
        diag_end = stat(aggregate)['mtime']

        raw = [i for i in data_lines if len(i) == 2 and (len(i[0]) == 3 and len(i[1]) == 7)]
        for i in raw:
            record = OrderedDict((h, '') for h in headers)

            record['src_report'] = aggregate
            record['diag_start'] = diag_start
            record['diag_end'] = diag_end
            record['uuid'] = os.path.basename(aggregate)
            record['processName'] = i[0][0]

            record['appDescription'] = i[0][1]
            if record['appDescription'] != '':
                record['appName'] = record['appDescription'].split(' ||| ')[0]
                record['appVersion'] = record['appDescription'].split(' ||| ')[1]

            record['foreground'] = i[0][2]

            record['uptime'] = i[1][0]
            record['uptime_parsed'] = time.strftime("%H:%M:%S", time.gmtime(i[1][0]))

            record['activeTime'] = i[1][1]
            record['activeTime_parsed'] = time.strftime("%H:%M:%S", time.gmtime(i[1][1]))

            record['launches'] = i[1][2]
            record['idleTimeouts'] = i[1][3]
            record['activations'] = i[1][4]
            record['activityPeriods'] = i[1][5]

            record['powerTime'] = i[1][6]
            record['powerTime_parsed'] = time.strftime("%H:%M:%S", time.gmtime(i[1][6]))

            line = record.values()
            output.write_entry(line)
            counter += 1

    if counter > 0:
        print ("[+] Wrote {0} lines to {1}.{2}.".format(counter, outfile_loc, fmt))
    else:
        print ("[!] No output file generated.")


if __name__ == "__main__":

    CoreAnalyticsParser()
