
[Environment]::NewLine
# $Oth00 = 'Текст комментария скопирован в буфер обмена. Можешь завершить скрипт или продолжить его выполнение'
# $OthEnter = "Некорректный выбор параметра" -ForegroundColor Red

Write-Host "1. Байкал и Дальний Восток" -ForegroundColor Cyan
$Oth1 = 'Birobidzhan', 'Khabarovsk', 'Yuzhno-Sakhalinsk', 'Vladivostok', 'Ulan-Ude', 'Magadan', 'Petropavlovsk-Kamchatsky', 'Irkutsk'

Write-Host "2. Сибирь" -ForegroundColor Cyan
$Oth2 = 'Abakan', 'Gorno-Altaysk', 'Barnaul', 'Novokuzneck', 'Kemerovo', 'Kyzyl', 'Tomsk', 'Norilsk', 'Omsk', 'Krasnoyarsk'

Write-Host "3. Урал" -ForegroundColor Cyan
$Oth3 = 'Tumen', 'Syktyvkar', 'Khanty-Mansiysk', 'Kurgan', 'Salekhard', 'Ufa', 'Ekaterinburg', 'Orenburg', 'Perm', 'Chelyabinsk'

Write-Host "4. Черноземье" -ForegroundColor Cyan
$Oth4 = 'Belgorod', 'Voronezh', 'Tambov', 'Kursk', 'Bryansk', 'Penza', 'Lipetsk', 'Saransk', 'Orel', 'Saratov'


Write-Host "5. Волга" -ForegroundColor Cyan
$Oth5 = 'Samara', 'Cheboksary', 'Kazan', 'Nizhniy Novgorod', 'Ulyanovsk', 'Yoshkar-Ola', 'Kirov', 'Izhevsk'

Write-Host "6. Центр" -ForegroundColor Cyan
$Oth6 = 'Smolensk', 'Vladimir', 'Kostroma', 'Ryazan', 'Yaroslavl', 'Kaluga', 'Tver', 'Ivanovo', 'Tula'

Write-Host "7. Северо-Запад" -ForegroundColor Cyan
$Oth7 = 'Saint-Petersburg', 'Arkhangelsk', 'Veliky Novgorod', 'Vologda', 'Kaliningrad', 'Murmansk', 'Petrozavodsk', 'Pskov'

Write-Host "8. Юг" -ForegroundColor Cyan
$Oth8 = 'Volgograd', 'Krasnodar', 'Rostov-on-Don'



do {
    $Macro = $Null
    $Choice = Read-Host 'Укажи цифру макрорегиона'
    Switch ($Choice) {
        0{Exit}
        #1{ClearBrowser}
        #1{Set-Clipboard -Value $PCName}
        1{[Environment]::NewLine
            $Macro = $Oth1
            Write-Host "$Oth1" -ForegroundColor Yellow}
        2{[Environment]::NewLine
            $Macro = $Oth2
            Write-Host "$Oth2" -ForegroundColor Yellow}
        3{[Environment]::NewLine
            $Macro = $Oth3
            Write-Host "$Oth3" -ForegroundColor Yellow}
        4{[Environment]::NewLine
            $Macro = $Oth4
            Write-Host "$Oth4" -ForegroundColor Yellow}
        5{[Environment]::NewLine
            $Macro = $Oth5
            Write-Host "$Oth5" -ForegroundColor Yellow}
        6{[Environment]::NewLine
            $Macro = $Oth6
            Write-Host "$Oth6" -ForegroundColor Yellow}
        7{[Environment]::NewLine
            $Macro = $Oth7
            Write-Host "$Oth7" -ForegroundColor Yellow}
        8{[Environment]::NewLine
            $Macro = $Oth8
            Write-Host "$Oth8" -ForegroundColor Yellow}
        Default {
            # [Environment]::NewLine
            # Write-Host "$OthEnter" -ForegroundColor Yellow
            Write-Host "Некорректный выбор параметра" -ForegroundColor Red
           }
     } 
} while ($Null -eq $Macro)


[Environment]::NewLine
[array]$prop = @(
    "Created",
    "LastLogonDate",
    "Description",
    "OperatingSystem",
    "OperatingSystemServicePack"
    )



#[array]$X = "Name`tIP`tDN`tType`tBranch`tCreated`tLastLogon`tOS"
[array]$X = "Name`tType`tBranch`tCreated`tLastLogon`tOS"

foreach ($Branch in $Macro) {

    [Environment]::NewLine
    $Branch
    # do {$Branch = Read-Host 'Укажи бранч'} while  ($Error[0] -like '*каталога*')
    # $Branch = Read-Host 'Укажи бранч'   

        
    #Get-ADComputer -Filter {(Enabled -eq $true)} -SearchBase "OU=Branches,DC=corp,DC=tele2,DC=ru" `
    Get-ADComputer -Filter {(Enabled -eq $true)} -SearchBase "OU=Computers,OU=$Branch,OU=Branches,DC=corp,DC=tele2,DC=ru" -ResultSetSize $null -Properties $prop | ForEach-Object{
        
        $_.Name
        [array]$dnarr = ($_.DistinguishedName).Split("=,")
        # $ip = $Null
        # [string]$ip = [System.Net.Dns]::GetHostEntry($_).addresslist[0].ipaddresstostring
        
        
        #$X += ($_.Name + "`t" + $_.IP + "`t" + $_.DistinguishedName + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" `
        #$X += ($_.Name + "`t" + $_.DistinguishedName + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" + $_.Created.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + $_.LastLogonDate.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + ($_.operatingSystem + " " + $_.operatingSystemServicePack).Trim()) + "`t" + $_.Description
        $X += ($_.Name + "`t" + $dnarr[1].Substring(0,2).ToUpper() + "`t" + $dnarr[($dnarr.length-9)] + "`t" + $_.Created.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + $_.LastLogonDate.ToString("dd.MM.yyyy HH:mm:ss") + "`t" + ($_.operatingSystem + " " + $_.operatingSystemServicePack).Trim()) + "`t" + $_.Description
    }
}

 

$LogName = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")
Out-File -FilePath $LogName -InputObject $X
& $Logname