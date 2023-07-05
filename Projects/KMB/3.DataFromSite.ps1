
# скрипт на получение данных с:
# https://app.corp.tele2.ru/IT-Landscape/_api/web/lists/getByTitle('it-systems')/Items?$top=1000
# и конвертации их в CSV


[Environment]::NewLine
  do {
 
    <# РАБОЧЕЕ
    $username = "t2ru\denis.tirskikh"
    $password = "******"
    $url = "https://app.corp.tele2.ru/IT-Landscape/_api/web/lists/getByTitle('it-systems')/Items?\$top=1000"
    $path = "D:\Scripts\PowerShell\KMB\3.xml"
    $web = New-Object System.Net.WebClient
    $web.Credentials = new-object System.Net.NetworkCredential($username, $password)
    $web.DownloadFile($url, $path)
    #>

    # Можно менять
    $url, $username, $password = $null
    $CSVfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "csv")
    #$CSVfile
    $XMLfile = [System.IO.Path]::ChangeExtension($MyInvocation.InvocationName, "xml")
    #$XMLfile

    $url = Read-Host "url"
    $username = Read-Host "login"
    $password = Read-Host "password" -AsSecureString
    
   #$path = "D:\Scripts\PowerShell\КМБ\3.xml"
    $web = New-Object System.Net.WebClient
    #[Net.ServicePointManager] :: SecurityProtocol + = 'tls12'
    $web.Credentials = new-object System.Net.NetworkCredential($username, $password)
   #$web.DownloadFile($url, $path)
    $web.DownloadFile($url, $XMLfile)
  


# CONVERT
#[xml]$inputFile = Get-Content "D:\Scripts\PowerShell\KMB\3.DataFromSite.xml" -Encoding:UTF8
 [xml]$inputFile = Get-Content $XMLfile -Encoding:UTF8



#$inputFile.Transaction.TXNHEAD | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path "c:\pstest\test.csv" -Encoding UTF8
#$inputFile.Transaction.TXNDETAIL | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Add-Content -Path "c:\pstest\test.csv" -Encoding UTF8
#$inputFile.feed.entry | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path "D:\Scripts\PowerShell\KMB\3.csv" -Encoding UTF8
#$inputFile.feed.entry | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path $CSVfile -Encoding UTF8
$inputFile.feed.entry.Content.properties | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path $CSVfile -Encoding UTF8
# [System.Text.Encoding]::Default.Codepage     # Check system encoding

 & $CSVfile

} while ($url -like '' -or $ErrSite)

[Environment]::NewLine








<#
function Get-Attributes([Object]$pnode)
{
    if($pnode.HasAttributes) {
        foreach($attr in $pnode.Attributes) {
            $xattString+= $attr.Name + ":" + $attr."#text" + ","
        }
    }
    else {
            $xattString = $pnode.nNode + ": No Attributes,"
    }
    return $xattString
}

function Get-XmlNode([ xml ]$XmlDocument, [string]$NodePath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
    # If a Namespace URI was not given, use the Xml document's default namespace.
    if ([string]::IsNullOrEmpty($NamespaceURI)) { $NamespaceURI = $XmlDocument.DocumentElement.NamespaceURI }   

    # In order for SelectSingleNode() to actually work, we need to use the fully qualified node path along with an Xml Namespace Manager, so set them up.
    $xmlNsManager = New-Object System.Xml.XmlNamespaceManager($XmlDocument.NameTable)
    $xmlNsManager.AddNamespace("ns", $NamespaceURI)
    $fullyQualifiedNodePath = "/ns:$($NodePath.Replace($($NodeSeparatorCharacter), '/ns:'))"

    # Try and get the node, then return it. Returns $null if the node was not found.
    $node = $XmlDocument.SelectSingleNode($fullyQualifiedNodePath, $xmlNsManager)
    return $node
}

cls
# $fin = "<Filepath>\<myFile>.xml"
$fin = "D:\Scripts\PowerShell\KMB\3.DataFromSite.xml"
# $fout = "<Filepath>\<myFile>.csv"
$fout = "D:\Scripts\PowerShell\KMB\3.DataFromSite.csv"

Remove-Item $fout -ErrorAction SilentlyContinue

[xml]$xmlContent = get-content $fin
$row=0
$COMMA=","
#$pNode = "ROOT"
$pNode = "feed"
# Replace all "MyTopNode" with your top node...
$nNode = "entry"

$xmlArray  = @(
    [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})

$xmlArray[$row].Row = $row
$xmlArray[$row].Parent = $pNode
$xmlArray[$row].Node = $nNode
$xmlArray[$row].Attribute = ""
$xmlArray[$row].ItemType = "Root"
$xmlArray[$row].Value = $attr."#text"
$row++

if($xmlContent.feed.HasAttributes) {

    foreach($attr in $xmlContent.feed.Attributes) {

        $xmlArray += @(
            [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
        $xmlArray[$row].Row = $row
        $xmlArray[$row].Parent = $pNode
        $xmlArray[$row].Node = $nNode
        $xmlArray[$row].Attribute = $attr.LocalName
        $xmlArray[$row].ItemType = "Attribute"
        $xmlArray[$row].Value = $attr."#text"
        $row++
    }
}

# Begin TRY
try {
    foreach($node in $xmlContent.feed.ChildNodes) {
        $pNode = "feed"
        $nNode = $node.LocalName
        $xmlArray += @(
            [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
        $xmlArray[$row].Row = $row
        $xmlArray[$row].Parent = $pNode
        $xmlArray[$row].Node = $nNode
        $xmlArray[$row].Attribute = ""
        $xmlArray[$row].ItemType = "Root"
        $xmlArray[$row].Value = $attr."#text"
        $row++

        if($nNode.HasAttributes) {

            foreach($attr in $node.Attributes) {

                $xmlArray += @(
                    [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
                $xmlArray[$row].Row = $row
                $xmlArray[$row].Parent = $pNode
                $xmlArray[$row].Node = $nNode
                $xmlArray[$row].Attribute = $attr.LocalName
                $xmlArray[$row].ItemType = "Attribute"
                $xmlArray[$row].Value = $attr."#text"
                $row++
            }
        }

        foreach($sNode in $node.ChildNodes) {
            $pNode = $nNode
            $snNode = $sNode.LocalName
            $xmlArray += @(
                [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
            $xmlArray[$row].Row = $row
            $xmlArray[$row].Parent = $pNode
            $xmlArray[$row].Node = $snNode
            $xmlArray[$row].Attribute = ""
            $xmlArray[$row].ItemType = "Root"
            $xmlArray[$row].Value = $attr."#text"
            $row++
            if($sNode.HasAttributes) {
                foreach($attr in $sNode.Attributes) {
                    $xmlArray += @(
                        [pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
                    $xmlArray[$row].Row = $row
                    $xmlArray[$row].Parent = $pNode
                    $xmlArray[$row].Node = $snNode
                    $xmlArray[$row].Attribute = $attr.LocalName
                    $xmlArray[$row].ItemType = "Attribute"
                    $xmlArray[$row].Value = $attr."#text"
                    $row++
                }
            }
        }
    }

    $xmlArray | SELECT Row,Parent,Node,Attribute,ItemType,Value | Export-CSV $fout -NoTypeInformation
}

# End TRY
# Begin Catch
Catch [System.Runtime.InteropServices.COMException]
{
    $ErrException = Format-ErrMsg -errmsg $_.Exception
    $ErrorMessage = $_.Exception.Message
    $ErrorID = $_.FullyQualifiedErrorId
    $line = $_.InvocationInfo.ScriptLineNumber

    Write-Host                           "  "
    Write-Host                           "  "
    Write-Host -ForegroundColor DarkMagenta  ""
    Write-Host -ForegroundColor Magenta      "==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!=="
    Write-Host -ForegroundColor DarkMagenta  ""
    Write-Host -ForegroundColor DarkCyan     "Details:"  
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Cyan         "`t  Module:        $modname"
    Write-Host -ForegroundColor Cyan         "`t Section:        $sFunc"
    Write-Host -ForegroundColor Cyan         "`t On Line:        $line"
    Write-Host -ForegroundColor Cyan         "`t File:           $fSearchFile | Search will be skipped!!"
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkCyan      "Exception Message:"  
    Write-Host -ForegroundColor White       "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Yellow       "`t ShortMessage:   $ErrorMessage"       
    Write-Host -ForegroundColor Yellow       "`t ErrorID:        $ErrorID"
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Magenta      "$ErrException"  
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkMagenta  "========================================================================================================================================== "
    Write-Host -ForegroundColor Yellow       "This File will be added to the Skip list. Please restart script $sScriptName ...." 
    Write-Host -ForegroundColor DarkMagenta  "========================================================================================================================================== "
    Write-Host                           "  "
    Write-Host                           "  "
}

Catch
{
    $ErrException = Format-ErrMsg -errmsg $_.Exception
    $ErrorMessage = $_.Exception.Message
    $ErrorID = $_.FullyQualifiedErrorId
    $line = $_.InvocationInfo.ScriptLineNumber

    Write-Host                           "  "
    Write-Host                           "  "
    Write-Host -ForegroundColor DarkRed  "================================================================================================================================================="
    Write-Host -ForegroundColor Red      "==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!=="
    Write-Host -ForegroundColor DarkRed  "================================================================================================================================================="
    Write-Host -ForegroundColor DarkCyan "Details:"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Cyan     "`t  Module:        $modname"
    Write-Host -ForegroundColor Cyan     "`t Section:        $sFunc"
    Write-Host -ForegroundColor Cyan     "`t On Line:        $line"
    Write-Host -ForegroundColor Cyan     "`t File:           $fSearchFile"
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkCyan "Exception Message:"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Yellow      "`t ShortMessage:   $ErrorMessage"       
    Write-Host -ForegroundColor Magenta  "`t ErrorID:        $ErrorID"
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Red      "$ErrException"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "

# Show etended error info if in debug mode.

    if ($extDebug -eq $true) {

        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
        Write-Host -ForegroundColor Red      "Extended Debugging info"  

        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
        $error[0].Exception | Format-List * -Force
        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "

    }

    Write-Host -ForegroundColor DarkRed  "==================================================================================================================================================== "
    Write-Host -ForegroundColor DarkRed  "==================================================================================================================================================== "
    Write-Host                           "  "
    Write-Host                           "  "

    Break
# End Catch
}
# Begin Finally
Finally
{
    "finish."
    Exit 0
# End Finally
}

#>




  
