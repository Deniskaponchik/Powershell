# STATUS: DOESN'T WORK !!!

add-type -AssemblyName System.Data.OracleClient

$username = "root"
$password = "t2root"
$data_source = "10.77.252.153"
$connection_string = "User Id=$username;Password=$password;Data Source=$data_source"
$statement = "select level, level + 1 as Test from dual CONNECT BY LEVEL <= 10"

try{
    $con = New-Object System.Data.OracleClient.OracleConnection($connection_string)
    $con.Open()
    $cmd = $con.CreateCommand()
    $cmd.CommandText = $statement
    $result = $cmd.ExecuteReader()
    # Do something with the results...

} catch {
    Write-Error ("Database Exception: {0}`n{1}" -f `
        $con.ConnectionString, $_.Exception.ToString())
} finally{
    if ($con.State -eq "Open") { $con.close() }
}