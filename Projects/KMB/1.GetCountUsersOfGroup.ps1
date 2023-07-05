
# скрипт для получения кол-ва пользователей в группе BPM9Lic
# (Get-ADGroup "Sys SD BPM7.9Lic" -Properties *).Member.Count

[Environment]::NewLine

  do {
    $Group = $Null
    $Group = Read-Host "Name of AD group"
    (Get-ADGroup $Group -Properties * -ErrorVariable ErrGroup).Member.Count
  } while ($Group -like '' -or $ErrGroup)
  
  [Environment]::NewLine


  
