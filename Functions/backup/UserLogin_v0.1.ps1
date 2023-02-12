# Кодировка файла: Windows-1251
# Функция получение логина по ФИО и обратно

  function UserLogin {
# $u, $us, $ResultUL = $null

do { #$Error[0], $lo = $null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {
    $u = $us.SamAccountName
    $Global:lo = 1
  }
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
              $u = $us.SamAccountName #.count
			# $Global:u = $us.SamAccountName
            if ($u.count -gt 1 ) {
               Write-Host $u
			   # $u
              Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')

$Login = [string]$u

# Return $ResultUL = Get-ADUser -identity $u -properties *
  Return $login

} 

