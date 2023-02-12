# Кодировка: UTF-8 with BOM

<#
Install-Module -Name NTFSSecurity
Import-Module NTFSSecurity

get-acl C:\Windows\ |fl
(get-acl C:\Windows\).access
(get-acl "\\wsir-it-01\C$\Windows\").access

$path = "c:\drivers"
$user = "WORKSTAT1\user1"
$Rights = "Read, ReadAndExecute, ListDirectory"
$InheritSettings = "Containerinherit, ObjectInherit"
$PropogationSettings = "None"
$RuleType = "Allow"
$acl = Get-Acl $path
$perm = $user, $Rights, $InheritSettings, $PropogationSettings, $RuleType
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $perm
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path $path

$path = "\\wsir-it-01\C$\TEST"
$user = "denis.tirskikh"
$Rights = "Read, ReadAndExecute, ListDirectory"
$InheritSettings = "Containerinherit, ObjectInherit"
$PropogationSettings = "None"
$RuleType = "Allow"
$acl = Get-Acl $path
$perm = $user, $Rights, $InheritSettings, $PropogationSettings, $RuleType
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $perm
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path $path
#>
  [Environment]::NewLine
  do {$PC = Read-Host "Имя компьютера и ip-адрес"}
  while ((Test-Connection $PC -Quiet) -eq $False){}


  $ChFolder = Read-Host "Имя папки на диске С"
  $path = "\\$PC\C$\$ChFolder"

# $user = "denis.tirskikh"
# Подгрузка внешней функции UserLogin !!! Кодировка файла должна быть Windows-1251 !!!
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.1.ps1
# . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.4.ps1
  UserLogin
  $Login


# $RightsRead = "Read, ReadAndExecute, ListDirectory"
  $RightsWrite = "Modify"
  $InheritSettings = "Containerinherit, ObjectInherit"
  $PropogationSettings = "None"
  $RuleType = "Allow"
  $acl = Get-Acl $path
# $perm = $user, $RightsRead, $InheritSettings, $PropogationSettings, $RuleType
  $perm = $login, $RightsWrite, $InheritSettings, $PropogationSettings, $RuleType
  $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $perm
  $acl.SetAccessRule($rule)
  $acl | Set-Acl -Path $path

# Вывод итоговых прав папки:
  (get-acl $path).access






