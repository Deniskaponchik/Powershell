<#  !!!   R E A D   M E   !!!
Популярные локальные группы для добавления (скопировать и вставить, когда скрипт запросит):
 
для возможности изменения ip-адреса машины для инженеров базовых станций и сетевиков:
Операторы настройки сети
Network Configuration Operator
 
Администраторы
Administartors

Пользователи удаленного рабочего стола
Remote Desktop Users
 

Общая структура скрипта:
$User = [ADSI]"WinNT://домен/учетка,user"
$Group = [ADSI]"WinNT://домен/комп/Администраторы,group"
$Group.Invoke("Add",$User.PSBase.Path)
#>

''
# !!! РАБОТАЕТ ТОЛЬКО ТАКАЯ ВАРИАЦИЯ, КОГДА $Null В конце:
$user, $u, $us, $login, $ADSIuser = $Null

# новый идеальный код:
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
$domainuser = [string]$user.SamAccountName
<#
$login = [string]$user.SamAccountName
$ADSIuser = [ADSI]"WinNT://t2ru/$login,user"
#>

do {$PC = Read-Host "Имя компьютера"}
while ((Test-Connection $PC -Quiet) -eq $False)
# if (Test-Connection -ComputerName $PC -Quiet)
[Environment]::NewLine

#do {

    $Error[0] = $null
    # [Environment]::NewLine
    write-host  'Примеры локальных групп:'  -ForegroundColor Green
    'Операторы настройки сети'
    'Network Configuration Operator'
    'Администраторы'
    'Administartors'
    'Пользователи удаленного рабочего стола'
    'Remote Desktop Users'
    
    [Environment]::NewLine
   # if (($g = Read-Host "Локальная группа, из которой удалить") -ne "") {
    if (($LocalGroup = Read-Host "Локальная группа, из которой удалить") -ne "") {
        #$Group = [ADSI]"WinNT://t2ru/$PC/$g,group"
        #$LocalGroup 

     }
     
     write-host  'Текущее наполнение группы:'  -ForegroundColor Yellow
     <# WORK original
     $RemoteComputerName = "WSZI-NGTIATE-03"
     $LocalGroup = "Администраторы"
     $ADSI = [ADSI]("WinNT://$RemoteComputerName,Computer")
     $Group = $ADSI.PSBase.Children.Find($LocalGroup,'Group')
     $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
     #>
     $ADSI = [ADSI]("WinNT://$PC,Computer")
     $Group = $ADSI.PSBase.Children.Find($LocalGroup,'Group')
     $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
     [Environment]::NewLine


      <# Doen't work
      Invoke-Command -ComputerName Test1-Win2k12,Test1-Win2k16 -ScriptBlock{Remove-LocalGroupMember -Group "Administrators" -Member "LabDomain\Alpha"}
      Invoke-Command -ComputerName "WSZI-NGTIATE-03" -ScriptBlock{Remove-LocalGroupMember -Group "Администраторы" -Member "Workstation ZR Admins"}
      #>

      <# WORK original
      $computer = "hp-pc";
      $domainUser = "DomainName/Morgan";
      $groupObj =[ADSI]"WinNT://$computer/Administrators,group" 
      $userObj = [ADSI]"WinNT://$domainUser,user"
      $groupObj.Remove($userObj.Path)
      #>

      #$computer = "WSZI-NGTIATE-03";
      #$domainUser = "t2ru/denis.tirskikh";
      $groupObj =[ADSI]"WinNT://$PC/$LocalGroup,group"
      $userObj = [ADSI]"WinNT://t2ru/$domainUser,user"
      #$groupObj.Remove($userObj.Path)

     if ($groupObj.Remove($userObj.Path)) {}
     else {
      write-host "Пользователь $domainuser успешно удалён из $LocalGroup на $PC !" -ForegroundColor Green
      write-host "`n"
    
      [Environment]::NewLine
      $ADSI = [ADSI]("WinNT://$PC,Computer")
      $Group = $ADSI.PSBase.Children.Find($LocalGroup,'Group')
      $Group.PSBase.Invoke('Members').Foreach{ $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) }
      [Environment]::NewLine
    
    
    
    }

#}while ($Error[0] -like '*Не найдено имя группы*')



