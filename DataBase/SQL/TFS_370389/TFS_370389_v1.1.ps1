# Get-Command -Module SQLPS
# Install-Module -Name SqlServer -RequiredVersion 21.1.18256
# cd D:\Programms\DataBase
# Install-Script -Name sqlserver.21.1.18256.nupkg


# Create folder for csv file
[Environment]::NewLine
#($myInvocation.MyCommand.Name).Basename
$NameScript = (Get-Item $myInvocation.myCommand.path).Basename
$PathScript = (Get-Item $myInvocation.myCommand.path).DirectoryName
$PathScript

$CsvPath = Read-Host "Куда выложить csv (По умолчанию создастся папка в директории со скриптом)"
if ($CsvPath -eq '') {
   New-Item -Path . -Name $NameScript -ItemType "Directory"
}
$CsvPath
[Environment]::NewLine


$FileSQL = Read-Host "Путь до sql-файла (по умолчанию директория со скриптом)"
if ($FileSQL -eq '') {
#[System.IO.Path]::GetFileNameWithoutExtension("$myInvocation.myCommand.path")
#[System.IO.Path]::GetFileNameWithoutExtension($myInvocation.MyCommand.Name)
#[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), ([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "sql" )))
[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Name)), ([System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Name, "sql" )))
}
$FileSQL
[Environment]::NewLine

# Server, base, table, auth
write-host  'Сервера bpm:'  -ForegroundColor Green
't2ru-tr-tst-02'
't2ru-bpmdb-read'
't2ru-bpmanl-01'
[Environment]::NewLine
$dataSource = Read-Host "Адрес сервера (по умолчанию t2ru-bpmdb-read\bpmonline )"
if ($dataSource -eq '') {
   $dataSource = "t2ru-bpmdb-read\bpmonline"
}
$dataSource
[Environment]::NewLine

write-host  'Базы данных:'  -ForegroundColor Green
'BPMonline7_8888'
'BPMonline_80'
'BPMonline_SSC'
[Environment]::NewLine
#$dataSource = “server\instance”
#$dataSource = "t2ru-tr-tst-02"
$database = Read-Host "База данных (по умолчанию BPMonline7_8888 )"
 if ($database -eq '') {
    $database = "BPMonline7_8888"
 }
 $database
 [Environment]::NewLine

#$TableName = "dbo.account"

 $auth = “Integrated Security=SSPI;”
#$auth = Get-Credential


[Environment]::NewLine
[DateTime]$StartDateTime = "2022-01-01"
 $StartDateTime = Read-Host "Start Date ( yyyy-MM-dd ) По умолчанию: 2022-01-01 "
 $StartDateTime.DateTime

 
 [Environment]::NewLine
 [DateTime]$EndDateTime = Get-Date
 $EndDateTime = Read-Host "  End Date ( yyyy-MM-dd ) По умолчанию: Get-Date "
 $EndDateTime.DateTime




###   sqlcmd   ###
while ($StartDateTime -le $EndDateTime) {

  [Environment]::NewLine
 #$StartDateTime.ToString("yyyy-MM-dd")     
 #$StartDate = $StartDateTime.ToString("yyyy-MM-dd")  # не работает
  $StartDate = '{0:yyyy-MM-dd}' -f $StartDateTime
  $StartDateFormat = '{0:ddMMyyy}' -f $StartDateTime
  $StartDate

  
   $InvokeVariables = @("StartDate = '$StartDate'")
  #$InvokeVariables = @("StartDate000000 = '$StartDate000000'", "StartDate235959 = '$StartDate235959'")
  #$StringArray = "MYVAR1='String1'", "MYVAR2='String2'"

   $d1 = Get-Date  # Фиксируем время начала отработки скрипта
   Invoke-sqlcmd -ServerInstance $dataSource -Database $database -InputFile $FileSQL -Variable $InvokeVariables `
    | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -NoTypeInformation
   #| Select-Object -Property "Перечень параметров" `
    
   #-Credential -OutputAs    # 
   $d2 = Get-Date  # Фиксируем время окончания отработки скрипта
   'Время выполнения:'
   $d2 - $d1 | Select-Object Minutes, Seconds | Out-Host

  #& "$PathScript\$NameScript\$NameScript.csv"
  #& "$PathScript\$NameScript\$startDate.csv"

  $startDateTime = $StartDateTime.AddDays(1)
}




<#
### System.Data.OleDb ###
# Подгружать файл sql с именем скрипта
# $MyInvocation.MyCommand.Name

#$sql = “SELECT * FROM sysdatabases”
#$sql = “SELECT TOP (10) * FROM dbo.account”
 $sql = Get-Content $FileSQL

#$connectionString = “Provider=sqloledb; ” + “Data Source=$dataSource; “ + “Initial Catalog=$database; “ + “$auth; “
 $connectionString = "Provider=sqloledb; Data Source=$dataSource; Initial Catalog=$database; $auth;"

$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
$command = New-Object System.Data.OleDb.OleDbCommand $sql,$connection
$connection.Open()
$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
$dataset = New-Object System.Data.DataSet
[void] $adapter.Fill($dataSet)
$connection.Close()

# Выгрузка в папку с именем скрипта
$dataset.Tables[0]
$dataset.Tables[0] | Export-Csv -Path "$PathScript\$NameScript\$NameScript.csv" -NoTypeInformation
& "$PathScript\$NameScript\$NameScript.csv"
#$rows=($dataset.Tables | Select-Object -Expand Rows)
#Write-Output $rows
#>


###   SslConnection   ###
<#$SqlServer = "server\instance";
 $SqlServer = "t2ru-tr-tst-02.corp.tele2.ru";
#$SqlCatalog = "база_данных";
 $SqlCatalog = "BPMonline_80";

 $SqlLogin = "";
#$SqlLogin = Read-Host "пользователь (через t2ru\)"
 $SqlPassw = ""
#$SqlPassw = Read-Host "пароль" -AsSecureString
#$auth = Get-Credential

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server=$SqlServer; Database=$SqlCatalog; Integrated Security=True"
 $SqlConnection.ConnectionString = "Server=$SqlServer; Database=$SqlCatalog; User ID=$SqlLogin; Password=$SqlPassw;"
#$SqlConnection.ConnectionString = "Server=$SqlServer; Database=$SqlCatalog; $auth;"

$SqlConnection.Open()
$SqlCmd = $SqlConnection.CreateCommand()
$SqlCmd.CommandText = "SELECT TOP (10) FROM dbo.account"
$objReader = $SqlCmd.ExecuteReader()
while ($objReader.read()) {
  echo $objReader.GetValue(0)
}
$objReader.close()
$SqlConnection.close()
#>


















