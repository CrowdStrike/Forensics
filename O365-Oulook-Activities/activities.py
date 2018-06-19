#!/usr/bin/env python
"""This module wraps basic functions of the Office 365 Outlook Activities API.
"""

import requests


class Activity(object):
    """Represents an Office 365 Outlook Activity
    """

    def __init__(self, activity):
        custom_props = activity.pop('CustomProperties', None)
        self.__dict__ = activity

        if custom_props:
            self.CustomProperties = {prop['Name']: prop['Value']
                                     for prop in custom_props}


class OutlookService(object):
    """Provides a simple abstraction layer and basic HTTP exception handling
    """

    base_url = "https://outlook.office.com/api/v2.0/Users('{}')"
    headers = {'Accept': 'application/json; odata.metadata=none',
               'Prefer': 'exchange.behavior="ActivityAccess"',
               'User-Agent': 'PythonOutlookService/1.0'}
    timeout = 10

    def __init__(self, access_token):
        self.access_token = access_token
        self.request_session = requests.Session()
        self.request_session.timeout = self.timeout
        self.request_session.auth = OAuth(self.access_token)
        self.request_session.headers.update(self.headers)

    def get_activities(self, user, **kwargs):
        api_url = self.base_url.format(user) + "/Activities?"
        params = {'${}'.format(param): value
                  for param, value in kwargs.items()}

        response = self.request_session.get(api_url, params=params)
        self._handle_errors(response)
        activities = [Activity(activity)
                      for activity in response.json()['value']]

        return activities

    def _handle_errors(self, response):
        if 199 < response.status_code < 300:
            return True
        elif response.status_code == 401:
            error = self._get_auth_error_from_headers(response.headers)
        elif 299 < response.status_code < 500:
            try:
                error = response.json()['error']['message']
            except ValueError:
                error = 'Client error.'
        else:
            error = 'Server error.'

        raise ValueError('HTTP {}: {}'.format(response.status_code, error))

    @staticmethod
    def _get_auth_error_from_headers(headers):
        fields = headers.get('x-ms-diagnostics')
        if fields:
            for field in fields.split(';'):
                if field.startswith('reason'):
                    return field.split('=')[1][1:-1]


class OAuth(requests.auth.AuthBase):
    def __init__(self, access_token):
        self.access_token = access_token

    def __call__(self, request):
        request.headers['Authorization'] = 'Bearer {}'.format(
                self.access_token)
        return request
