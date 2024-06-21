#!/bin/bash

# INSTALLING WAZUH
curl -sO https://packages.wazuh.com/4.8/wazuh-install.sh
chmod +x wazuh-install.sh
sed -i "s/bastion_ip/$(hostname -I)/g" config.yml
cat config.yml

# Generating Wazuh certificates
sudo ./wazuh-install.sh --generate-config-files

# Installing Indexer
sudo ./wazuh-install.sh --wazuh-indexer node-1
sudo ./wazuh-install.sh --start-cluster

# Installing Server
sudo ./wazuh-install.sh --wazuh-server wazuh-1

# Installing Dashboard
sudo ./wazuh-install.sh --wazuh-dashboard dashboard


# INSTALLING SURICATA
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:oisf/suricata-stable
sudo apt-get update
sudo apt-get install -y suricata
sudo suricata-update
sudo systemctl restart suricata
sudo systemctl status suricata