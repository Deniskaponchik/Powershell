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
  $ErrTestCon = $Null
  do {
    $PC = Read-Host "Имя компьютера и ip-адрес"
    #Test-Connection $PC -Quiet -ErrorVariable ErrTestCon -ErrorAction SilentlyContinue
    try {
      Test-Connection $PC -Quiet
    }
    catch {
      $ErrTestCon = 1
      'Компьютер недоступен или некорректно введено имя'
    }
  }
# while ((Test-Connection $PC -Quiet -ErrorVariable ErrTestCon) -eq $False)
# while (((Test-Connection $PC -Quiet -ErrorVariable ErrTestCon) -eq $False) -or ($PC -like ''))
# while ($ErrTestCon -like '*не удаётся проверить аргумент*' -or $PC -like '')
  while ($ErrTestCon -eq 1 -or $PC -like '')


# Список папок на диске C:
  $pathC = "\\$PC\C$\"
# $pathC = "\\NBDM-IKUSCH\C$\"
# Get-ChildItem "\\NBDM-IKUSCH\C$\"
  Get-ChildItem $pathC

  [Environment]::NewLine
  $ChFolder = Read-Host "Имя папки на диске С"
  $path = "\\$PC\C$\$ChFolder\"
# $path = "\\wsir-it-01\C$\Test 2\"
# $path = "\\wsir-it-01\C$\distr"
# $path


  [Environment]::NewLine
  'Последние 5 залогинившихся пользователей:'
  $wcusers = "\\$PC\C$\Users\"
  $GetUsers = get-ChildItem $wcUsers -ErrorAction SilentlyContinue -ErrorVariable NotAccessC | Sort-Object -property LastWriteTime, Name -descending | Select-Object -first 5 | Format-Table Name, LastWriteTime
  $GetUsers
# Обработка непрерывающих ошибок
  if ($NotAccessC -like '*удается найти*') {
    Write-Host "Нет доступа к диску C" -ForegroundColor Red
  }
# Если возникнет доселе не описанная ошибка, то вывести её на экран:
  elseif ($NotAccessC) {$NotAccessC}
  [Environment]::NewLine


  $login = $Null
# $user = "denis.tirskikh"
# $login = "anatoly.broner"
#
# Подгрузка внешней функции UserLogin !!! Кодировка файла должна быть Windows-1251 !!!
  . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.1.ps1
# . \\t2ru\folders\IT-Outsource\Scripts\PowerShell\Functions\UserLogin_v0.4.ps1
#  UserLogin
# $login = [string]$login
# $login = 'ilya.kusch'
  $login = UserLogin
  $login
# Pause
#>

# Задаём будущие права для папки:
# $RightsRead = "Read, ReadAndExecute, ListDirectory"
# $RightsWrite = "Write"
  $RightsWrite = "Modify"
  $InheritSettings = "Containerinherit, ObjectInherit"  # касается этой папки и всех вложенных папок и файлов.
  $PropogationSettings = "None"
  $RuleType = "Allow"

  [Environment]::NewLine
  Write-Host 'Текущие права на папку:' -ForegroundColor Yellow
# $acl = Get-Acl $path | Format-Table
# $acl = Get-Acl $path | Select-Object Path, Owner, Group, Access | Format-List
#        Get-Acl $path | Select-Object Path, Owner, Group, Access | Format-List
# $acl = Get-Acl $path
# Get-Acl "\\NBDM-IKUSCH\C$\перенос\"
# $acl = (get-acl $path).access
  $acl = get-acl $path
  $aclAcc = $acl.Access
  Write-Output $aclAcc
# Pause


<# Зависающий скрипт:
# $perm = $login, $RightsRead, $InheritSettings, $PropogationSettings, $RuleType
  $perm = $login, $RightsWrite, $InheritSettings, $PropogationSettings, $RuleType
  $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $perm
  $acl.SetAccessRule($rule)
  $acl | Set-Acl -Path $path # На этом моменте всё зависает
#>

# Делаем копию существующих прав на папку
# $old_acl = Get-ACL -Path "C:\Folder1"
  $old_acl = Get-ACL -Path $path
# Права и новый пользователь
# $new_acl = New-Object System.Security.AccessControl.FileSystemAccessRule('DOMAIN\Test 2', 'Write,Read', 'ContainerInherit, ObjectInherit', 'None', 'Allow')
  $new_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($login, $RightsWrite, $InheritSettings, $PropogationSettings, $RuleType)
# Изменяем скопированные разрешения
# $old_acl.AddAccessRule($new_acl)
  $old_acl.AddAccessRule($new_acl)
# Устанавливаем все разрешения к папке
# Set-ACL -Path "C:\Folder1" -ACLObject $old_acl
  Set-ACL -Path $path -ACLObject $old_acl



  [Environment]::NewLine
# Вывод итоговых прав папки:
  Write-Host 'Права на папку после внесённых изменений:' -ForegroundColor Yellow
  (get-acl $path).access
# (get-acl "\\wsir-it-01\C$\Test 2\").access
# (get-acl "\\wsir-it-01\C$\Test 2\").access






