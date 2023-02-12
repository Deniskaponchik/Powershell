<# Общая структура скрипта:
$User = [ADSI]"WinNT://домен/учетка,user"
$Group = [ADSI]"WinNT://домен/комп/Администраторы,group"
$Group.Invoke("Add",$User.PSBase.Path)
#>

''
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$user, $u, $us, $login, $ADSIuser = $Null

# новый идеальный код:
do { # $Error[0] = $null, $lo = $Null
if ($null -eq $u) {$u = Read-Host "Логин или ФИО"}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {$u = $us.SamAccountName
  $lo = 1}
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
            $u = $us.SamAccountName #.count
            if ($u.count -gt 1 ) {$u
            Write-Host "Найдено несколько логинов! Скопируй необходимый мышкой и вставь в следующем поле" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $Null -eq $us -or $Error[0] -like '*поиска*' -or $Error[0] -like '*проверить*')  # $u.count -eq 1 -or 

$user = Get-ADUser -identity $u -properties *
$login = [string]$user.SamAccountName
$login
$ADSIuser = [ADSI]"WinNT://t2ru/$login,user"


do {$PC = Read-Host "Имя компьютера"}
while ((Test-Connection $PC -Quiet) -eq $False)
# if (Test-Connection -ComputerName $PC -Quiet)

do {
    $Error[0] = $null
    [Environment]::NewLine
    write-host  'Примеры локальных групп для добавления:'  -ForegroundColor Green
    'Операторы настройки сети'
    'Network Configuration Operator'
    'Администраторы'
    'Administartors'
  # 'Опытные пользователи'
    'Пользователи удаленного рабочего стола'
    'Remote Desktop Users'
    
    [Environment]::NewLine
    if (($g = Read-Host "Локальная группа, в которую добавить") -ne "") {

         write-host  'Текущее наполнение группы:'  -ForegroundColor Yellow
         <# WORK original
         $RemoteComputerName = "WSZI-NGTIATE-03"
         $LocalGroup = "Администраторы"
         $ADSI = [ADSI]("WinNT://$RemoteComputerName,Computer")
         $Group = $ADSI.PSBase.Children.Find($LocalGroup,'Group')
         $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
         #>
         $ADSI = [ADSI]("WinNT://$PC,Computer")
         $Group = $ADSI.PSBase.Children.Find($g,'Group')
         $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
         [Environment]::NewLine
         Pause

     $Group = [ADSI]"WinNT://t2ru/$PC/$g,group"
     # $Group_Test = Test-Connection -"$PC/Операторы настройки сети,group"
     # if ($Group_Test -eq $true){
     }
     
     if ($Group.Invoke("Add",$ADSIuser.PSBase.Path)) {
         # $Group = [ADSI]"WinNT://t2ru/$PC/Network Configuration Operator,group"
         # $Group.Invoke("Add",$User.PSBase.Path)}
        }
     else {
         write-host "Пользователь $login успешно добавлен в $g на $PC !" -ForegroundColor Green
         write-host "`n"

        # write-host  'Текущее наполнение группы:'  -ForegroundColor Yellow
         <# WORK original
         $RemoteComputerName = "WSZI-NGTIATE-03"
         $LocalGroup = "Администраторы"
         $ADSI = [ADSI]("WinNT://$RemoteComputerName,Computer")
         $Group = $ADSI.PSBase.Children.Find($LocalGroup,'Group')
         $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
         #>
         $ADSI = [ADSI]("WinNT://$PC,Computer")
         $Group = $ADSI.PSBase.Children.Find($g,'Group')
         $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
         
        }
}
while ($Error[0] -like '*Не найдено имя группы*')
[Environment]::NewLine


# write-host "Срипт поставлен на паузу на 15 минут" -ForegroundColor Red
write-host "Скрипт поставлен на паузу ровно на 20 минут в:" -ForegroundColor Red
Get-Date -Format T
write-host "Через 20 минут пользователь будет удалён из указанной группы" -ForegroundColor Red
[Environment]::NewLine
Set-Clipboard -Value "При попытке запроса админских прав введите логин и пароль от своей учётной записи. Там везде далее и ок"
write-host "Текст комментария для пользователя скопирован в буфер обмена" -ForegroundColor Green
Wait-Event -Timeout 1200

      #$computer = "WSZI-NGTIATE-03";
      #$domainUser = "t2ru/denis.tirskikh";
      $groupObj =[ADSI]"WinNT://$PC/$g,group"
      $userObj = [ADSI]"WinNT://t2ru/$login,user"
      #$groupObj.Remove($userObj.Path)

     if ($groupObj.Remove($userObj.Path)) {
       # [ADSI]"WinNT://NBUU-ZAYAKHANOV/$'Пользователи удаленного рабочего стола',group".remove([ADSI]"WinNT://t2ru/$login,user".path)
     }
     else {
      write-host "Пользователь $login успешно удалён из $g на $PC !" -ForegroundColor Green
      write-host "`n"
    
      [Environment]::NewLine
      $ADSI = [ADSI]("WinNT://$PC,Computer")
      $Group = $ADSI.PSBase.Children.Find($g,'Group')
      $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
      [Environment]::NewLine    
    
    }
[Environment]::NewLine


