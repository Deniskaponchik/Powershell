# ��������� �����: Windows-1251
# ������� ��������� ������ �� ��� � �������

  function UserLogin {
# $u, $us, $ResultUL = $null

do { #$Error[0], $lo = $null
if ($null -eq $u) {$u = Read-Host "����� ��� ��� "}
  if ($us = Get-ADUser -Filter "SamAccountName -like '$u'") {
    $u = $us.SamAccountName
    $Global:lo = 1
  }
  elseif ($null -eq ($us = Get-ADUser -Filter "displayname -like '$u'")) {$us = Get-ADUser -Filter "displayname -like '$u*'"}
              $u = $us.SamAccountName #.count
			# $Global:u = $us.SamAccountName
            if ($u.count -gt 1 ) {
               Write-Host $u
			   # $u
              Write-Host "������� ��������� �������! �������� ����������� ������ � ������ � ��������� ����" -ForegroundColor RED} }
while ($u.count -gt 1 -or $u -eq '' -or $us -eq $Null -or $Error[0] -like '*������*' -or $Error[0] -like '*���������*')

$Login = [string]$u

# Return $ResultUL = Get-ADUser -identity $u -properties *
  Return $login

} 

