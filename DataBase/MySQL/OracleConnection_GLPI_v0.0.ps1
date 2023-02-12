function SQLConnect (
    [string]$ConnectionString,
    [string]$Query,
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

$username = "root"
$password = "t2root"
$DataSource = "10.77.252.153"
$connectionString = "User Id=$username;Password=$password;Data Source=$DataSource"
SQLconnect -ConnectionString $connectionString -DBTypeConnection Oracle -Operation Read -Query "SELECT * FROM glpi_db.glpi_computers"
