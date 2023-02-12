<# Install-Module не работает
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module MySQLCmdlets -Force   #>

# !!! RUN AS LOCAL ADMIN !!!
     

#Write-Host "Запрос прав локального администратора компьютера (5 попыток ввода)"
#$AdminCred = Get-Credential
 $proxy = "https://t2rs-fgproxy.corp.tele2.ru"
     
 $ModuleName = 'ImportExcel'
#$MySqlCmdletsVersion = "21.0.7930.1"
 $Version = "7.8.0"
#$MySQLCmdletNupg = "mysqlcmdlets.$MySqlCmdletsVersion.nupkg"
 $NupgName = "$ModuleName.$Version.nupkg"

#$WebPathMySQlModule = "https://www.powershellgallery.com/packages/MySQLCmdlets/$MySqlCmdletsVersion/"
 $WebPathModule = "https://www.powershellgallery.com/packages/$ModuleName/$Version"
 
#$FpsPathMySQLmodule = "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\MySQL\$MySQLCmdletNupg"     
 $FpsPathModule = "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\Excel\$NupgName"

 $LocPathPSmodules = "$env:ProgramFiles\WindowsPowerShell\Modules\"
#$LocPathMySQLmodule = "$env:ProgramFiles\WindowsPowerShell\Modules\MySQLCmdlets\"
 $LocPathModule = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName\"
    
 New-Item -Path $LocPathModule -ItemType Directory

#Invoke-WebRequest $myDownloadUrl -OutFile c:\file.ext
#Invoke-WebRequest $WebPathMySQlModule -OutFile "$LocPathMySQLmodule\$MySqlCmdletsVersion.zip" -Proxy $proxy
#Invoke-WebRequest : Невозможно соединиться с удаленным сервером
#Move-Item -Path .\sqlserver.21.1.18230.nupkg -Destination .\sqlserver.21.1.18230.zip
#Move-Item -Path .\$MySQLCmdletNupg -Destination $LocPathMySQLmodule\$MySqlCmdletsVersion.zip
#Copy-Item -Path $FpsPathMySQLmodule -Destination $LocPathMySQLmodule\$MySqlCmdletsVersion.zip
 Copy-Item -Path $FpsPathModule -Destination $LocPathModule\$Version.zip 
    
#Expand-Archive -Path .\sqlserver.21.1.18230.zip
#Expand-Archive -Path $LocPathMySQLmodule\$MySqlCmdletsVersion.zip -DestinationPath $LocPathMySQLmodule\$MySqlCmdletsVersion
 Expand-Archive -Path $LocPathModule\$Version.zip -DestinationPath $LocPathModule\$Version


 Import-Module MySQLCmdlets -Verbose
#Pause