#!/bin/bash
read -p "Create unneded infra? (true/false): " create_other
terraform -chdir=./terraform apply --var-file=values.tfvars --var="create_other=$create_other"

read -p "Public IP/DNS of Bastion: " bastion_ip
scp /home/dmitriy/.ssh/id_rsa ubuntu@$bastion_ip:~/.ssh/
scp /home/dmitriy/bank_network/config.yml ubuntu@$bastion_ip:~/
scp /home/dmitriy/bank_network/setup_monitor.sh ubuntu@$bastion_ip:~/
scp /home/dmitriy/bank_network/install_wazuh_agent.sh ubuntu@$bastion_ip:~/
