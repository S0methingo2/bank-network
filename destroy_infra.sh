#!/bin/bash
read -p "Create unneded infra? (true/false): " create_other
terraform -chdir=./terraform destroy --var-file=values.tfvars --var="create_other=$create_other"