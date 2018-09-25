#!/usr/bin/env python

import geoip2.database


class Enricher(object):

    enrichers = []

    def __init_subclass__(cls, **kwargs):
        if cls.enabled:
            super().__init_subclass__(**kwargs)
            cls.enrichers.append(cls())


class Geolocation(Enricher):

    enabled = True
    db_path = 'databases/geoip/GeoLite2-City.mmdb'
    
    def __init__(self):
        self.reader = geoip2.database.Reader(self.db_path)

    def check(self, event):
        return True if event.get('Client_IP') else False
            
    def run(self, event):
        enriched_event = event
        try:
            enriched_event['Country'] = self.reader.city(enriched_event['Client_IP']).country.name
            enriched_event['Region'] = self.reader.city(enriched_event['Client_IP']).subdivisions.most_specific.name
            enriched_event['City'] = self.reader.city(enriched_event['Client_IP']).city.name
        except (ValueError, geoip2.errors.AddressNotFoundError):
            pass
        return enriched_event
