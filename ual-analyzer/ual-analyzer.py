#!/usr/bin/env python

import argparse
import csv
import json

from plugins.enrichers import Enricher
from plugins.parsers import Parser


WORKLOADS = ['Exchange', 'AzureActiveDirectory']

EXCLUDED_USERS = ['S-1-5-18', 'NT AUTHORITY\SYSTEM', 'DevilFish',
                  'Microsoft Operator']

OUTPUT_FIELDS = ['Time', 'Action', 'Workload', 'User', 'Status', 'Client_IP',
                 'Client_Type', 'User_Agent', 'Address', 'Country', 'Region',
                 'City', 'Data']

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('--input', required=True)
arg_parser.add_argument('--output', required=True)
args = arg_parser.parse_args()

events = []

# Open input file
with open(args.input) as input_file:
    reader = csv.DictReader(input_file)
    for row in reader:
        event = {}

        try:
            audit_data = json.loads(row['AuditData'])
        except json.decoder.JSONDecodeError:
            continue

        if WORKLOADS and not audit_data.get('Workload') in WORKLOADS:
            continue

        if any(user in row['UserIds'] for user in EXCLUDED_USERS):
            continue

        # Normalize event
        for prop, value in audit_data.items():

            if prop in ['Parameters', 'ExtendedProperties'] \
                    and type(value) is list:
                for extended_prop in value:
                    event.setdefault('ExtendedProperties', {})[
                            extended_prop['Name']] = extended_prop['Value']
            else:
                event[prop] = value
        
        # Parse event
        for parser in Parser.parsers:
            if parser.check(event):
                event = parser.run(event)
                break

        # Enrich event
        for enricher in Enricher.enrichers:
            if enricher.check(event):
                event = enricher.run(event)

        # Add event to list
        events.append(event)

# Sort events
events = sorted(events, key=lambda k: k['Time'])

# Open output file
with open(args.output, 'w+', encoding='utf-8-sig') as output_file:
    writer = csv.DictWriter(output_file, extrasaction='ignore', 
                            fieldnames=OUTPUT_FIELDS, lineterminator='\n')
    writer.writeheader()

    # Write events to output file
    for event in events:
        writer.writerow(event)
