#!/bin/bash

read -p "Enter Group name: " group_name
read -p "Enter Agent name: " agent_name
read -p "Wazuh manager IP-adress: " manager_ip

sudo wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.8.0-1_amd64.deb && \
    sudo WAZUH_MANAGER="$manager_ip" WAZUH_AGENT_GROUP="$group_name" WAZUH_AGENT_NAME="$agent_name" dpkg -i ./wazuh-agent_4.8.0-1_amd64.deb

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent