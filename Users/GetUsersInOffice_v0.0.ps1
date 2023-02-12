# Version: 0.0
# STATUS: Работает при ручном выделении строк
# ПРЕДНАЗНАЧЕНИЕ: Подсчёт и вывод активных пользователей в конкретном офисе, а не во всём бранче
[Environment]::NewLine

$City = Read-Host "Город на РУССКОМ языке"

$SearchText = "*$City Региональный Филиал*"
#$GetAdUser = get-aduser -filter {Office -like '*Кызыл Региональный Филиал*'} | Where-Object {$_.Enabled -like "True"}
$GetAdUser = get-aduser -filter {Office -like '*Тюмень Региональный Филиал*'} | Where-Object {$_.Enabled -eq $true}
#$GetAdUser = get-aduser -filter {Office -like "$SearchText"} | Where-Object {$_.Enabled -eq $true}
#(get-aduser -filter {Office -like '*Тюмень Региональный Филиал*'} | Where-Object {$_.Enabled -eq $true}).SamAccountName
#get-aduser -filter {sapTitle -like '*Специалист*'} -properties SamAccountName

 $GetAdUser.SamAccountName
 [Environment]::NewLine

 $GetAdUser.SamAccountName.Count
#$GetAdUser.count
[Environment]::NewLine