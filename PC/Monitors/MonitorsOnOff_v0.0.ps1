<# VARIANT 0
#(Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)
#Another approach to keep powershell input alive is using PostMessage instead of SendMessage
# Monitors ON
#(Add-Type "[DllImport(""user32.dll"")] public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);" -Name "Win32PostMessage" -Namespace Win32Functions -PassThru)::PostMessage(0xffff, 0x0112, 0xF170, 2)
# Monitors OFF
#(Add-Type "[DllImport(""user32.dll"")] public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);" -Name "Win32PostMessage" -Namespace Win32Functions -PassThru)::PostMessage(0xffff, 0x0112, 0xF170, -1)
#>

<# VARIANT 1
Add-Type -Namespace Win32API -Name Message -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(
        int hWnd,
        UInt32 Msg,
        int wParam,
        int lParam
    );
'@
$msg = @{
    HWND_Broadcast = 0xFFFF
    WM_SysCommand = 0x0112
    SC_MonitorPower = 0xF170
    PowerOn = -1
    PowerOff = 2
}
Function Start-Display {
    [CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/Turn-the-Display-On-and-Off-3414d706')]    
    Param()
    [Win32API.Message]::SendMessage($msg.HWND_Broadcast, $msg.WM_SysCommand, $msg.SC_MonitorPower, $msg.PowerOn) 
}
Function Stop-Display {
    [CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/Turn-the-Display-On-and-Off-3414d706')]
    Param()
    [Win32API.Message]::SendMessage($msg.HWND_Broadcast, $msg.WM_SysCommand, $msg.SC_MonitorPower, $msg.PowerOff)
}
New-Alias -Name sadp -Value Start-Display
New-Alias -Name spdp -Value Stop-Display
#>

""
"!!! DO NOT CLOSE THIS WINDOW. IT IS MONITORS ON/OFF SCRIPT !!!"
""

powercfg -x -standby-timeout-ac 0  # отключение спящего режима при работе от сети.
powercfg -x -standby-timeout-dc 0  # отключение спящего режима при работе от батареи.

$Signature = @"
[DllImport("user32.dll")]
public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, 
IntPtr lParam);

[DllImport("user32.dll")]
public static extern void mouse_event(Int32 dwFlags, Int32 dx, Int32 dy, Int32 dwData, UIntPtr dwExtraInfo);
"@
Try {
  $ShowWindowAsync = Add-Type -MemberDefinition $Signature -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru -ErrorAction Ignore}
Catch {}
$MONITOR_ON = -1;
$MONITOR_OFF = 2;
$MONITOR_STANBY = 1;
[System.Int64]$MOUSEEVENTF_MOVE = 0x0001;
[System.IntPtr]$HWND_BROADCAST = New-Object System.IntPtr(0xffff)
[System.UInt32]$WM_SYSCOMMAND = 0x0112
[System.IntPtr]$SC_MONITORPOWER = New-Object System.IntPtr(0xF170)
# this commands puts monitors to sleep
# $ShowWindowAsync::SendMessage($HWND_BROADCAST, $WM_SYSCOMMAND, $SC_MONITORPOWER, [System.IntPtr]$MONITOR_OFF);
# this command wakes monitors up
# $ShowWindowAsync::mouse_event($MOUSEEVENTF_MOVE, 0, 1, 0, [System.UIntPtr]::Zero);

<# Боевые времена ВЫКЛЮЧЕНИЯ экранов
$GTdate1 = "22:00"
$LTdate1 = "23:59"
$GTdate2 = "00:00"
$LTdate2 = "08:00"
#>
#$Deldate = [datetime]::ParseExact("$GTdate", 'HH:mm', $null)
#$Newdate = [datetime]::ParseExact("$LTdate", 'HH:mm', $null)
# TEST times ВЫКЛЮЧЕНИЯ экранов
$GTdate1 = "10:00"
$LTdate1 = "10:30"
$GTdate2 = "11:00"
$LTdate2 = "11:30"

Do {
    $d1 = Get-Date -Format HH:mm #$d1 = Get-Date -Format mm
    $d1
    #if(($d1 -gt $GTdate) -and ($d1 -lt $LTdate)){
    if(($d1 -gt $GTdate1 -and $d1 -lt $LTdate1) -or ($d1 -gt $GTdate2 -and $d1 -lt $LTdate2)){
        #Stop-Display
        #(Add-Type "[DllImport(""user32.dll"")] public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);" -Name "Win32PostMessage" -Namespace Win32Functions -PassThru)::PostMessage(0xffff, 0x0112, 0xF170, 2)
        $ShowWindowAsync::SendMessage($HWND_BROADCAST, $WM_SYSCOMMAND, $SC_MONITORPOWER, [System.IntPtr]$MONITOR_OFF);
        "Monitors OFF"
    }
    else{
        #Start-Display
        #(Add-Type "[DllImport(""user32.dll"")] public static extern int PostMessage(int hWnd, int hMsg, int wParam, int lParam);" -Name "Win32PostMessage" -Namespace Win32Functions -PassThru)::PostMessage(0xffff, 0x0112, 0xF170, -1)
        $ShowWindowAsync::mouse_event($MOUSEEVENTF_MOVE, 0, 1, 0, [System.UIntPtr]::Zero);
        "Monitors ON"
    }
    Start-Sleep -Seconds 300
} 
While($true)
