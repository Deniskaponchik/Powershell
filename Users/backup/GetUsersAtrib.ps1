<#            !!!   R E A D   M E   !!!
Данный скрипт служит шаблоном для любой популярной выгрузки списка атрибутов пользователей
из txt-файла (называется как имя скрипта)
в csv-файл (называется как имя скрипта)
!!!   Данный скрипт не рекомендуется редактировать  !!! Создавай свою копию под свои нужды   !!!
!!!   Или закомментриуй не нужное
#>

# Берём файл txt из директории скрипта и с именем скрипта:
[string]$file = [System.IO.Path]::Combine(([System.IO.Path]::GetDirectoryName($MyInvocation.InvocationName)), `
([System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "txt" )))

# Подписываем столбцы:
# [array]$res = @("Name`tIP`tOS`tManufacturer`tModel`tMemory`tProcessors`tDisks`tBIOS`tSerial number")
  [array]$res = @("Login`tPosition")
  
# Вариант с автоматическим удалением пустых строк:
# Get-Content $file | ?{$_.Trim() -ne ""} | %{
# Get-Content $file | ?{$_} | %{
# Берём данные, включая пустые строки:
  Get-Content $file | Where-Object{$_ -or $_ -eq ''} | ForEach-Object{
    # $login = $_.Trim().Replace("t2ru\","")
    # $login = $_.Replace("t2ru\","")
    
    # Если взята пустая строка, то и на выходе добавить пустую строку:
      if ($_ -eq '') {
        # if ([string]::IsNullOrWhitespace($_)) {
        # if ($_.Length -eq 0) {
          [string]$login = ""
          [string]$position = ""
       }    
      else {
        $login = $Null
        $position = $Null
        $login = $_.Replace("t2ru\","")
        #>
        # Должность
          $position = $Null
          if ([string]$p = (Get-ADUser $login -Properties title | Select title)) {
            [string]$position = $p.Replace("@{title=","").Replace("@{Title=","").Replace("}","")
          }
          else {
            [string]$position = ""
          }
          # [string]$position = Get-ADUser $login -Properties title | Select Title
          # [string]$p = $position.Replace("@{Title=","").Replace("}","")

          # $res += "$server`t$ip`t$os`t$man`t$mod`t$mem`t$proc`t$disk`t$bios`t$serial"
       }
    $res += "$login`t$position" 
}

[string]$resfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")    # Результаты запроса

"Выгрузка данных в '$resfile'"
Out-File -FilePath $resfile -InputObject $res
& $resfile