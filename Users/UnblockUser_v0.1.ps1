# \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Users\UnblockUser.ps1

"`n"
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$u, $us, $user, $Command = $null

do {$Error[0] = $null
    $lo = $Null
  if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
    if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
    $lo = 1}
    elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
              $u = $us.SamAccountName #.count
              if ($u.count -gt 1 ) {$u
              Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
  while ($u.count -gt 1 -or $u -eq '' -or $Null -eq $us -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 
  $user = Get-ADUser -identity $u -properties *

  # Формирование текста комментария для пользователя на основании его ролей
  # Список ролей пользователя:
  #              Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name
    $UserRoles = Get-ADPrincipalGroupMembership $User | Sort-Object | Select-Object -ExpandProperty name
  # $UserRoles
  # if ($UserRoles -contains 'Role Covid') {'Содержит!'}
    if ($UserRoles -contains 'Role CovidVpn') 
         {$Command = 'CTRL + ALT + DELETE'}
    else {$Command = 'CTRL + ALT + END'}


  [Environment]::NewLine
 #"##################################################"
  #Get-ADUser -identity $user -properties *
  "Дата создания УЗ                 : " + $user.whencreated.DateTime
  "Дата установки пароля            : " + $user.PasswordLastSet.DateTime
  "Дата ввода неправильного пароля  : " + $user.LastBadPasswordAttempt.DateTime
  if ($user.PasswordExpired) {Write-Host 'СРОК ДЕЙСТВИЯ ПАРОЛЯ ИСТЁК!!!' -ForegroundColor RED} 
  if ($user.userAccountControl -eq 512 -or $user.userAccountControl -eq 66048) {'Учётка Активна'} 
  else{Write-Host 'Учётка Заблокирована' -ForegroundColor RED}
 #"##################################################"
 [Environment]::NewLine

Write-Host "Продолжаем работу по разблокировке учётки?" -ForegroundColor Yellow
Pause

''
# Вносим изменения на учётке:
Set-ADUser $User -PasswordNeverExpires:$True -ChangePasswordAtLogon:$False -Enabled:$true
# Enable-ADAccount -Identity "PattiFul"

Write-Host "Убираны галочки для:" -ForegroundColor Red
Write-Host "* Пароль истёк" -ForegroundColor Red
Write-Host "* Поменять пароль при входе" -ForegroundColor Red
[Environment]::NewLine

"Скрипт поставлен на паузу ровно на 15 минут в:"
Get-Date -Format T
[Environment]::NewLine

Write-Host "За это время пользователю необходимо:" -ForegroundColor Red
Write-Host "1. Успеть залогиниться" -ForegroundColor Red
Write-Host "2. Сменить пароль" -ForegroundColor Red
[Environment]::NewLine

Write-Host "Варианты смены пароля на удалённом ПК:" -ForegroundColor magenta
Write-Host "1. CTRL + ALT + END" -ForegroundColor Magenta
Write-Host "2. Если сочетание клавиш не работает, то есть скрипт:" -ForegroundColor magenta
Write-Host "   \\t2ru\folders\IT-Outsource\Scripts\HTA\ChangePasswd.hta" -ForegroundColor magenta
[Environment]::NewLine

Write-Host "Через 15 мин. скрипт автоматически вернёт все галочки в правильное корпоративное состояние и завершит работу" -ForegroundColor Yellow
[Environment]::NewLine


$Message = 'Добрый день.', 'Учётку разблокировал, можно пробовать подключаться снова со старым паролем', 'После успешного подключения необходимо обязательно сменить пароль:', $Command
Set-Clipboard -Value $Message
Write-Host "Текст комментария для пользователя скопирован в буфер обмена" -ForegroundColor Green
[Environment]::NewLine

Wait-Event -Timeout 900

# Возвращаем всё как было:
  Set-ADUser $User -PasswordNeverExpires:$False
# Get-ADUser $User -properties PasswordExpired, PasswordLastSet, lastlogontimestamp, PasswordNeverExpires


#"Дата создания УЗ                 : " + $user.whencreated.DateTime
"Дата установки пароля            : " + $user.PasswordLastSet.DateTime
"Дата окончания действия пароля   : " + $user.PasswordLastSet.AddDays(+90).DateTime
"Дата ввода не правильного пароля : " + $user.LastBadPasswordAttempt.DateTime
if ($user.userAccountControl -eq 512 -or $user.userAccountControl -eq 66048) {'Учётка Активна'} 
else{Write-Host 'Учётка Заблокирована' -ForegroundColor RED}


 # Get-ADUser $User `
 # -properties PasswordExpired, PasswordLastSet, lastlogontimestamp, PasswordNeverExpires | Select-Object PasswordNeverExpires
 # Get-ADUser $User –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" `
 # | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

"`n"