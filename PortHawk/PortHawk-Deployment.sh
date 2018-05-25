#!/bin/bash

#get internet target ip address
echo -n "Please enter the Internet IP Address for the Server: "
read internetipaddress
sed -i -e "s/REPLACETHISIPADDRESSREPLACETHISIPADDRESS/$internetipaddress/" porthawk-client.py

# add repo
sudo apt-add-repository -y ppa:oisf/suricata-stable

# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# IP table rules to not respond to malformed packets sent
sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP
sudo iptables -A OUTPUT -p icmp -j DROP

# install apps
sudo apt-get -y install suricata
sudo apt-get -y install build-essential
sudo apt-get -y install python-dev
sudo apt-get -y install python-pip
sudo pip install --upgrade pip
sudo pip install pycrypto
sudo echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
sudo echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo echo iptables-persistent/autosave_v4	boolean	true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent

# porthawk rules
echo "alert ip any any -> $internetipaddress any (msg:\"porthawk\";content:\"porthawk\";)" > /etc/suricata/rules/porthawk.rules
sudo mv suricata.yaml /etc/suricata/suricata.yaml
sudo sed -i 's/eth0/'"$(ifconfig | grep $(hostname -I) -B 1 | grep -Eo '^[^ ]+')"'/g' /etc/suricata/suricata.yaml

# create the suricata user
sudo adduser --disabled-password --gecos "" suri
sudo addgroup suri
sudo adduser suri suri
sudo mkdir -p /var/log/suricata/pcaps
sudo chown -R suri:suri /var/log/suricata/
sudo chown -R suri:suri /etc/suricata/
sudo mkdir -p /home/suri/porthawk/engagements

#generate RSA keys used to encrypt engagement name within the traffic
openssl genrsa 512 > privkey.pem
openssl rsa -in privkey.pem -outform PEM -pubout -out pubkey.pem
#inserting priv key to server log script
echo -n "RSAPrivKey = \"\"\"" > out.tmp
cat privkey.pem >> out.tmp
echo \"\"\" >> out.tmp
sed -i -e "/REPLACETHISRSAKEYREPLACETHISRSAKEYREPLACETHISRSAKEY/r out.tmp" porthawk-server-log.py
rm out.tmp

#inserting pub key to client
echo -n "pubKey = \"\"\"" > out.tmp
cat pubkey.pem >> out.tmp
echo \"\"\" >> out.tmp
sed -i -e "/RSAPUBKEYREPLACERSAPUBKEYREPLACERSAPUBKEYREPLACE/r out.tmp" porthawk-client.py 
rm out.tmp

#move python script and files over and make sure permissions are right
sudo mv porthawk-server-log.py /home/suri/porthawk/porthawk-server-log.py
sudo mv privkey.pem /home/suri/porthawk/
sudo mv pubkey.pem /home/suri/porthawk/
sudo mv porthawk-client.py /home/suri/porthawk/
sudo chown -R suri:suri /home/suri/
sudo chown -R suri:suri /var/log/suricata
#sudo chown -R suri:suri /etc/suricata

# cronjobs
## Every day at 4 am, kill suricata, remove the eve.json file, and then restart suricata
(sudo crontab -l ; echo "0 4 * * * sudo kill -15 \$\(sudo cat /var/run/suricata.pid\); sudo rm /var/log/suricata/eve.json; sleep 30; sudo suricata -c /etc/suricata/suricata.yaml -i $(ifconfig | grep $(hostname -I) -B 1 | grep -Eo '^[^ ]+') --user=suri --group=suri -D")| sudo crontab -
## On boot, start suricata
(sudo crontab -l ; echo "@reboot sudo suricata -c /etc/suricata/suricata.yaml -i $(ifconfig | grep $(hostname -I) -B 1 | grep -Eo '^[^ ]+') -user=suri -group=suri -D")| sudo crontab -
## On boot, start the python file as user 'suri'
(sudo crontab -l ; echo "@reboot sudo nohup /usr/bin/python /home/suri/porthawk/porthawk-server-log.py &")| sudo crontab -

# remove packets suricata caught while started
sudo rm /var/log/suricata/eve.json

# prompt for a reboot
clear
echo ""
echo "===================="
echo " TIME FOR A REBOOT! "
echo "===================="
echo ""

sudo shutdown -r now
