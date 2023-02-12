
# Create folder for csv file
[Environment]::NewLine
#($myInvocation.MyCommand.Name).Basename 
$NameScript = (Get-Item $myInvocation.myCommand.path).Basename
$PathScript = (Get-Item $myInvocation.myCommand.path).DirectoryName
$PathScript


$CsvPath = Read-Host "Куда выложить csv (По умолчанию создастся папка в директории со скриптом)"
if ($CsvPath -eq '') {
    New-Item -Path . -Name $NameScript -ItemType "Directory"
    $CsvPath = "$PathScript\$NameScript"
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
$FileSqlTxt = Get-Content $FileSQL -Encoding UTF8 -Raw
$Query = @"
$FileSqlTxt
"@
[Environment]::NewLine

# Server, base, table, auth
write-host  'Сервера баз данных:'  -ForegroundColor Green
't2ru-bpmdb-read\bpmonline'
't2ru-tr-tst-02'
't2ru-bpmanl-01'
[Environment]::NewLine
#$dataSource = “server\instance”
#$dataSource = "t2ru-tr-tst-02"
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
 




###   SQLconnect   ###
<# РАССКОММЕНТИРУЙ ЭТО, ЕСЛИ БУДЕШЬ ЗАПУСКАТЬ СКРИПТ НЕ ЦЕЛЬНЫМ ФАЙЛОМ, А ТОЛЬКО ЧАСТЬ. 
# УКАЖИ ТОЛЬКО ПЕРВЫЕ ДВА ПУТИ ПО ШАБЛОНУ
$FileSqlTxt = Get-Content "D:\Scripts\PowerShell\SQL\TFS_370389_v2.0.sql" -Encoding UTF8 -Raw
$CsvPath = "D:\Scripts\PowerShell\SQL\TFS_370389_v2.0"

$Query = @"
$FileSqlTxt
"@
$dataSource = "t2ru-bpmdb-read\bpmonline"       # t2ru-bpmdb-read\bpmonline t2ru-tr-tst-02
$database = "BPMonline7_8888"
$auth = "Integrated Security=SSPI;"
[DateTime]$StartDateTime = "2022-01-01"       # 2022-01-01 2021-07-25  
[DateTime]$EndDateTime = Get-Date        # Get-Date   "2021-07-27"
#>

# Итоговая строка подключения
$connectionString = "Data Source=$DataSource; Initial Catalog=$database; $auth"
#$connectionString = "Data Source=t2ru-tr-tst-02; Initial Catalog=BPMonline7_8888; Integrated Security=SSPI"

while ($StartDateTime -le $EndDateTime) {

    [Environment]::NewLine
   #$StartDateTime.ToString("yyyy-MM-dd")     
   #$StartDate = $StartDateTime.ToString("yyyy-MM-dd")  # не работает
    $DateForSqlVariable = '{0:yyyy-MM-dd}' -f $StartDateTime
    $DateForSqlVariable
    $DateForCsvName = '{0:ddMMyyyy}' -f $StartDateTime
    

    $d1 = Get-Date  # Фиксируем время начала отработки скрипта

    $con = new-object "System.data.sqlclient.SQLconnection"
    $con.ConnectionString =$ConnectionString
    $con.open()
    $sqlcmd = new-object "System.data.sqlclient.sqlcommand"
    $sqlcmd.connection = $con
    $sqlcmd.CommandTimeout = 10000000
    $sqlcmd.CommandText = $Query
    $sqlCmd.Parameters.Add('@StartDate',$DateForSqlVariable)
    $result = $sqlcmd.ExecuteReader()
    $Table = [System.Data.DataTable]::new()
    $Table.Load($result)
    $con.Close()
    $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}

    $Table | Export-Csv -Path "$CsvPath\SR_BPM7_$DateForCsvName.csv" -Encoding UTF8 -NoTypeInformation
    # | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -Delimiter "^" -NoTypeInformation

    $d2 = Get-Date  # Фиксируем время окончания отработки скрипта
    'Время выполнения:'
    $d2 - $d1 | Select-Object Minutes, Seconds | Out-Host
    
    $startDateTime = $StartDateTime.AddDays(1)
    #{$name = Get-Date(Get-Date).AddDays($i) -f "dd.MM.yyyy" }
  }



 


 



<# Константин функция
# Итоговая строка подключения
 $connectionString = "Data Source=$DataSource; Initial Catalog=$database; $auth"
#$connectionString = "Data Source=t2ru-tr-tst-02; Initial Catalog=BPMonline7_8888; Integrated Security=SSPI"

$Result = SqlConnect -ConnectionString $connectionString -Query $Query -DBTypeConnection MSSql -Operation Read
$Result = SqlConnect -ConnectionString $connectionString -Query $Query -Variable $Variable -DBTypeConnection MSSql -Operation Read  # C переменными не удалось заставить работать
#$Result | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -NoTypeInformation
 $result | Export-Csv -Path "D:\Scripts\PowerShell\SQL\TFS_370389_v2.0\SR_BPM7_$($anme).csv" -Encoding UTF8 -NoTypeInformation

function SQLConnect (
    [string]$ConnectionString,
    [string]$Query,
    #[string]$Variable,   # C переменными не удалось заставить работать
    [ValidateSet("MSSql", "Oracle")][String]$DBTypeConnection,
    [ValidateSet("Read", "Write")][String]$Operation
) {
    switch ($DBTypeConnection) {
        "MSSql" {
            $con = new-object "System.data.sqlclient.SQLconnection"
            $con.ConnectionString =$ConnectionString
            $con.open()
            $sqlcmd = new-object "System.data.sqlclient.sqlcommand"
            $sqlcmd.connection = $con
            $sqlcmd.CommandTimeout = 10000000
            $sqlcmd.CommandText = $Query
            #$sqlCmd.Parameters.Add('@StartDate',$Variable) # C переменными не удалось заставить работать
            switch ($Operation) {
                "Read"  {
                    $result = $sqlcmd.ExecuteReader()
                    $Table = [System.Data.DataTable]::new()
                    $Table.Load($result)
                    $con.Close()
                    $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
                    return ,$Table
                }
                "Write" {
                    [void]::($sqlcmd.ExecuteNonQuery())
                    $con.Close()
                }
            }
        }
        "Oracle" {
            $con = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($ConnectionString)
            $con.Open()
            $cmd = $con.CreateCommand()
            $cmd.CommandText = $Query
            switch ($Operation) {
                "Read" {
                    $result = $cmd.ExecuteReader()
                    $Table = New-Object "System.Data.DataTable"
                    $Table.Load($result)
                    $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
                }
                "Write" {
                    $cmd.Transaction = $con.BeginTransaction()
                    [void]::($cmd.ExecuteNonQuery())
                    $cmd.Transaction.Commit()
                }
            }
            $con.Close()
            switch ($Operation) {
                "Read" {return ,$Table}
                "Write" {return}
            }
        }
    }
}


# Тут что-то из высшего пилотажа - не смог осилить
    $query = @"
        select top 10 * from [case] where number in (
    "@

    @("sr01","SR02") | % {
        $query += "@"
            '$_',
    "@
    }
    $query = $query.Substring(0.$Query.Length-1)
    $query += ")"  #>


#>






<#
###   sqlcmd   ###

# Get-Command -Module SQLPS
# Install-Module -Name SqlServer -RequiredVersion 21.1.18256
# cd D:\Programms\DataBase
# Install-Script -Name sqlserver.21.1.18256.nupkg


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
#>



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





















