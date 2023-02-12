# Версия: 0.7
# Статус: Работает
# Реализация: Через внешнюю функцию + feedback
# Проблемы:
# автор: denis.tirskikh@tele2.ru

[Environment]::NewLine
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\ShowPCinfoFun_v0.3.ps1
#$PC = Read-Host "Имя компьютера или IP-адрес"
PCinfo #-PC $PC



[Environment]::NewLine
# Логирование НОВОЕ через БД MS SQL Server
$AdminLogin = $env:USERNAME
$DateStart = Get-Date
$ScriptName= $MyInvocation.MyCommand.Name
$FeedBack = Read-Host "Напиши в свободной форме, как улучшить скрипт "
. \\t2ru\folders\IT-Outsource\Scripts\PowerShell\DataBase\SQL\WsirIt01_ScriptEx_v0.0.ps1
ScriptsExecute -Operation Insert -AdminLogin $AdminLogin -DateStart $DateStart -ScriptName $ScriptName -DateEnd $DateStart -FeedBack $FeedBack


[Environment]::NewLine
