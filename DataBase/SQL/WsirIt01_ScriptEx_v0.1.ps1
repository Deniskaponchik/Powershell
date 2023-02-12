# Version: 0.1
# STATUS: TEST
# реализация: datetime на стороне PS и SQL
# проблемы:
function ScriptsExecute (
[ValidateSet("Update", "Insert")][String]$Operation,
#[datetime]$DateStart, [datetime]$DateEnd, 
[datetime]$DateStart0, [datetime]$DateEnd0, 
[string]$AdminLogin,[string]$ScriptName, [string]$FeedBack
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
        $FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.1_Insert.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
        $sqlcmd.CommandText = $Query
        $Param1 = $sqlCmd.Parameters.Add('@DateStart0',$DateStart0)
        $Param2 = $sqlCmd.Parameters.Add('@DateEnd0',$DateEnd0)
        $Param3 = $sqlCmd.Parameters.Add('@AdminLogin',$AdminLogin)
        $Param4 = $sqlCmd.Parameters.Add('@AdminFIO',$AdminFIO)
        $Param5 = $sqlCmd.Parameters.Add('@ScriptName',$ScriptName)
        $Param6 = $sqlCmd.Parameters.Add('@FeedBack',$FeedBack)
        #$result = $sqlcmd.ExecuteReader()
        $rowsAffected = $SqlCmd.ExecuteNonQuery();
        $con.Close()
        [Environment]::NewLine
    }
    "Update" {
        #$AdminFIO = (Get-ADUser -Filter "SamAccountName -eq '$AdminLogin'" -properties *).displayname
        $FileSqlTxt = Get-Content '\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0_Update.sql' -Encoding UTF8 -Raw
        $Query = "$FileSqlTxt"
        $sqlcmd.CommandText = $Query
        $Param1 = $sqlCmd.Parameters.Add('@DateStart',$DateStart)
        $Param2 = $sqlCmd.Parameters.Add('@DateEnd',$DateEnd)
        $Param3 = $sqlCmd.Parameters.Add('@AdminLogin',$AdminLogin)
        $Param4 = $sqlCmd.Parameters.Add('@AdminFIO',$AdminFIO)
        $Param5 = $sqlCmd.Parameters.Add('@ScriptName',$ScriptName)
        $Param6 = $sqlCmd.Parameters.Add('@FeedBack',$FeedBack)
        #$result = $sqlcmd.ExecuteReader()
        $rowsAffected = $SqlCmd.ExecuteNonQuery();
        $con.Close()
        [Environment]::NewLine
    }
  }
}
#
$AdminLogin = $env:USERNAME
#$DateStart = Get-Date
#$DateEnd = Get-Date
$DateStart0 = Get-Date
$DateEnd0 = Get-Date
#ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart $DateStart -DateEnd $DateEnd
ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart0 $DateStart0 -DateEnd0 $DateEnd0
#$DateEnd = Get-Date
#ScriptsExecute -Operation Update -DateStart $DateStart -DateEnd $DateEnd #-AdminLogin $AdminLogin
#>