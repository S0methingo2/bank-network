# Призначення репозиторію

В цьому репозиторії надано [Terraform код](/terraform/) для створення макету банківської мережі в [`AWS`](https://aws.amazon.com), а також bash скрипти для налаштування пристроїв в мережі.

# Інфраструктура

Наданий Terraform код створює наступну інфраструктуру:
![infrastructure](/img/infrastruscture.png)

# Скрипти

1. [`create_infra.sh`](/create_infra.sh) -- створює інфраструктуру в AWS
2. [`destroy_infra.sh`](/destroy_infra.sh) -- знищує створену іфнрастркутуру в AWS
3. [`setup_monitor.sh`](/setup_monitor.sh) -- встановлює необхідні компоненти моніторингової системи
4. [`install_wazuh_agent.sh`](/install_wazuh_agent.sh) -- встановлює агенти на інші пристрої мережі