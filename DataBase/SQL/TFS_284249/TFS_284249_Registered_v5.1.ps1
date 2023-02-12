# УКАЖИ ТОЛЬКО ПЕРВЫЕ ДВА ПУТИ ПО ШАБЛОНУ
$FileSqlTxt = Get-Content "D:\Scripts\PowerShell\SQL\TFS_284249_Closed_v5.1.sql" -Encoding UTF8 -Raw
$CsvPath = "D:\Scripts\PowerShell\SQL\TFS_284249_Closed_v5.1"

$Query = @"
$FileSqlTxt
"@
$dataSource = "t2ru-bpmdb-read\bpmonline"       # t2ru-bpmdb-read\bpmonline t2ru-tr-tst-02
$database = "BPMonline_80"
$auth = "Integrated Security=SSPI;"
[DateTime]$StartDateTime = "2022-01-01"         # 2022-01-01 2021-07-25  
[DateTime]$EndDateTime = Get-Date               # Get-Date   "2021-07-27"
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
    $DateForCsvName = '{0:dd.MM.yyyy}' -f $StartDateTime
    

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

    $Table | Export-Csv -Path "$CsvPath\$DateForCsvName.csv" -Encoding UTF8 -NoTypeInformation
    # | Export-Csv -Path "$PathScript\$NameScript\SR_BPM7_$startDateFormat.csv" -Encoding UTF8 -Delimiter "^" -NoTypeInformation

    $d2 = Get-Date  # Фиксируем время окончания отработки скрипта
    WRITE-Host 'Время выполнения:' -ForegroundColor Green
    $d2 - $d1 | Select-Object Minutes, Seconds | Out-Host
    
    $startDateTime = $StartDateTime.AddDays(1)
    #{$name = Get-Date(Get-Date).AddDays($i) -f "dd.MM.yyyy" }
  }