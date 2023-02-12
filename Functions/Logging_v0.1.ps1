function Logging
{
    param (
    [Parameter (Mandatory = $true)]
    # [string] $ComputerName,
    [Parameter (Mandatory = $false)]
    # [string] $DiskDrive = "c"

    )

# Логирование:
  $dl = Get-Date -Format "dd.MM HH.mm.ss"
# $dl

# $PSScriptRoot   # текущая директория, из которой был запущен скрипт
# $PSCommandPath  #  полный путь и имя файла скрипта
# $MyInvocation.MyCommand.Path  # содержит полный путь и имя скрипта
# $MyInvocation.MyCommand.Name  # имя файла
  $ScriptName= $MyInvocation.MyCommand.Name   # имя файла

  $LogName = "$dl $Env:Username $ScriptName"
# $LogName = "$Env:Username $ScriptName"
# $LogName 

# Out-File -FilePath "$PSScriptRoot\logs" -InputObject $res
# Out-File -FilePath "$PSScriptRoot\logs\$dl_$Username_$MyInvocation.MyCommand.Name.txt"
# Out-File -FilePath $PSScriptRoot\logs\$dl_$Username_$MyInvocation.MyCommand.Name.txt

  $NewItem = New-Item -Name "$LogName.txt" -Path "$PSScriptRoot\logs"
# $NewItem = New-Item -Name "$LogName.txt" -Path "$PSScriptRoot\logs" -Value "Этот текст будет внутри созданного файла"


}