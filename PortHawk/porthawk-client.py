import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
import socket
import sys, getopt
from Crypto.PublicKey import RSA
from scapy.all import *

# RSAPUBKEYREPLACERSAPUBKEYREPLACERSAPUBKEYREPLACE

encryptKey = RSA.importKey(pubKey)

def portHawk(engagementName, hostname, interface, verbose):

    trigger = 'porthawk'
    if hostname == '':
        hostname = socket.gethostname()

    data = "[%s](%s)" % (engagementName, hostname)
    data = trigger + encryptKey.encrypt(data, 32)[0].encode('hex')
    serverIP = "REPLACETHISIPADDRESSREPLACETHISIPADDRESS"
    
    if interface != '':
        s = conf.L3socket(iface=interface)
        if verbose:
            import progressbar
            bar = progressbar.ProgressBar()
            # send ICMP Packets type 0-255
            print "sending ICMP packets..."
            for n in bar(range(0,256)):
                s.send(IP(dst=serverIP) /ICMP(type=n)/str(data))

            # send UDP Packets
            print "sending UDP packets..."
            bar = progressbar.ProgressBar()
            for n in bar(range(0,65536)):
                s.send(IP(dst=serverIP) / UDP(dport=n) / Raw(load=data))

            # send TCP Packets
            print "sending TCP packets..."
            bar = progressbar.ProgressBar()
            for n in bar(range(0,65536)):
                s.send(IP(dst=serverIP) / TCP(dport=n) / Raw(load=data))
        else:
            # send ICMP
            for n in range(0,256):
                s.send(IP(dst=serverIP) /ICMP(type=n)/str(data))

            # send UDP Packets
            for n in range(0,65536):
                s.send(IP(dst=serverIP) / UDP(dport=n) / Raw(load=data))

            # send TCP Packets
            for n in range(0,65536):
                s.send(IP(dst=serverIP) / TCP(dport=n) / Raw(load=data))
    else:
        if verbose:
            import progressbar
            bar = progressbar.ProgressBar()
            # send ICMP Packets type 0-255
            print "sending ICMP packets..."
            for n in bar(range(0,256)):
                send(IP(dst=serverIP) /ICMP(type=n)/str(data), verbose=0)

            # send UDP Packets
            print "sending UDP packets..."
            bar = progressbar.ProgressBar()
            for n in bar(range(0,65536)):
                send(IP(dst=serverIP) / UDP(dport=n) / Raw(load=data), verbose=0)

            # send TCP Packets
            print "sending TCP packets..."
            bar = progressbar.ProgressBar()
            for n in bar(range(0,65536)):
                send(IP(dst=serverIP) / TCP(dport=n) / Raw(load=data), verbose=0)
        else:
            # send ICMP
            for n in range(0,256):
                send(IP(dst=serverIP) /ICMP(type=n)/str(data), verbose=0)

            # send UDP Packets
            for n in range(0,65536):
                send(IP(dst=serverIP) / UDP(dport=n) / Raw(load=data), verbose=0)

            # send TCP Packets
            for n in range(0,65536):
                send(IP(dst=serverIP) / TCP(dport=n) / Raw(load=data), verbose=0)


def main(argv):
   engagementName = ''
   hostname = ''
   interface = ''
   verbose = False

   usage = 'usage: porthawk.py -e engagementName -n (optional) Computer Name -i (optional - specify this for speed) interface --verbose (optional)'
   try:
      opts, args = getopt.getopt(argv,"e:n:i:v:h", ["engagement=","name=","verbose","help"])
   except getopt.GetoptError:
      print usage
      sys.exit(2)
   for opt, arg in opts:
       if opt in ("-h", "--help"):
           print usage
           sys.exit()
       elif opt in ("-e", "--engagement"):
           engagementName = arg
       elif opt in ("-v", "--verbose"):
           verbose = True
       elif opt in ("-i", "--interface"):
           interface = arg
       elif opt in ("-n", "--name"):
           hostname = arg

   if engagementName == '':
       print usage
       sys.exit()

   return (engagementName, hostname, interface, verbose)

if __name__ == "__main__":
   portHawk(*main(sys.argv[1:]))
