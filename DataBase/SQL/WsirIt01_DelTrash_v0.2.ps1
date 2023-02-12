# Version: 0.2
# STATUS: Используется в запросах
# реализация: с выбором варианта инцидента
# проблемы:
function DelTrash (
[ValidateSet("Read", "Write")][String]$Operation,
[string]$SRnumber, [string]$SRlink, [string]$Pcname, [string]$ip, [string]$UserLogin, [string]$AdminLogin, [string]$Comment, [string]$IncidentType, [string]$WorkType
){
$dataSource = "WSIR-IT-01"       # t2ru-bpmdb-read\bpmonline t2ru-tr-tst-02
$database = "ITsupport"
$auth = "Integrated Security=SSPI;"
$connectionString = "Data Source=$DataSource; Initial Catalog=$database; $auth"
#$connectionString = "Data Source=t2ru-tr-tst-02; Initial Catalog=BPMonline7_8888; Integrated Security=SSPI"
# con=SqlConnection, Query=sql
$con = new-object "System.data.sqlclient.SQLconnection"
$con.ConnectionString = $ConnectionString
$con.open()
$sqlcmd = new-object "System.data.sqlclient.sqlcommand"
$sqlcmd.connection = $con
$sqlcmd.CommandTimeout = 10000000
switch ($Operation) {
    "Write" {
        $AdminFIO = (Get-ADUser -Filter "SamAccountName -eq '$AdminLogin'" -properties *).displayname
        $UserFIO = (Get-ADUser -Filter "SamAccountName -eq '$UserLogin'" -properties *).displayname
        [Environment]::NewLine
        Write-Host "1. Заканчивается место на диске C:"
        Write-Host "2. Увеличить ОЗУ"
        Write-Host "3. SMART Диска не ОК"
        Write-Host "4. Обновление Windows"
        Write-Host "5. Другое"
        [Environment]::NewLine
        $Choice = Read-Host "Укажи номер варианта иницидента"
        $IncidentType = switch($Choice){
            1{"Заканчивается место на диске C:"}
            2{"Увеличить ОЗУ"}
            3{"SMART Диска не ОК"}
            4{"Обновление Windows"}
            5{"Другое"}
            Default {"0. Не указано"}
        }
        #try {Test-Path variable:SRnumber}catch {$SRnumber = $NULL}
        $FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_DelTrash_v0.2_Write.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
        $sqlcmd.CommandText = $Query
        $Param1 = $sqlCmd.Parameters.Add('@SRnumber',$SRnumber)
        $Param2 = $sqlCmd.Parameters.Add('@SRlink',$SRlink)
        $Param3 = $sqlCmd.Parameters.Add('@PCname',$PCname)
        $Param4 = $sqlCmd.Parameters.Add('@ip',$ip)
        $Param5 = $sqlCmd.Parameters.Add('@UserLogin',$UserLogin)
        $Param6 = $sqlCmd.Parameters.Add('@UserFIO',$UserFIO)
        $Param7 = $sqlCmd.Parameters.Add('@AdminLogin',$AdminLogin)
        $Param8 = $sqlCmd.Parameters.Add('@AdminFIO',$AdminFIO)
        $Param9 = $sqlCmd.Parameters.Add('@Comment',$Comment)
        $Param10 = $sqlCmd.Parameters.Add('@IncidentType',$IncidentType)
        $Param11 = $sqlCmd.Parameters.Add('@WorkType',$WorkType)
        #$result = $sqlcmd.ExecuteReader()
        $rowsAffected = $SqlCmd.ExecuteNonQuery();
        $con.Close()
        [Environment]::NewLine
    }
    "Read" {
        $Query = "select * from SmacPC where Pcname = '$PCname' order by id DESC" #$Query = "$FileSqlTxt"
        <#$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet)
        $Con.Close()
        $DataSet.Tables[0] #>
        $sqlcmd.CommandText = $Query
        $result = $sqlcmd.ExecuteReader()
        $Table = [System.Data.DataTable]::new()
        $Table.Load($result)
        $con.Close()
        $Table.Columns.ColumnName | % { $Table.Columns[$_].ColumnName = $_.ToUpper()}
        #if ($NULL -eq $Table){return 'Работа не велась'} else {return ,$Table} #$DataSet.Tables[0]}
        [Environment]::NewLine
        return ,$Table
    }
  }
}
<#
$SRlink = 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/cc2559dc-a0c7-41b6-a2bc-021cd0bc27b3'
$AdminLogin = $env:USERNAME
$UserLogin = 'elvira.golubenko'
$PCname = 'WSZR-WEBSHOP-10'
 DelTrash -Operation Write -SRlink $SRlink -AdminLogin $AdminLogin -UserLogin $UserLogin -Pcname $PCname
#$DelTrash = DelTrash -Operation Read -Pcname $PCname
#$DelTrash
#if($DelTrash[0] -eq ''){Write-Host 'Работа не велась'} else {$DelTrash[0]}
#>