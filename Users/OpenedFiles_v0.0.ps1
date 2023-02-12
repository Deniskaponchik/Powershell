function Test-FileLock {
    param (
      [parameter(Mandatory=$true)][string]$Path
    )
  
    $oFile = New-Object System.IO.FileInfo $Path
  
    if ((Test-Path -Path $Path) -eq $false) {
      #return $false
      return "File not found" #0 #"файл не найден"
    }
  
    try {
      $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  
      if ($oStream) {
        $oStream.Close()
      }
      #return $false
      #return write-host "File is n't opened" -ForeGroundColor Green
      #return 0
    } catch {
      # file is locked by a process.
      #return $true
      #return write-host "File is opened" -ForeGroundColor Red
      if ($path.Contains(".")) {
        # Функция вернёт путь к открытому кем-то файлу, если путь содержит точку
        return write-host $Path -ForeGroundColor Red
      }
    }
}

$Path = "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\"

$FilesInFolder = Get-ChildItem $Path -Force -Recurse # -Force include hidden files
foreach ($SearchedFile in $FilesInFolder) {
  #$SearchedFile.Name
  $SearchedFilePath = $SearchedFile.PSPath.Substring(38)

  #Test-FileLock -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\DelTrashFilesRemote_v0.28.ps1"
  #Test-FileLock -Path "\\t2ru\folders\IT-Outsource\Scripts\PowerShell\PC\$SearchedFile"
   Test-FileLock -Path $SearchedFilePath
  #[Environment]::NewLine
}