 # do {$Branch = Read-Host 'Укажи бранч'} while  ($Error[0] -like '*каталога*')
 $Branch = Read-Host 'Укажи бранч'
 
#[array]$X = "Name`tIP`tDN`tType`tBranch`tCreated`tLastLogon`tOS"
[array]$X = "Name`tType`tBranch`tCreated`tLastLogon`tOS"

[array]$prop = @(
    "Created",
    "LastLogonDate",
    "Description",
    "OperatingSystem",
    "OperatingSystemServicePack"
)

#Get-ADComputer -Filter {(Enabled -eq $true)} -SearchBase "OU=Branches,DC=corp,DC=tele2,DC=ru" `
 Get-ADComputer -Filter {(Enabled -eq $true)} -SearchBase "OU=Computers,OU=$Branch,OU=Branches,DC=corp,DC=tele2,DC=ru" `
-ResultSetSize $null -Properties $prop | ForEach-Object{

[array]$dnarr = ($_.DistinguishedName).Split("=,")


# $ip = $Null  
# [string]$ip = [System.Net.Dns]::GetHostEntry($_).addresslist[0].ipaddresstostring

#$X += ($_.Name + "`t" + $_.IP + "`t" + $_.DistinguishedName + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" `
#$X += ($_.Name + "`t" + $_.DistinguishedName + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" + $_.Created.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + $_.LastLogonDate.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + ($_.operatingSystem + " " + $_.operatingSystemServicePack).Trim()) + "`t" + $_.Description
$X += ($_.Name + "`t" + $_.DistinguishedName + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" + $_.Created.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + $_.LastLogonDate.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + ($_.operatingSystem + " " + $_.operatingSystemServicePack).Trim()) + "`t" + $_.Description
}

$LogName = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")

Out-File -FilePath $LogName -InputObject $X
& $Logname