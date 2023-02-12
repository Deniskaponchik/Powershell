# Version: 0.0
# STATUS: Используется в запросах
# Цель: Сбор обратной связи по качеству запускаемых скриптов
# реализация: БД MS SQL Server на WSIR-IT-01
# проблемы:
function ScriptsExecute (
[ValidateSet("Update", "Insert")][String]$Operation,
[datetime]$DateStart, [datetime]$DateEnd, [string]$AdminLogin,[string]$ScriptName, [string]$FeedBack
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
    "Insert" {
        $AdminFIO = (Get-ADUser -Filter "SamAccountName -eq '$AdminLogin'" -properties *).displayname
$FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0_Insert.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
        $sqlcmd.CommandText = $Query
# Переменная $DateEnd задана, но в SQL запросе она не использована для защиты от ошибок
        $Param1 = $sqlCmd.Parameters.Add('@DateStart',$DateStart)
       #$Param2 = $sqlCmd.Parameters.Add('@DateEnd',$DateEnd)
        $Param3 = $sqlCmd.Parameters.Add('@AdminLogin',$AdminLogin)
        $Param4 = $sqlCmd.Parameters.Add('@AdminFIO',$AdminFIO)
        $Param5 = $sqlCmd.Parameters.Add('@ScriptName',$ScriptName)
        $Param6 = $sqlCmd.Parameters.Add('@FeedBack',$FeedBack)
        $rowsAffected = $SqlCmd.ExecuteNonQuery();
        $con.Close()
    }
    "Update" {
        $AdminFIO = (Get-ADUser -Filter "SamAccountName -eq '$AdminLogin'" -properties *).displayname
$FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0_Update.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
        $sqlcmd.CommandText = $Query
        $Param1 = $sqlCmd.Parameters.Add('@DateStart',$DateStart)
        $Param2 = $sqlCmd.Parameters.Add('@DateEnd',$DateEnd)
        $Param3 = $sqlCmd.Parameters.Add('@AdminLogin',$AdminLogin)
        $Param4 = $sqlCmd.Parameters.Add('@AdminFIO',$AdminFIO)
        $Param5 = $sqlCmd.Parameters.Add('@ScriptName',$ScriptName)
        $Param6 = $sqlCmd.Parameters.Add('@FeedBack',$FeedBack)
        $rowsAffected = $SqlCmd.ExecuteNonQuery();
        $con.Close()
    }
  }
}
<#
$AdminLogin = $env:USERNAME
$DateStart = Get-Date
#Start-Sleep -Seconds 2
ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart $DateStart -DateEnd $DateEnd #>
<#$DateEnd = Get-Date
$FeedBack = 'Buy!'
$ScriptName = 'DelTrashFiles'
ScriptsExecute -Operation Update -DateStart $DateStart -DateEnd $DateEnd -Feedback $FeedBack -ScriptName $ScriptName
#>