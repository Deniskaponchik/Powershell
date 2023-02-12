
#Получим список логических дисков, которые не сетевые
$disks = Get-WmiObject Win32_DiskDrive | ForEach-Object {
  $disk = $_
  $partitions = "ASSOCIATORS OF " +
                "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                "WHERE AssocClass = Win32_DiskDriveToDiskPartition"
  Get-WmiObject -Query $partitions | ForEach-Object {
    $partition = $_
    $drives = "ASSOCIATORS OF " +
              "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
              "WHERE AssocClass = Win32_LogicalDiskToPartition"
    Get-WmiObject -Query $drives | ForEach-Object {
      New-Object -Type PSCustomObject -Property @{
        DiskSize    = $disk.Size
        DriveLetter = $_.DeviceID
        VolumeName  = $_.VolumeName
        Size        = $_.Size
        FreeSpace   = $_.FreeSpace
      }
    }
  }
}

#Отсортируем список по алфавиту
$disks = $disks | Sort-Object -Property DriveLetter

#Узнаем какой сейчас размер файла подкачки
$sizeMax = (Get-WmiObject Win32_PagefileSetting | Where-Object {$_.name -eq "C:\pagefile.sys”}).MaximumSize

#Посмотрим, есть ли лишние диски
if ($disks.Length -ge 2){
    
    foreach ($disk in $disks){

     if ($disk.FreeSpace/1024/1024/1024 -ge 10 -and $disk.DriveLetter -ne 'C:' ){

         $Pagefile = Get-WmiObject Win32_PagefileSetting | Where-Object {$_.name -eq $disk.DriveLetter+"\pagefile.sys”}
         
         #Если на диске есть файл подкачки, не будем трогать
            if (-not ([string]::IsNullOrEmpty($Pagefile))){
                continue    
            
            }else{
                
                # если файла подкачки нет, тогда создадим новый и удалим старый
                $Pagefile = Get-WmiObject Win32_PagefileSetting | Where-Object {$_.name -eq “C:\pagefile.sys”}
                $pagefile.Name = $disk.DriveLetter+“\pagefile.sys”
                $pagefile.Caption = $disk.DriveLetter+“\pagefile.sys”
                $pagefile.Description = “’pagefile.sys’ @ "+$disk.DriveLetter
                $pagefile.SettingID =”pagefile.sys @ "+$disk.DriveLetter
                $pagefile.InitialSize = 200
                $pagefile.MaximumSize = $sizeMax
                $pagefile.put()
                $pagefile2 = Get-WmiObject Win32_PagefileSetting | Where-Object {$_.name -eq “C:\pagefile.sys”}
                $pagefile2.delete()
                break
            }
         }

    }

}

###################
# Start-Process Cleanmgr
#Очистим темп
$tempfolders = @( “C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, “C:\Documents and Settings\*\Local Settings\temp\*”, “C:\Users\*\Appdata\Local\Temp\*” )
Remove-Item $tempfolders -force -recurse


###################
#Уменьшим корзину

#
$Size=1024 # Size in MB
$Volume=mountvol C:\ /L 
$Guid=[regex]::Matches($Volume,'{([-0-9A-Fa-f].*?)}')
$RegKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
New-ItemProperty -Path $RegKey -Name MaxCapacity -Value $Size -PropertyType "dword" -Force


New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null 
$LoggedOnSids = (Get-ChildItem HKU: | where { $_.Name -match '(S-([0-9-]*))|.DEFAULT$' }).PSChildName 
foreach ($sid in $LoggedOnSids) {
    $RegKey="HKU:\"+$sid+"\Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume\"+$Guid.value
    try { New-ItemProperty -Path $RegKey -Name MaxCapacity -Value $Size -PropertyType "dword" -Force}
    catch { Write-Host 'Path not found' }
}
