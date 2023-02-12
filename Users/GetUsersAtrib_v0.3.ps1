<#            !!!   R E A D   M E   !!!
Данный скрипт служит для любой выгрузки атрибутов группы пользователей:
взятых из txt-файла (называется как имя скрипта, должен лежать в директории скрипта. Кодировка файла должна быть: Windows-1251)
выгрузка сохранится в csv-файл (называется как имя скрипта, будет лежать в директории скрипта)

#>
  

#
# Подгрузка внешней функции UserLogin !!! Кодировка файла должна быть Windows-1251 !!!
# powershell -ExecutionPolicy bypass -File \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\Logging_v0.2.ps1
# 
# . C:\Scripts\Example-02-DotSourcing.ps1
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.1.ps1
# . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.4.ps1
# Get-Content \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.2.ps1 -Encoding utf8
# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.2.ps1 -Encoding utf8
#>

<# Внутрення функция UserLogin
  function UserLogin {
# Получение логина по ФИО и обратно:
$u, $us, $ResultUL = $null

do {$Error[0], $lo = $null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {
    $u = $us.SamAccountName
    $Global:lo = 1
  }
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {
              Write-Host $u
              Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

Return Get-ADUser -identity $u -properties *
# Возврат нескольких переменных
# $return = & $delprof2 $computer $switches
} 
#>

# Вызываем функцию
# $ResultUL = UserLogin
# $ResultUL = $Result
  $login = UserLogin
# $ResultUL = Get-ADUser -identity $Login -properties *


[Environment]::NewLine



  # Выводим список доступных атрибутов для удобства:
  [Environment]::NewLine
  Get-ADUser -identity $login -properties *
  

  [Environment]::NewLine
# Задаём атрибуты, которые будем извлекать:
  $Atrib1 = Read-Host "Укажи Атрибут 1"
  $Atrib2 = Read-Host "Укажи Атрибут 2"
  $Atrib3 = Read-Host "Укажи Атрибут 3"
  $Atrib4 = Read-Host "Укажи Атрибут 4"



  [Environment]::NewLine
# Берём файл txt из директории скрипта и с именем скрипта:
  [string]$file = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "txt" )))

# Подписываем столбцы:
# [array]$res = @("Name`tIP`tOS`tManufacturer`tModel`tMemory`tProcessors`tDisks`tBIOS`tSerial number")
  [array]$res = @("Login`t$Atrib1`t$Atrib2`t$Atrib3`t$Atrib4")
# [array]$res = @("UserName`tPosition")
  
# Вариант с автоматическим удалением пустых строк:
# Get-Content $file | ?{$_.Trim() -ne ""} | %{
# Get-Content $file | ?{$_} | %{
# Берём данные, включая пустые строки:
  Get-Content $file | Where-Object{$_ -or $_ -eq ''} | ForEach-Object{
    # $username = $_.Trim().Replace("t2ru\","")
    # $username = $_.Replace("t2ru\","")
    
    # Если взята пустая строка, то и на выходе добавить пустую строку:
      if ($_ -eq '') {
        # if ([string]::IsNullOrWhitespace($_)) {
        # if ($_.Length -eq 0) {
        # [string]$username = ""
          [string]$login = ""
        # [string]$position = ""
          [string]$Atrib11 = ""
          [string]$Atrib22 = ""
          [string]$Atrib33 = ""
          [string]$Atrib44 = ""
       }    
      else {
        $username = $Null
        if ($_ -like "t2ru*") {$username = $_.Replace("t2ru\","")}
        else {$username = $_}

        <#
        do {$Error[0] = $null
            $lo = $Null
          if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
            if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {
                $u = $us.SamAccountName
                $lo = 1}
            elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {
                $us = Get-ADUser -Filter "displayname -like '$u*'"
            }
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {
                $u
                Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED
            } 
          }
          while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
          $user = Get-ADUser -identity $u -properties *
         
          $user.SamAccountName
          [Environment]::NewLine
          #>

        # Первод ФИО в логин
        $u1 = $Null # Зануляем параметр для запроса ввода логина от предыдущего пользователя
        do {$Error[0] = $null
            # if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
              if ($u1 -ne $Null) {$username = Read-Host "Логин или ФИО"}

            if ($us = Get-ADUser -Filter "SamAccountName -like '$username'") {
                $u = $us.SamAccountName
            }
            elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$username'")) {
                $us = Get-ADUser -Filter "displayname -like '$username*'"
            }   
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {
                #$user = $null
                $u
                Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED
                #$user = Read-Host "Найдено несколько логинов!"
                $u1 = 1 # Маркер для запроса ввода логина
            } 
          }
        while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  
        # $u.count -eq 1 -or
        # $user -eq $Null -or
        $user = Get-ADUser -identity $u -properties *
        $Login = $user.SamAccountName



          
          [Environment]::NewLine
          <# Должность
            $position = $Null
            if ([string]$p = (Get-ADUser $Login -Properties title | Select-Object title)) {
                [string]$position = $p.Replace("@{title=","").Replace("@{Title=","").Replace("}","")
            }
          else {[string]$position = ""}
          # [string]$position = Get-ADUser $username -Properties title | Select Title
          # [string]$p = $position.Replace("@{Title=","").Replace("}","")
          #>
         
          # Переменная $Atrib1
            try {
              $Atrib11 = $Null
            if ([string]$p = (Get-ADUser $Login -Properties $Atrib1 | Select-Object $Atrib1)) {
                [string]$Atrib11 = $p.Replace("@{$Atrib1=","").Replace("@{$Atrib1=","").Replace("}","")
            }
            else {[string]$Atrib11 = ""}
            }
            catch {
              'Атрибут1 не был задан'
            }            

            # Переменная $Atrib2
            try {
              $Atrib22 = $Null
            if ([string]$p = (Get-ADUser $Login -Properties $Atrib2 | Select-Object $Atrib2)) {
                [string]$Atrib22 = $p.Replace("@{$Atrib2=","").Replace("@{$Atrib2=","").Replace("}","")
            }
            else {[string]$Atrib22 = ""}
            }
            catch {
              'Атрибут2 не был задан'
            }

            # Переменная $Atrib3
            try {
              $Atrib33 = $Null
            if ([string]$p = (Get-ADUser $Login -Properties $Atrib3 | Select-Object $Atrib3)) {
                [string]$Atrib33 = $p.Replace("@{$Atrib3=","").Replace("@{$Atrib3=","").Replace("}","")
            }
            else {[string]$Atrib33 = ""}
            }
            catch {
              'Атрибут3 не был задан'
            }           


            # Переменная $Atrib4
            try {
              $Atrib44 = $Null
            if ([string]$p = (Get-ADUser $Login -Properties $Atrib4 | Select-Object $Atrib4)) {
                [string]$Atrib44 = $p.Replace("@{$Atrib4=","").Replace("@{$Atrib4=","").Replace("}","")
            }
            else {[string]$Atrib44 = ""}
            }
            catch {
              'Атрибут4 не был задан'
            }

            [Environment]::NewLine  

       }

    # занесение в ячейки итогового файла:
    # $res += "$server`t$ip`t$os`t$man`t$mod`t$mem`t$proc`t$disk`t$bios`t$serial"
    # $res += "$username`t$position"
      $res += "$login`t$Atrib11`t$Atrib22`t$Atrib33`t$Atrib44" 
}

[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса

"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile