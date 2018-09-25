#!/usr/bin/env python

import ipaddress
import json
import sys


class Parser(object):

    parsers = []

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        cls.parsers.append(cls())


class MailboxActions(Parser):
    
    operations = ['Copy', 'Create', 'FolderBind', 'HardDelete', 'MailboxLogin',
                  'MessageBind', 'Move', 'MoveToDeletedItems', 'SendAs',
                  'SendOnBehalf', 'SoftDelete', 'Update',
                  'UpdateCalendarDelegation', 'UpdateFolderPermissions',
                  'UpdateInboxRules', 'New-InboxRule']

    def check(self, event):
        return True if event['Operation'] in self.operations else False
            
    def run(self, event):
        if event.get('ClientInfoString'):
            client_type, user_agent = self._get_client_info(event['ClientInfoString'])
        else:
            client_type, user_agent = None, None
        if event.get('ClientIPAddress'):
            ip_address = event['ClientIPAddress']
        else:
            ip_address = None
        parsed_event = {'Time': event['CreationTime'],
                        'Action': event['Operation'],
                        'Workload': event['Workload'],
                        'User': event['UserId'],
                        'Status': event['ResultStatus'],
                        'Client_IP': ip_address,
                        'Client_Type': client_type,
                        'User_Agent': user_agent,
                        'Data': event}
        return parsed_event

    def _get_client_info(self, clientinfostring):
        strings = clientinfostring.split(';')
        if any(element in strings[0] for element in ['/owa/', '/ecp/']):
            client_type = 'Web'
        elif strings[0].startswith('Client'):
            client_type = strings[0].split('=')[1]
        else:
            client_type = strings[0]
        user_agent = ';'.join(strings[1:]).strip()
        return client_type, user_agent


class ForwardingRule(Parser):
    
    def check(self, event):
        if event.get('ExtendedProperties', {}).get('ForwardingSmtpAddress'):
            return True
        else:
            return False

    def run(self, event):
        client_ip = event['ClientIP'].split(':')[0]
        parsed_event = {'Time': event['CreationTime'],
                        'Action': 'ForwardingRule',
                        'Workload': event['Workload'],
                        'User': event['UserId'],
                        'Status': event['ResultStatus'],
                        'Address': event['ExtendedProperties']['ForwardingSmtpAddress'].split(':')[1],
                        'Client_IP': client_ip,
                        'Data': event}
        return parsed_event


class Default(Parser):
    
    def check(self, event):
        return True
            
    def run(self, event):
        parsed_event = {'Time': event['CreationTime'],
                        'Action': event['Operation'],
                        'Workload': event['Workload'],
                        'User': event['UserId'],
                        'Data': event}

        if event.get('ClientIP'):
            try:
                ipaddress.ip_address(event.get('ClientIP'))
                client_ip = event['ClientIP']
            except ValueError:
                if event.get('ClientIP').startswith('['):
                    client_ip = event.get('ClientIP').split(']')[0][1:]
                else:
                    client_ip = event['ClientIP'].split(':')[0]
            parsed_event['Client_IP'] = client_ip
                
        if event.get('ResultStatus'):
            parsed_event['Status'] = event.get('ResultStatus')

        if event.get('ExtendedProperties', {}).get('UserAgent'):
            parsed_event['User_Agent'] = event['ExtendedProperties']['UserAgent']

        return parsed_event
