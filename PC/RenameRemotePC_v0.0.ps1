    $PcName = Read-Host "Старое имя компьютера"
 $NewPcName = Read-Host "Новое имя компьютера"
 $AdmWSDomCred = Get-Credential

Rename-Computer -NewName $NewPCName -ComputerName $PCname -restart -verbose -confirm -ErrorVariable ErrRen -DomainCredential $AdmWSDomCred