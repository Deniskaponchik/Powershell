<#            !!!   R E A D   M E   !!!
Данный скрипт служит шаблоном для любой популярной выгрузки списка атрибутов пользователей, взятых из:
из txt-файла (называется как имя скрипта, должен лежать в директории скрипта. Кодировка файла должна быть: Windows-1251)
в csv-файл (называется как имя скрипта, будет ледать в директории скрипта)



!!!   Данный скрипт не рекомендуется редактировать  !!! Создавай свою копию под свои нужды   !!!
!!!   Или закомментриуй не нужное
#>




[Environment]::NewLine
# Берём файл txt из директории скрипта и с именем скрипта:
[string]$file = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "txt" )))

# Подписываем столбцы:
# [array]$res = @("Name`tIP`tOS`tManufacturer`tModel`tMemory`tProcessors`tDisks`tBIOS`tSerial number")
  [array]$res = @("UserName`tPosition")
  
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
          [string]$username = ""
          [string]$position = ""
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
            # else {
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
        $user.SamAccountName




          $position = $Null
          [Environment]::NewLine

        #>
        # Должность
          $position = $Null
          if ([string]$p = (Get-ADUser $username -Properties title | Select-Object title)) {
            [string]$position = $p.Replace("@{title=","").Replace("@{Title=","").Replace("}","")
          }
          else {
            [string]$position = ""
          }
          # [string]$position = Get-ADUser $username -Properties title | Select Title
          # [string]$p = $position.Replace("@{Title=","").Replace("}","")

          # $res += "$server`t$ip`t$os`t$man`t$mod`t$mem`t$proc`t$disk`t$bios`t$serial"
       }
    $res += "$username`t$position" 
}

[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса

"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile