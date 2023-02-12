# Версия: 0.3
# Статус: Можно использовать в запросах
# Реализация: Функция переделывания ФИО в логин
# Проблемы:
# Вопросы: denis.tirskikh@tele2.ru

function UserLogin #([string]$u)
{
do {
    [Environment]::NewLine
    $u = Read-Host "Login OR FIO "
    #$u = 'Тирских Денис'
    $ErrFind = $Null
    #if ($u -eq '' -or $Null -eq $u) {}

    # Либо сразу находим по логину
     if ($us = Get-ADUser -Filter "SamAccountName -like '$u'"){
          $u = $us.SamAccountName
         #'Hi'
    }

    # Либо ищем по ФИО
    elseif($us = Get-ADUser -Filter "displayname -like '$u*'") {        
        $u = $us.SamAccountName
        #'Buy'
    }

    else {$ErrFind = 1}
       
    
    # Если найдено несколько логинов:
    [Environment]::NewLine
    if ($u.count -gt 1) {
        Write-Host $u
        Write-Host "Find several logins! Copy with mouse and Paste in the field below" -ForegroundColor RED
    } 

}
while ($u.count -gt 1 -or $u -eq '' -or $ErrFind -eq 1) 
#-or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

#$Login = [string]$u
Return $u #$login
}

#UserLogin
#[Environment]::NewLine

