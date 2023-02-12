# Версия: 0.4
# Статус: Можно использовать в запросах
# Реализация: Функция переделывания ФИО в логин
# Проблемы:
# Вопросы: denis.tirskikh@tele2.ru

function UserLogin ($u)
{
do {
    #[Environment]::NewLine
    WRITE-HOST ''
    $ErrFind = $Null
    #$u = 'Тирских Денис'
    if ($u -eq '' -or $Null -eq $u) {
        $u = Read-Host "Login OR FIO "
    }

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

    # Если введена всякая несуразица
    else {
        $ErrFind = 1
        $u = $Null
        #'Good Buy'
    }
       
    
    # Если найдено несколько логинов:
    #[Environment]::NewLine
    WRITE-HOST ''
    if ($u.count -gt 1) {
        Write-Host "Find several logins! Copy with mouse and Paste in the field below" -ForegroundColor RED
        #Write-Host $u  # Выводит всё в одну строку
        foreach ($login in $u){
            Write-Host $login
        }
    } 

}
while ($u.count -gt 1 -or $u -eq '' -or $ErrFind -eq 1) 
#-or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

#$Login = [string]$u
Return $u #$login
}

#UserLogin
#[Environment]::NewLine

