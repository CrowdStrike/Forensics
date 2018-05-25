import json
from pprint import pprint
import bisect
import time
from Crypto.PublicKey import RSA
import os
import subprocess
os.nice(10) # to prevent this script from locking up the server

# REPLACETHISRSAKEYREPLACETHISRSAKEYREPLACETHISRSAKEY


decryptKey = RSA.importKey(RSAPrivKey)

while True:
    database = {}
    try: # script could try to run while eve.json is being wiped
        with open ('/var/log/suricata/eve.json') as data_file:
            for suricata_hit in data_file:
                packet = json.loads(suricata_hit)
                try:
                    if packet['alert']['signature'] == 'porthawk':
                        packetContent = packet['payload_printable']
                        try:
                            if packetContent[:8] == 'porthawk':
                                classification = decryptKey.decrypt(packetContent[8:].decode("hex"))
                                engagement = classification[classification.index("[") + 1:classification.rindex("]")]
                                hostname = classification[classification.index("(") + 1:classification.rindex(")")]
                                protocol = packet['proto']

                                def insertPacket(protocol):
                                    if protocol == 'ICMP':
                                        if packet['icmp_type'] not in database[engagement][hostname]['ICMP_type']:
                                            bisect.insort(database[engagement][hostname]['ICMP_type'], packet['icmp_type'])

                                    elif protocol == 'UDP':
                                        if packet['dest_port'] not in database[engagement][hostname]['UDP_dest_port']:
                                            bisect.insort(database[engagement][hostname]['UDP_dest_port'], packet['dest_port'])

                                    elif protocol == 'TCP':
                                        if packet['dest_port'] not in database[engagement][hostname]['TCP_dest_port']:
                                            bisect.insort(database[engagement][hostname]['TCP_dest_port'], packet['dest_port'])

                                # has the database seen the engagement before
                                if engagement in database:
                                    if hostname in database[engagement]: # the hostname AND engagement is there
                                        insertPacket(protocol)
                                    else: # add the hostname, and initialize ICMP/UDP/TCP:[] (engagement is there)
                                        database[engagement].update({hostname:{'ICMP_type':[],'UDP_dest_port':[],'TCP_dest_port':[]}})
                                        insertPacket(protocol)
                                else: # add the engagement and host to the database
                                    database[engagement] = {hostname:{'ICMP_type':[],'UDP_dest_port':[],'TCP_dest_port':[]}}
                                    insertPacket(protocol)
                        except ValueError: # this prevents packets that are false positives from breaking program
                            continue
                except KeyError:
                    continue


        for key,value in database.iteritems():
            file_name = '/home/suri/porthawk/engagements/%s.json' % key
            #if logic here to see if engagement name file exists
            if os.path.exists(file_name): #if the file does exist, check to see if it has that host
                with open (file_name, 'r+') as existing_engagement:
                    new_hosts = []
                    new_hosts_flag = False
                    for host_name in existing_engagement: # for each host existing in the .json file
                        for collected_hostname,associated_ports in value.iteritems(): # for each collected hostname
                            if collected_hostname in host_name: # if it is there, existing, then pass
                                pass
                            else: # else it is a new host in an existing engagement, possibly one of many, add it to a 'to-be appended' db
                                new_hosts.append({collected_hostname:associated_ports})
                                new_hosts_flag = True

                    if new_hosts_flag:
                        # remove the last '}', so the program can add the new hosts within the JSON object
                        existing_engagement.seek(-1, os.SEEK_END)
                        existing_engagement.truncate()
                        for entry in new_hosts:
                            # comma separate the entries, and clip the {} json.dumps puts on the data by default
                            existing_engagement.write(",")
                            existing_engagement.write(json.dumps(entry)[1:-1])
                        existing_engagement.write("}")
            else: # if the engagement does not exist, add it
                with open(file_name, 'w') as f:
                    f.write(json.dumps(value))
    except IOError: # script could try to run while eve.json is being wiped, so wait 5 seconds
        time.sleep(5)

    subprocess.call("chmod -R 555 /home/suri/porthawk/engagements", shell=True)
    time.sleep(900) # script runs every 15 min
