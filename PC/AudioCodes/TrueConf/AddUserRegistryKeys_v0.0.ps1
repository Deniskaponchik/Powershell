# Version:      0.0
# STATUS:       Рабочее
# Мотивация:    Добавить пользовательские ключи в реестр для автозапуска TrueConf Room и Chrome 
# реализация:   
# проблемы:     
# Планы:        Протестировать на бОльшем кол-ве устройств
# Last Update:  
# Author:       denis.tirskikh@tele2.ru


#Добавление ключей в реестр. Выделить и выполнить весь код ниже:
try {
    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "TrueConf Room" -value 'C:\Program Files\TrueConf\Room\TrueConfRoom.exe -pin "123" --min --wsport 8765' -Verbose -ErrorAction Stop -ErrorVariable ErrRegChrome
    Write-Host "Пользовательская поправка к реестру для TrueConf Room применена успешно" -ForegroundColor Green
    [Environment]::NewLine


    Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -name "chrome" -value '"C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk --fullscreen http://localhost/' -Verbose -ErrorAction Stop -ErrorVariable ErrRegRoom
    Write-Host "Пользовательская поправка к реестру для Хрома применена успешно" -ForegroundColor Green
    [Environment]::NewLine   

    regedit.exe
}
catch {
    Write-Host $ErrRegRoom -ForegroundColor Red
    [Environment]::NewLine
    Write-Host $ErrRegChrome -ForegroundColor Red
    [Environment]::NewLine
    Write-Host "Пользовательские поправки к реестру не были примены. Смотри текст ошибок" -ForegroundColor Green
}
