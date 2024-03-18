# Version:      0.0
# STATUS:       Рабочее
# Мотивация:    Добавить машинные ключи для автозапуска TrueConf Room и Chrome 
# реализация:   
# проблемы:     
# Планы:        Протестировать на бОльшем кол-ве устройств
# Last Update:  
# Author:       denis.tirskikh@tele2.ru

### !!! CHROME ДОЛЖЕН БЫТЬ УСТАНОВЛЕН !!! ###
#Добавление ключей в реестр. Выделить и выполнить весь код ниже:
try {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\'
    [Environment]::NewLine
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome'
    [Environment]::NewLine
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist'
    [Environment]::NewLine

    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist' -name "1" -value "miljnhflnadlekbdohjgjdpeigmbiomh" -Verbose -ErrorAction Stop -ErrorVariable ErrRegChrome
    [Environment]::NewLine

    Write-Host "Machine Reg-file for chrome and TrueConf Room Apllied successfully" -ForegroundColor Green

    regedit.exe
}
catch {
    Write-Host $ErrRegChrome -ForegroundColor RED
    Write-Host "Reg-file for chrome and TrueConf Room could not Apply" -ForegroundColor RED
    Write-Host "you must add Reg-file after mannually" -ForegroundColor RED
}
