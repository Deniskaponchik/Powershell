# $pc = Read-Host "Имя компьютера "
  $pc = "wsir-broner"

# Add-Type –Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.15\Assemblies\v4.5.2\MySql.Data.dll'
  Add-Type –Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.21\Assemblies\v4.5.2\MySql.Data.dll'

# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.44.82;uid=root;pwd=t2root;database=glpi'}
# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.178;uid=spadmin;pwd=T2spar3parts;database=spareparts'} # SpareParts ПОДКЛЮЧАЕТСЯ
# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=glpi;pwd=glpi;database=glpi_db'} # T2RU-GLPI-01
# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=root;pwd=root;database=glpi_db'}
  $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=root;pwd=t2root;database=glpi_db'}
# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=service.glpi;pwd=!08PcGBKFMW;database=glpi_db'}
# $Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=10.77.252.153;uid=service.glpi;pwd=!08PcGBKFMW;database=T2RU-ITDB-01'}

$Connection.Open()
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet
$MYSQLCommand.Connection=$Connection
#
$MYSQLCommand.CommandText='SELECT glpi_computers.name, glpi_computers.contact, glpi_deviceprocessors.designation as procmana, glpi_computers.serial, `
glpi_manufacturers.name as mana, glpi_computermodels.name as compmodel, glpi_computertypes.name, glpi_operatingsystemarchitectures.name as osarch, `
glpi_operatingsystemeditions.name, glpi_operatingsystemservicepacks.name, glpi_operatingsystems.name as osname, glpi_operatingsystemversions.name as oscore, `
glpi_items_devicememories.size as memsize, glpi_devicememories.designation, glpi_devicememorytypes.name, glpi_devicegraphiccards.designation, `
glpi_items_devicegraphiccards.memory, glpi_items_disks.name as diskname, glpi_items_disks.device, glpi_items_disks.totalsize, glpi_items_disks.freesize
FROM ((((((((((((((((glpi_computers LEFT JOIN glpi_manufacturers ON glpi_computers.manufacturers_id = glpi_manufacturers.id) LEFT JOIN glpi_computermodels ON `
glpi_computers.computermodels_id = glpi_computermodels.id) LEFT JOIN glpi_computertypes ON glpi_computers.computertypes_id = glpi_computertypes.id) `
LEFT JOIN glpi_items_operatingsystems ON glpi_computers.entities_id = glpi_items_operatingsystems.items_id) LEFT JOIN glpi_operatingsystemarchitectures ON `
glpi_items_operatingsystems.operatingsystemarchitectures_id = glpi_operatingsystemarchitectures.id) LEFT JOIN glpi_operatingsystemservicepacks ON `
glpi_items_operatingsystems.operatingsystemservicepacks_id = glpi_operatingsystemservicepacks.id) LEFT JOIN glpi_operatingsystemeditions ON `
glpi_items_operatingsystems.operatingsystemeditions_id = glpi_operatingsystemeditions.id) LEFT JOIN glpi_operatingsystems ON `
glpi_items_operatingsystems.operatingsystems_id = glpi_operatingsystems.id) LEFT JOIN glpi_operatingsystemversions ON `
glpi_items_operatingsystems.operatingsystemversions_id = glpi_operatingsystemversions.id) LEFT JOIN glpi_items_devicememories ON `
glpi_computers.id = glpi_items_devicememories.items_id) LEFT JOIN glpi_devicememories ON glpi_items_devicememories.devicememories_id = glpi_devicememories.id) `
LEFT JOIN glpi_devicememorytypes ON glpi_devicememories.devicememorytypes_id = glpi_devicememorytypes.id) LEFT JOIN `
glpi_items_devicegraphiccards ON glpi_computers.id = glpi_items_devicegraphiccards.items_id) LEFT JOIN glpi_devicegraphiccards ON `
glpi_items_devicegraphiccards.devicegraphiccards_id = glpi_devicegraphiccards.id) LEFT JOIN glpi_items_disks ON glpi_computers.id = glpi_items_disks.items_id) LEFT JOIN `
glpi_items_deviceprocessors ON glpi_computers.id = glpi_items_deviceprocessors.items_id) LEFT JOIN glpi_deviceprocessors ON `
glpi_items_deviceprocessors.deviceprocessors_id = glpi_deviceprocessors.id
WHERE (((glpi_computers.name)="' + $pc + '"))'
<# GLPI_DB
$MYSQLCommand.CommandText='SELECT glpi_db.glpi_computers, glpi_computers.contact, glpi_deviceprocessors.designation as procmana, glpi_computers.serial, `
glpi_manufacturers.name as mana, glpi_computermodels.name as compmodel, glpi_computertypes.name, glpi_operatingsystemarchitectures.name as osarch, `
glpi_operatingsystemeditions.name, glpi_operatingsystemservicepacks.name, glpi_operatingsystems.name as osname, glpi_operatingsystemversions.name as oscore, `
glpi_items_devicememories.size as memsize, glpi_devicememories.designation, glpi_devicememorytypes.name, glpi_devicegraphiccards.designation, `
glpi_items_devicegraphiccards.memory, glpi_items_disks.name as diskname, glpi_items_disks.device, glpi_items_disks.totalsize, glpi_items_disks.freesize
FROM ((((((((((((((((glpi_computers LEFT JOIN glpi_manufacturers ON glpi_computers.manufacturers_id = glpi_manufacturers.id) LEFT JOIN glpi_computermodels ON `
glpi_computers.computermodels_id = glpi_computermodels.id) LEFT JOIN glpi_computertypes ON glpi_computers.computertypes_id = glpi_computertypes.id) `
LEFT JOIN glpi_items_operatingsystems ON glpi_computers.entities_id = glpi_items_operatingsystems.items_id) LEFT JOIN glpi_operatingsystemarchitectures ON `
glpi_items_operatingsystems.operatingsystemarchitectures_id = glpi_operatingsystemarchitectures.id) LEFT JOIN glpi_operatingsystemservicepacks ON `
glpi_items_operatingsystems.operatingsystemservicepacks_id = glpi_operatingsystemservicepacks.id) LEFT JOIN glpi_operatingsystemeditions ON `
glpi_items_operatingsystems.operatingsystemeditions_id = glpi_operatingsystemeditions.id) LEFT JOIN glpi_operatingsystems ON `
glpi_items_operatingsystems.operatingsystems_id = glpi_operatingsystems.id) LEFT JOIN glpi_operatingsystemversions ON `
glpi_items_operatingsystems.operatingsystemversions_id = glpi_operatingsystemversions.id) LEFT JOIN glpi_items_devicememories ON `
glpi_computers.id = glpi_items_devicememories.items_id) LEFT JOIN glpi_devicememories ON glpi_items_devicememories.devicememories_id = glpi_devicememories.id) `
LEFT JOIN glpi_devicememorytypes ON glpi_devicememories.devicememorytypes_id = glpi_devicememorytypes.id) LEFT JOIN `
glpi_items_devicegraphiccards ON glpi_computers.id = glpi_items_devicegraphiccards.items_id) LEFT JOIN glpi_devicegraphiccards ON `
glpi_items_devicegraphiccards.devicegraphiccards_id = glpi_devicegraphiccards.id) LEFT JOIN glpi_items_disks ON glpi_computers.id = glpi_items_disks.items_id) LEFT JOIN `
glpi_items_deviceprocessors ON glpi_computers.id = glpi_items_deviceprocessors.items_id) LEFT JOIN glpi_deviceprocessors ON `
glpi_items_deviceprocessors.deviceprocessors_id = glpi_deviceprocessors.id
WHERE (((glpi_computers.name)="' + $pc + '"))'
#>
<# SPAREPARTS
$MYSQLCommand.CommandText='SELECT spareparts_computers.name, spareparts_computers.contact, spareparts_deviceprocessors.designation as procmana, spareparts_computers.serial, `
spareparts_manufacturers.name as mana, spareparts_computermodels.name as compmodel, spareparts_computertypes.name, spareparts_operatingsystemarchitectures.name as osarch, `
spareparts_operatingsystemeditions.name, spareparts_operatingsystemservicepacks.name, spareparts_operatingsystems.name as osname, spareparts_operatingsystemversions.name as oscore, `
spareparts_items_devicememories.size as memsize, spareparts_devicememories.designation, spareparts_devicememorytypes.name, spareparts_devicegraphiccards.designation, `
spareparts_items_devicegraphiccards.memory, spareparts_items_disks.name as diskname, spareparts_items_disks.device, spareparts_items_disks.totalsize, spareparts_items_disks.freesize
FROM ((((((((((((((((spareparts_computers LEFT JOIN spareparts_manufacturers ON spareparts_computers.manufacturers_id = spareparts_manufacturers.id) LEFT JOIN spareparts_computermodels ON `
spareparts_computers.computermodels_id = spareparts_computermodels.id) LEFT JOIN spareparts_computertypes ON spareparts_computers.computertypes_id = spareparts_computertypes.id) `
LEFT JOIN spareparts_items_operatingsystems ON spareparts_computers.entities_id = spareparts_items_operatingsystems.items_id) LEFT JOIN spareparts_operatingsystemarchitectures ON `
spareparts_items_operatingsystems.operatingsystemarchitectures_id = spareparts_operatingsystemarchitectures.id) LEFT JOIN spareparts_operatingsystemservicepacks ON `
spareparts_items_operatingsystems.operatingsystemservicepacks_id = spareparts_operatingsystemservicepacks.id) LEFT JOIN spareparts_operatingsystemeditions ON `
spareparts_items_operatingsystems.operatingsystemeditions_id = spareparts_operatingsystemeditions.id) LEFT JOIN spareparts_operatingsystems ON `
spareparts_items_operatingsystems.operatingsystems_id = spareparts_operatingsystems.id) LEFT JOIN spareparts_operatingsystemversions ON `
spareparts_items_operatingsystems.operatingsystemversions_id = spareparts_operatingsystemversions.id) LEFT JOIN spareparts_items_devicememories ON `
spareparts_computers.id = spareparts_items_devicememories.items_id) LEFT JOIN spareparts_devicememories ON spareparts_items_devicememories.devicememories_id = spareparts_devicememories.id) `
LEFT JOIN spareparts_devicememorytypes ON spareparts_devicememories.devicememorytypes_id = spareparts_devicememorytypes.id) LEFT JOIN `
spareparts_items_devicegraphiccards ON spareparts_computers.id = spareparts_items_devicegraphiccards.items_id) LEFT JOIN spareparts_devicegraphiccards ON `
spareparts_items_devicegraphiccards.devicegraphiccards_id = spareparts_devicegraphiccards.id) LEFT JOIN spareparts_items_disks ON spareparts_computers.id = spareparts_items_disks.items_id) LEFT JOIN `
spareparts_items_deviceprocessors ON spareparts_computers.id = spareparts_items_deviceprocessors.items_id) LEFT JOIN spareparts_deviceprocessors ON `
spareparts_items_deviceprocessors.deviceprocessors_id = spareparts_deviceprocessors.id
WHERE (((spareparts_computers.name)="' + $pc + '"))'
#>

$MYSQLDataAdapter.SelectCommand=$MYSQLCommand
# $NumberOfDataSets=$MYSQLDataAdapter.Fill($MYSQLDataSet, "data")

#"---------PC Parameters----------"
""
"System Name      : {0}" -f $DataSet.name
"User             : {0}" -f $DataSet.contact
"Processor        : {0}" -f $DataSet.procmana
"Manufacturer     : {0}" -f $DataSet.mana
"Model            : {0}" -f $DataSet.compmodel
"S/N              : {0}" -f $DataSet.serial
"Caption          : {0}" -f $DataSet.osname  + " ver " + $DataSet.oscore
"OSArchitecture   : {0}" -f $DataSet.osarch

$i=0
foreach($DataSet in $MYSQLDataSet.tables[0])
{
$i=$DataSet.memsize +$i

#write-host "PC:" $DataSet.name  "user:" $DataSet.contact
}
"Total Memory (MB): {0}" -F $i
$j=1
$k=""
foreach ($DataSet in $MYSQLDataSet.tables[0])
{
    if ($k -ne $DataSet.diskname ){
    "Disk $j Model     : {0}" -f $DataSet.diskname
    }  
    
    $k=$DataSet.diskname 
    $j++
    
} 
$j=1
$part=""
foreach ($DataSet in $MYSQLDataSet.tables[0]) 
    {
    $part1=$DataSet.device
    if ($part -ne $DataSet.device ){
    "Part $part1          : {0}" -f  "Size " + ([math]::round(($DataSet.totalsize / 1024 / 1024), 2)) + " Free " + ([math]::round(($DataSet.freesize / 1024 / 1024), 2))     
    }
    $part=$DataSet.device
    }
   

#Clear-Variable $DataSet

$Connection.Close()
pause