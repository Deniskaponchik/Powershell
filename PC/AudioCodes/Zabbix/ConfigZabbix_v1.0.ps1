# Version:      1.0
# STATUS:       Пишет некоторые ошибки, но службу запускает и устанавливает
# Цель:         настройка и запуск Zabbix для систем ВКС AudioCodes
# реализация:   
# проблемы:     
# Планы:        Протестировать
# Last Update:  Все функции в принципе добавлены. нужно проверять
# Author:       denis.tirskikh@tele2.ru


<# !!! Сначала запускаем только эту одну строку кода снизу (выделить или поставить курсор и F8)
try {
    Set-ExecutionPolicy Unrestricted -Verbose
    Write-Host  "Политика выполнения PS-скриптов включена" -ForegroundColor Green
}
catch {
    Write-Host  'Политика выполнения PS-скриптов уже включена' -ForegroundColor Green  
}
[Environment]::NewLine
#>
 


$PathZabbixConf = "C:\AudioCodes\Zabbix\zabbix_agentd.conf"
$PathZabbixExe = "C:\AudioCodes\Zabbix\zabbix_agentd.exe"

# 1. Изменяем файл conf

# 2. Конфигурируем Firewall
try {
    #New-NetFirewallRule -DisplayName "Разрешить приложение Zabbix Agent" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Program $PathZabbixExe -Verbose
    #New-NetFirewallRule -DisplayName "Разрешить порт 10050 для Zabbix" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050 -Verbose
    New-NetFirewallRule -DisplayName "ALLOW Zabbix Agent" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Program $PathZabbixExe -Verbose
    New-NetFirewallRule -DisplayName "ALLOW 10050 port for Zabbix" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 10050 -Verbose

    #Write-Host "Созданы разрешающие правила на firewall для Zabbix" -ForegroundColor Green
    Write-Host "allow firewall rules was created  for Zabbix" -ForegroundColor Green
}
catch {
    Write-Host "allow firewall rules was NOT created  for Zabbix" -ForegroundColor Red
    Write-Host "Start of zabbix-service impossible" -ForegroundColor Red
    Write-Host "Check if start script with administrator permissions" -ForegroundColor Red
    [Environment]::NewLine
    exit
}

[Environment]::NewLine

# 3. Устанавливаем и запускаем службу
#& "C:\AudioCodes\Zabbix\zabbix_agentd.exe" --config "C:\AudioCodes\Zabbix\zabbix_agentd.conf" --install -verbose
#& "C:\AudioCodes\Zabbix\zabbix_agentd.exe" --config "C:\AudioCodes\Zabbix\zabbix_agentd.conf" --start -verbose
#Write-Host "Zabbix-агент установлен и запущен" -ForegroundColor GREEN
try {
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--config 'C:\AudioCodes\Zabbix\zabbix_agentd.conf' --install" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--start" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop

    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--config $PathZabbixConf --install" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop
    #Start-Process -FilePath $PathZabbixExe -ArgumentList "--start" -Verbose -ErrorVariable ErrZabbixInstall -ErrorAction Stop

    cd "C:\AudioCodes\Zabbix\"
    .\zabbix_agentd.exe -c .\zabbix_agentd.conf -i
    .\zabbix_agentd.exe -s
    
    #Write-Host "Zabbix-агент установлен и запущен" -ForegroundColor GREEN
    #Write-Host "Проверь, запустилась ли служба Zabbix в Службах Диспетчера задач" -ForegroundColor Green\
    Write-Host "Zabbix-agent was installed and ran" -ForegroundColor GREEN
    Write-Host "check Zabbix service in Task manager" -ForegroundColor Green
}
catch {
    #Write-Host "Zabbix агент не смог установиться или запуститься." -ForegroundColor RED
    #Write-Host "Проверь, что файлы лежат в этой директории:" -ForegroundColor RED
    Write-Host "Zabbix agent was not intalled and ran" -ForegroundColor RED
    Write-Host "Check files in the directory:" -ForegroundColor RED
    Write-Host $PathZabbixExe -ForegroundColor RED
    Write-Host $PathZabbixConf -ForegroundColor RED
}
[Environment]::NewLine
PAUSE



#Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
#Write-Host "отправлять на:"
Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback"
Write-Host "send to:"
Write-Host "denis.tirskikh@tele2.ru"
[Environment]::NewLine