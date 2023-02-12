
[Environment]::NewLine

$PC = Read-Host "Имя компьютера или ip-адрес"
if (Test-Connection -ComputerName $PC -Quiet) {

<#
2046
4096
8192
16384
#>

<# Общая структура кода изменения файла подкачки:
$System = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges -ComputerName $_.Name
      IF ($System.AutomaticManagedPagefile) {
      $System.AutomaticManagedPagefile = $False
      $System.Put()}
      $PageFile = Get-WmiObject Win32_PageFileSetting -ComputerName $_.Name
      $PageFile.InitialSize = $Size
      $PageFile.MaximumSize = $Size
      $PageFile.Put() | Out-Null
      $PageFile | Select __Server, Name, Initialsize, MaximumSize}
#>

# Изменение файла подкачки (выдели код ниже и F8):
$IntSize = Read-Host "Установи первоначальный размер файла подкачки в  МБ"
$MaxSize = Read-Host "Установи максимальный   размер файла подкачки в  МБ"

$System = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges -ComputerName $PC
IF ($System.AutomaticManagedPagefile) { 
 $System.AutomaticManagedPagefile = $False
 $System.Put()
}
      $PageFile = Get-WmiObject Win32_PageFileSetting -ComputerName $PC
      $PageFile.InitialSize = $IntSize
      $PageFile.MaximumSize = $MaxSize

      $PageFile.Put() | Out-Null
      $PageFile | Select-Object Name, Initialsize, MaximumSize
#>

} else {Write-host "Компьютер $PC недоступен" -ForeGroundColor Red}
