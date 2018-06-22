#!/usr/bin/env python
"""This tool retrieves Office 365 Outlook Activities for a specified user.

Obtain a valid OAuth 2.0 access token from https://oauthplay.azurewebsites.net
or implement your own OAuth 2.0 flow for Azure AD.
"""

import argparse
import csv
import os
import sys

from activities import OutlookService


# Max number of activities per batch (1 - 1000)
BATCH_SIZE = 1000

# List of properties to retrieve
PROPERTIES = ['TimeStamp',
              'AppIdType',
              'ActivityIdType',
              'ActivityItemId',
              'ActivityCreationTime',
              'ClientSessionId',
              'CustomProperties']

# Parse arguments
parser = argparse.ArgumentParser(
        description='Retrieve Office 365 Outlook Activities')
parser.add_argument('--user', metavar='<username>',
                    help='Target user (user principal name)', required=True)
parser.add_argument('--output', metavar='<filename>',
                    help='CSV output filename', required=True)
parser.add_argument('--token', metavar='<token>',
                    help='OAuth access token', required=False)
parser.add_argument('--start', metavar='<timestamp>',
                    help='Start timestamp (ISO 8601)', required=False)
parser.add_argument('--end', metavar='<timestamp>',
                    help='End timestamp (ISO 8601)', required=False)
parser.add_argument('--types', metavar='<type>',
                    help='Space-delimited list of activity types', nargs='+',
                    required=False)
args = parser.parse_args()

# Verify access token was supplied
access_token = args.token if args.token else os.environ.get('OAUTH_TOKEN')
if not access_token:
    print("An access token must be supplied via the '--token' command-line "
          "argument or via the 'OAUTH_TOKEN' environment variable.")
    sys.exit(1)

# Construct filter expression
filters = []
if args.start:
    filters.append('(TimeStamp ge {})'.format(args.start))
if args.end:
    filters.append('(TimeStamp le {})'.format(args.end))
if args.types:
    types = ["ActivityIdType eq '{}'".format(
            activity_type) for activity_type in args.types]
    filters.append('({})'.format(' or '.join(types)))
filter_expression = ' and '.join(filters)

# Create Outlook service
service = OutlookService(access_token)

# Begin processing activities
batches = 0
while True:
    try:

        # Retrieve batch of activities
        activities = service.get_activities(
                args.user, filter=filter_expression,
                top=BATCH_SIZE, skip=batches * BATCH_SIZE,
                select=','.join(PROPERTIES))

    # Exit if error occurred issuing request
    except (IOError, ValueError) as error:
        print(error)
        sys.exit(1)

    if batches == 0:

        # Exit if no activities returned
        if not activities:
            print('No activities returned using the specific criteria.')
            sys.exit(1)

        try:

            # Create CSV file and write header
            csv_file = open(args.output, 'w+', encoding='utf-8-sig')
            writer = csv.DictWriter(
                    csv_file, extrasaction='ignore',
                    fieldnames=PROPERTIES, lineterminator='\n')
            writer.writeheader()
            print('Retrieving activities', end='')

        # Exit if error occurred writing to file
        except IOError as error:
            print(error)
            sys.exit(1)

    # Write rows to CSV file
    for activity in activities:
        writer.writerow(vars(activity))

    # Print status and flush buffers
    print('.', end='')
    sys.stdout.flush()
    csv_file.flush()

    # Break if final batch
    if len(activities) < BATCH_SIZE:
        break
    batches += 1

# Close file and print completion status
csv_file.close()
print('\nSuccessfully retrieved {} activities.'.format(
        batches * BATCH_SIZE + len(activities)))
