# Version:      1.1
# STATUS:       НЕ протестировано
# Цель:         Смена пользователя, под которым автологиниться ДЛЯ УЧЁТОК С ПАРОЛЕМ
# реализация:   
# проблемы:     
# Планы:        
# Last Update:  нужно проверять
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
    ($UserAutoLogin -ne "Skype") -and ($UserAutoLogin -ne "TrueConf") -and ($UserAutoLogin -ne "Test")
)
[Environment]::NewLine


#Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -PropertyType "DWord" -Value "0"
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

#Всегда остаётся таким. Не меняем:
#Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String

 Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$UserAutoLogin" -type String
[Environment]::NewLine


$Question = Read-host "Does the account have a password? (1. Yes / 2. No) "

 If ($Question -eq "1" -or $question -eq "Yes" -or $question -eq "Y"){
#If ($Question -eq "2" -or $question -eq "No" -or $question -eq "N"){

    #$PasswordBoth = ""
    #$PasswordSkype = ""
    #$PasswordTrueConf = ""
    $PasswordUser = Read-Host "Input password for user "

    <# Случай, когда у учёток Skype и TrueConf разные пароли
    if ($UserAutoLogin -eq "Skype"){
        #Remove-ItemProperty $RegistryPath 'DefaultPassword' -force
        Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PasswordSkype" -type String
    }
    if ($UserAutoLogin -eq "TrueConf"){
        #New-ItemProperty $RegistryPath 'DefaultPassword' -Value "$tcpwdunsecur" -type String
        Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PasswordTrueConf" -type String
    }
    #>

    Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$PasswordUser" -type String

    Write-Host "For user $UserAutoLogin set autologon in the system with password" -ForegroundColor Green

} else {
    #Если пароля нет
    Remove-ItemProperty $RegistryPath 'DefaultPassword' -force

    Write-Host "For user $UserAutoLogin set autologon in the system without password" -ForegroundColor Green
}

#Write-Host "Для пользователя $UserAutoLogin установлен Автолог в систему без пароля" -ForegroundColor Green
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
    #Write-Host "команда перезагрузки не смогла выполниться корректно. Можешь сделать это самостоятельно" -ForegroundColor Red
    Write-Host "The command for reboot could not run. You can make it manually" -ForegroundColor Red
}