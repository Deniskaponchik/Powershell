# Версия: 0.5
# Статус: Можно интегрировать в запросы
# Реализация: Вывод функции - все свойства объекта в AD
# Проблемы: 
# Вопросы: denis.tirskikh@tele2.ru
function UserLogin ($u){
do {
    WRITE-HOST ''
    #$u = 'sgdfgdfgdfgfd'
    if ($u -eq '' -or $Null -eq $u -or $us.count -gt 1) {
        $u = Read-Host "Login OR FIO "
    }
    # Либо сразу находим по логину
     if ($us = Get-ADUser -Filter "SamAccountName -like '$u'" -properties *){
        #$u = $us.SamAccountName
    }
    # Либо ищем по ФИО
    elseif($us = Get-ADUser -Filter "displayname -like '$u*'" -properties *) {        
        #$u = $us.SamAccountName
    }
    # Если введена всякая несуразица
    else { $u = $Null }     
    # Если найдено несколько логинов:
    WRITE-HOST ''
    if (
        #$u.count -gt 1
        $us.count -gt 1
        ){
        Write-Host "Find several logins! Copy with mouse and Paste in the field below" -ForegroundColor RED
        foreach (
            #$login in $u
            $login in $us.SamAccountName
            ){
            Write-Host $login
        }
    }
}
 #while ($us.count -gt 1 -or $u -eq '' -or $ErrFind -eq 1)
  while ($us.count -gt 1 -or $u -eq '' -or $u -eq $Null)
#-or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

Return $us #$login
}
#UserLogin
#$UserProp = UserLogin
#$UserProp.mobilePhone
#[Environment]::NewLine

