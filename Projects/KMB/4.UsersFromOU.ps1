
# скрипт на получение данных с:
# https://app.corp.tele2.ru/IT-Landscape/_api/web/lists/getByTitle('it-systems')/Items?$top=1000
# и конвертации их в CSV

  do {
    $Branch = $Null
    $Branch = Read-Host "Branch"

  
    $OUpath = "OU=Users,OU=$Branch,OU=Branches,DC=corp,DC=tele2,DC=ru"
  # $ExportPath = 'D:\Scripts\PowerShell\КМБ\4.csv'
    $LogName = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")
    
  # Get-ADUser -Filter * -SearchBase $OUpath | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $LogName
  # Get-ADUser -Filter * -SearchBase $OUpath | Select-object SamAccountName | Export-Csv -NoType $LogName
    <#
    $SamAccountNames = Get-ADUser -Filter * -SearchBase $OUpath | Select-object SamAccountName
    $SamAccountNames
    $SamAccountNames | Export-Csv -NoType $LogName
    #>
    $GetAD = Get-ADUser -Filter * -SearchBase $OUpath -ErrorVariable ErrAD
    $SamAccountNames = $GetAD | Select-object SamAccountName

    
  # Out-File -FilePath $LogName -InputObject $X    

  } while ($Branch -like '' -or $ErrAD)
  

  $SamAccountNames
  $SamAccountNames | Export-Csv -NoType $LogName
  & $Logname



  
