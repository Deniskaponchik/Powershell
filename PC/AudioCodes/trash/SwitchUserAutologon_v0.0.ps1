# Version:      0.0
# STATUS:       НЕ протестировано
# Цель:         Быстрая смена пользователя, под которым автологиниться
# реализация:   
# проблемы:     
# Планы:        
# Last Update:  Все функции в принципе добавлены. нужно проверять
# Author:       denis.tirskikh@tele2.ru


<# !!! Сначала запускаем только эту одну строку кода снизу (выделить или поставить курсор и F8)
try {
    Set-ExecutionPolicy Unrestricted
    Write-Host  "Политика выполнения PS-скриптов включена" -ForegroundColor Green
}
catch {
    Write-Host  'Политика выполнения PS-скриптов уже включена' -ForegroundColor Green  
}
[Environment]::NewLine
#>


 #CHECK. Автологин без пароля
 do {
    #$UserAutoLogin = Read-Host "Укажи имя учётной записи Skype или TrueConf, в которую настроить автологин "
    $UserAutoLogin = Read-Host "Write Skype or TrueConf for autologon setting "
    $UserAutoLogin
} while (    
    ($UserAutoLogin -ne "Skype") -and ($UserAutoLogin -ne "TrueConf") #-and ($UserAutoLogin -ne "Test")
)
#Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "0"
 $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
#Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
 Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String
#Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "" -type String

#Write-Host "Для пользователя $UserAutoLogin установлен Автолог в систему без пароля" -ForegroundColor Green
Write-Host "For user $UserAutoLogin set autologon in the system without password" -ForegroundColor Green
[Environment]::NewLine
PAUSE



#Write-Host "Ошибки, Логи, Баги, Скрины, Проблемы, Пожелания, Предложения и Любую другую обратную связь"
#Write-Host "отправлять на:"
#Write-Host "denis.tirskikh@tele2.ru"
Write-Host "Errors, bugs, logs, screens, photos, reports, problems, suggestions and other feedback"
Write-Host "send to:"
Write-Host "denis.tirskikh@tele2.ru"
[Environment]::NewLine
PAUSE


#CHECK. 
try {
    Restart-Computer -Confirm -Force
}
catch {
    Write-Host "команда перезагрузки не смогла выполниться корректно. Можешь сделать это самостоятельно" -ForegroundColor Red
}