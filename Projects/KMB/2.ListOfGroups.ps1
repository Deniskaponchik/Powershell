# скрипт получения всех групп Sys SD *

[Environment]::NewLine

  do {
    $Group = $Null
    $Group = Read-Host "Name or Part of name of AD group"

  
  #  Get-ADGroup -Filter {Name -like 'Sys SD *'}  -Properties * | Select-Object -property SamAccountName #,Name,Description,DistinguishedName,CanonicalName,GroupCategory,GroupScope,whenCreated
    Get-ADGroup -Filter {Name -like $Group}  -Properties * -ErrorVariable ErrGroup | Select-Object -property SamAccountName #,Name,Description,DistinguishedName,CanonicalName,GroupCategory,GroupScope,whenCreated


    <#
    $Group2 = Get-ADGroup -Filter {Name -like $Group}  -Properties * -ErrorVariable ErrGroup
    foreach ($G in $Group2) {
        $G.SamAccountName
    }
    #>

  } while ($Group -like '' -or $ErrGroup)

  [Environment]::NewLine


  
