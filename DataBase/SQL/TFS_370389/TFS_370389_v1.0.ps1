# Get-Command -Module SQLPS
# Install-Module -Name SqlServer -RequiredVersion 21.1.18256
# cd D:\Programms\DataBase
# Install-Script -Name sqlserver.21.1.18256.nupkg


# Create folder for csv file
#($myInvocation.MyCommand.Name).Basename 
$NameScript = (Get-Item $myInvocation.myCommand.path).Basename
$PathScript = (Get-Item $myInvocation.myCommand.path).DirectoryName
$PathScript
#[System.IO.Path]::GetFileNameWithoutExtension("$myInvocation.myCommand.path")
#[System.IO.Path]::GetFileNameWithoutExtension($myInvocation.MyCommand.Name)
New-Item -Path . -Name $NameScript -ItemType "Directory"
[Environment]::NewLine

#[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), ([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "sql" )))
[string]$FileSQL = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Name)), ([System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Name, "sql" )))


# Server, base, table, auth
write-host  'Сервера bpm:'  -ForegroundColor Green
't2ru-tr-tst-02'
't2ru-bpmdb-read'
't2ru-bpmanl-01'
[Environment]::NewLine
#$dataSource = “server\instance”
#$dataSource = "t2ru-tr-tst-02"
 $dataSource = Read-Host "Адрес сервера"

#$database = “master”
 $database = "BPMonline7_8888"

#$TableName = "dbo.account"

 $auth = “Integrated Security=SSPI;”
#$auth = Get-Credential


###   sqlcmd   ###
[Environment]::NewLine
 [DateTime]$StartDateTime = Read-Host "Start Date ( yyyy-MM-dd ) Example: 2022-01-01 "
 [DateTime]$EndDateTime   = Read-Host "  End Date ( yyyy-MM-dd ) Example: 2022-05-31 "
#[DateTime]$StartDateTime = '2021-07-25'
#[DateTime]$EndDateTime   = '2021-07-27'



while ($StartDateTime -le $EndDateTime) {

  [Environment]::NewLine
 #$StartDate000000 = $StartDate+" 00:00:00"
 #$StartDate235959 = $StartDate+" 23:59:59"
  
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
    | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -Delimiter "^" -NoTypeInformation
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


















