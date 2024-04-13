# Version:      0.2
# STATUS:       Протестировано на 3 устройствах
# Цель:         Запуск различных программ для работы Рума
# реализация:   Скрипт запускается в Планировщике задач. В зависимости от входных аргументов он запускаетсяв 2 разных эпостасиях.
# проблемы:     
# Планы:        Получить обратную связь от инженеров
# Last Update:  Добавлена Синхронизация времени от админа при запуске системы
# Author:       denis.tirskikh@tele2.ru


#Внешние входные параметры для скрипта
[CmdletBinding()]
Param (
    [Parameter (Position=1)] #[Parameter (Mandatory=$true, Position=1)]
    #[alias("ARG","ArgumentName")]
    #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
    #[ValidateLength(1,3)]
    [string]
    $username,

    [Parameter (Position=2)] #[Parameter (Mandatory=$true, Position=2)]
    [string]
    $device    
)
[Environment]::NewLine
Write-Host "Username : "$username
Write-Host "Device   : "$device
[Environment]::NewLine
#

#Общие переменные
$exeChrome  = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$exeRoom    = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
$exeService = "C:\Program Files\TrueConf\Room\TrueConfRoomService.exe"
#$pname = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
$processNameRoom = [System.IO.Path]::GetFileNameWithoutExtension($exeRoom)


function TimeSync {
    try {
        #net start w32time
        Start-Service W32Time -ErrorAction Stop -ErrorVariable ErrStartServiceTime
        Write-Host "Windows Time service run" -ForegroundColor Green
    }
    catch {
        Write-Host $ErrStartServiceTime -ForegroundColor Red
        Write-Host "Windows Time service WAS NOT run" -ForegroundColor Red
    }
    [Environment]::NewLine

    w32tm /config /syncfromflags:manual /manualpeerlist:"ntp1.tele2.ru ntp2.tele2.ru ntp3.tele2.ru" /update
}


function MoveWindow {
    param
( 
  [Parameter(Mandatory)]
  [string]
  $ProcessName,

  [Parameter(Mandatory)]
  [Int]
  $MonitorNum,

  [Int]
  $StartDelay = 1
)

Add-Type -assembly System.Windows.Forms
Add-Type -Name WinAPIHelpers -Namespace WinApi -MemberDefinition '
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); 
    
    [DllImport("user32.dll")]
	  public static extern bool SetForegroundWindow(IntPtr hWnd);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

    [DllImport("user32.dll")]
	  [return: MarshalAs(UnmanagedType.Bool)]
	  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);'

    $WinAPI = [WinApi.WinAPIHelpers]
    $Screen = [System.Windows.Forms.Screen]
    $SendKeys = [System.Windows.Forms.SendKeys]

    Start-Sleep -Seconds $StartDelay
    $window = (Get-Process -Name $ProcessName | where {$_.MainWindowHandle -ne ([IntPtr]::Zero)} | select -First 1).MainWindowHandle
    Write-Output "Moving $ProcessName to monitor: $MonitorNum" 
    #Write-Host "Moving $ProcessName to monitor: $MonitorNum" -ForegroundColor Green

    $monitor =  $MonitorNum-1;
    $left = $Screen::AllScreens[$monitor].WorkingArea.Left
    $top = $Screen::AllScreens[$monitor].WorkingArea.Top

    $WinAPI::ShowWindow($window, 9) # 9 == Restore
    $WinAPI::MoveWindow($window, $left, $top, 1000, 800)

    $WinAPI::SetForegroundWindow($window);
    $SendKeys::SendWait("{F11}");
    $SendKeys::Flush();

    Start-Sleep -Seconds $StartDelay
    ## kill full screen browser message - it's w/o title.
    $window = (Get-Process -Name $ProcessName | where {$_.MainWindowHandle -ne ([IntPtr]::Zero)} | select -First 1).MainWindowHandle
    $stringbuilder = New-Object System.Text.StringBuilder 256
    $WinAPI::GetWindowText($window, $stringbuilder, 256) | Out-Null

    if(-Not $stringbuilder.ToString()) {
        $WinAPI::SendMessage($window, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
        Write-Output "Closing F11 window if found"
    }
}

function StopStartChromeTomin {
    #$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    #$exeChrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    #$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
    #$p = (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
    #if ($p -ne $null) {

    try {
        Get-Process $processNameChrome -ErrorAction Stop

        try {
            Stop-Process -Name $processNameChrome -Force -ErrorAction Stop -ErrorVariable ErrStopChrome
            Write-Host "$processNameChrome закрыт" -ForegroundColor Green
            Start-Sleep -Seconds 5
        }
        catch {
            Write-Host $ErrStopChrome -ForegroundColor Red
            Write-Host "$processNameChrome НЕ был закрыт" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Нет ранее запущенного процесса $processNameChrome" -ForegroundColor Green
    }
    
    <#
    BitsPerPixel : 32
    Bounds       : {X=0,Y=0,Width=1280,Height=800}
    DeviceName   : \\.\DISPLAY1
    Primary      : True
    WorkingArea  : {X=0,Y=0,Width=1280,Height=800}

    BitsPerPixel : 32
    Bounds       : {X=1920,Y=0,Width=1920,Height=1080}
    DeviceName   : \\.\DISPLAY2
    Primary      : False
    WorkingArea  : {X=1920,Y=0,Width=1920,Height=1080}
    #>
    try {
        Get-Process $processNameChrome -ErrorAction Stop

        Write-Host "Запущен процесс $processNameChrome. Открыть новый процесс на весь экран невозможно" -ForegroundColor Red
    }
    catch {
        #$exeChrome  = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        #$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)

        Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"

        Set-Location $PSScriptRoot

        #https://superuser.com/questions/720917/starting-multiple-chrome-full-screen-instances-on-multiple-monitors-from-batch
        $ArgsChrome = "--new-window http://localhost/ --hide-crash-restore-bubble"
        $ChromeProcess = Start-Process -FilePath $exeChrome -ArgumentList $ArgsChrome #-PassThru
        #. .\Move-Window.ps1 -ProcessName $processNameChrome -MonitorNum 1
        MoveWindow "Chrome", 1
        
    }
    [Environment]::NewLine
}



function Set-TopMost($handle) {
    $FnDef = '
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(int hWnd, int hAfter, int x, int y, int cx, int cy, uint Flags);
    ';
    $user32 = Add-Type -MemberDefinition $FnDef -Name 'User32' -Namespace 'Win32' -PassThru
    $user32::SetWindowPos($handle, -1, 0,0,0,0, 3)
}

function getChromeProcess {
    return (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
}
#getChromeProcess

function StopStartChromeF11try {
    #$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    #$exeChrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    #$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
    #$p = (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
    #if ($p -ne $null) {

    try {
        Get-Process $processNameChrome -ErrorAction Stop

        try {
            Stop-Process -Name $processNameChrome -Force -ErrorAction Stop -ErrorVariable ErrStopChrome
            Write-Host "$processNameChrome закрыт" -ForegroundColor Green
            Start-Sleep -Seconds 5
        }
        catch {
            Write-Host $ErrStopChrome -ForegroundColor Red
            Write-Host "$processNameChrome НЕ был закрыт" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Нет ранее запущенного процесса $processNameChrome" -ForegroundColor Green
    }
    
    <#
    BitsPerPixel : 32
    Bounds       : {X=0,Y=0,Width=1280,Height=800}
    DeviceName   : \\.\DISPLAY1
    Primary      : True
    WorkingArea  : {X=0,Y=0,Width=1280,Height=800}

    BitsPerPixel : 32
    Bounds       : {X=1920,Y=0,Width=1920,Height=1080}
    DeviceName   : \\.\DISPLAY2
    Primary      : False
    WorkingArea  : {X=1920,Y=0,Width=1920,Height=1080}
    #>
    try {
        Get-Process $processNameChrome -ErrorAction Stop

        Write-Host "Запущен процесс хрома. Открыть новый процесс на весь экран невозможно" -ForegroundColor Red
    }
    catch {
        Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"

        #https://superuser.com/questions/720917/starting-multiple-chrome-full-screen-instances-on-multiple-monitors-from-batch
        #--hide-crash-restore-bubble       --disable-session-crashed-bubble
        #--window-size=1920,1080 
        $ArgsChrome = "--kiosk --fullscreen http://localhost/ --hide-crash-restore-bubble --disable-features=Translate"
        #$ArgsChrome = "--kiosk --fullscreen http://localhost/ --window-position=0,0"
        $ChromeProcess = Start-Process -FilePath $exeChrome -ArgumentList $ArgsChrome #-PassThru
    
        Write-Host "Waiting for process '$processNameChrome'"
        while ($p -eq $null) {
            Start-Sleep -Seconds 1 #-Milliseconds 100

            #$pname = [System.IO.Path]::GetFileNameWithoutExtension($exe)
            #$p = (Get-Process $pname -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
            $p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
            #$p = getChromeProcess
        }

        #Не ставить запятую между аргументами!!!
        MoveWindow $processNameChrome 1
        #Write-Host "$processNameChrome перемещён на 1 дисплей" -ForegroundColor Green

        $p.MainWindowHandle
        Set-TopMost $p.MainWindowHandle

        <#Если хром будет постоянно переоткрываться, то, наверное, нет необходимости в F11
        #inner vbs f11 input
        #https://stackoverflow.com/questions/66529507/powershell-send-f5-key-to-edge
        $wshell = New-Object -ComObject wscript.shell
        Start-Sleep -Seconds 10                  ### increase time for slow connection
        $wshell.AppActivate($ChromeProcess.Id)
        $wshell.SendKeys('{f11}')
        Write-Host "F11 прожато" -ForegroundColor Green
        Start-Sleep -Seconds 2
        #>
    }
    [Environment]::NewLine
}

function StopStartChromeF11if {
    #$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    #$exeChrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    #$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
    #$p = (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
    #if ($p -ne $null) {
    if (getChromeProcess -ne $null) {   
        try {
            Stop-Process -Name "Chrome" -Force -ErrorAction Stop -ErrorVariable ErrStopChrome
            Write-Host "Chrome закрыт" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }
        catch {
            Write-Host $ErrStopChrome -ForegroundColor Red
            Write-Host "Chrome НЕ был закрыт" -ForegroundColor Red
        }
    }

    #$p = (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
    #if ($p -eq $null) {
    if (getChromeProcess -eq $null) {  
        Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"
        $ChromeProcess = Start-Process -FilePath $exeChrome -ArgumentList "--kiosk --fullscreen http://localhost/" #-PassThru
    
        Write-Host "Waiting for process '$processNameChrome'"
        while ($p -eq $null) {
            Start-Sleep -Seconds 1 #-Milliseconds 100
            #$p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
            $p = getChromeProcess
        }

        $p.MainWindowHandle
        Set-TopMost $p.MainWindowHandle

        <#Если хром будет постоянно переоткрываться, то, наверное, нет необходимости в F11
        #inner vbs f11 input
        #https://stackoverflow.com/questions/66529507/powershell-send-f5-key-to-edge
        $wshell = New-Object -ComObject wscript.shell
        Start-Sleep -Seconds 10                  ### increase time for slow connection
        $wshell.AppActivate($ChromeProcess.Id)
        $wshell.SendKeys('{f11}')
        Write-Host "F11 прожато" -ForegroundColor Green
        Start-Sleep -Seconds 2
        #>
    }    
    [Environment]::NewLine
}

function StartChromeF11 {
    #$exe = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

    $processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)

    $p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
    if ($p -eq $null) {
        Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"
        $ChromeProcess = Start-Process -FilePath $exeChrome -ArgumentList "--kiosk --fullscreen http://localhost/" #-PassThru
        
        #inner vbs f11 input
        #https://stackoverflow.com/questions/66529507/powershell-send-f5-key-to-edge
        $wshell = New-Object -ComObject wscript.shell
        Start-Sleep -Seconds 10                  ### increase time for slow connection
        $wshell.AppActivate($ChromeProcess.Id)
        $wshell.SendKeys('{f11}')
        Start-Sleep -Seconds 2
    

        Write-Host "Waiting for process '$processNameChrome'"
        while ($p -eq $null) {
            sleep -Milliseconds 100
            $p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
        }
    }

    $p.MainWindowHandle
    Set-TopMost $p.MainWindowHandle
    [Environment]::NewLine
}

function StartChrome {
    #$exe = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" #--kiosk --fullscreen http://localhost/
    $exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe" #--kiosk --fullscreen http://localhost/

    $processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)

    $p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
    if ($p -eq $null) {
        Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"
        #& $exe
        Start-Process -FilePath $exeChrome -ArgumentList "--kiosk --fullscreen http://localhost/"
        Write-Host "Waiting for process '$processNameChrome'"
        while ($p -eq $null) {
            sleep -Milliseconds 100
            $p = (Get-Process $processNameChrome -ErrorAction "SilentlyContinue") | ? { $_.MainWindowHandle -ne 0 }
        }
    }

    $p.MainWindowHandle
    Set-TopMost $p.MainWindowHandle
    [Environment]::NewLine
}

function StartEdgeF11 {
    #For test
    $url = "http://localhost/"
    $medge = Start-Process -PassThru -FilePath microsoft-edge:$url
    $wshell = New-Object -ComObject wscript.shell

    Start-Sleep -Seconds 10                  ### increase time for slow connection
    while ( $wshell.AppActivate($medge.Id) ) ### activate the desired window
    {
        #$wshell.SendKeys('{f5}')             ### send keys only if successfully activated
        $wshell.SendKeys('{f11}') 
        Start-Sleep -Seconds 10
    }
}

function OuterF11VbsInput {
    $WShell = New-Object -Com "Wscript.Shell"
    $WShell.SendKeys("{F11}")
}

function PressF11vbs {
    #$vbsF11 = "C:\AudioCodes\TrueConf\F11_Press.vbs"
    try {
        #Start-Process -FilePath $vbsF11 #-ArgumentList "--start" #

        $WShell = New-Object -Com "Wscript.Shell"
        $WShell.SendKeys("{F11}")

        Write-Host "vbs, нажимающий F11, запущен" -ForegroundColor Green
    }
    catch {
        Write-Host "vbs, нажимающий F11, не смог запуститься" -ForegroundColor red
    }
    [Environment]::NewLine
}

function ClickLeftMouseF11square {
#Попадает в квадратик
#https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell
    $cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class Clicker
{
    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-input
    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    { 
        public int        type; // 0 = INPUT_MOUSE
                                // 1 = INPUT_KEYBOARD
                                // 2 = INPUT_HARDWARE
        public MOUSEINPUT mi;
    }

    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-mouseinput
    [StructLayout(LayoutKind.Sequential)]
    struct MOUSEINPUT
    {
        public int    dx;
        public int    dy;
        public int    mouseData;
        public int    dwFlags;
        public int    time;
        public IntPtr dwExtraInfo;
    }

    // This covers most use cases although complex mice may have additional buttons.
    // There are additional constants you can use for those cases, see the MSDN page.
    const int MOUSEEVENTF_MOVE       = 0x0001;
    const int MOUSEEVENTF_LEFTDOWN   = 0x0002;
    const int MOUSEEVENTF_LEFTUP     = 0x0004;
    const int MOUSEEVENTF_RIGHTDOWN  = 0x0008;
    const int MOUSEEVENTF_RIGHTUP    = 0x0010;
    const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
    const int MOUSEEVENTF_MIDDLEUP   = 0x0040;
    const int MOUSEEVENTF_WHEEL      = 0x0080;
    const int MOUSEEVENTF_XDOWN      = 0x0100;
    const int MOUSEEVENTF_XUP        = 0x0200;
    const int MOUSEEVENTF_ABSOLUTE   = 0x8000;

    const int screen_length = 0x10000;

    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    public static void LeftClickAtPoint(int x, int y)
    {
        // Move the mouse
        INPUT[] input = new INPUT[3];

        input[0].mi.dx = x * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
        input[0].mi.dy = y * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
        input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;

        // Left mouse button down
        input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;

        // Left mouse button up
        input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;

        SendInput(3, input, Marshal.SizeOf(input[0]));
    }
}
'@

Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing

#Think Smart Hub resolution = 1920x1200
# первый параметр X = расстояние от левого края главного экрана
# второй параметр Y = Расстояние сверху главного экрана
[Clicker]::LeftClickAtPoint(1950, 25)
}

function ClickLeftMouseToBatDesktopScript {
    #Попадает в квадратик
    #https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell
        $cSource = @'
    using System;
    using System.Drawing;
    using System.Runtime.InteropServices;
    using System.Windows.Forms;
    
    public class Clicker
    {
        // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-input
        [StructLayout(LayoutKind.Sequential)]
        struct INPUT
        { 
            public int        type; // 0 = INPUT_MOUSE
                                    // 1 = INPUT_KEYBOARD
                                    // 2 = INPUT_HARDWARE
            public MOUSEINPUT mi;
        }
    
        // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-mouseinput
        [StructLayout(LayoutKind.Sequential)]
        struct MOUSEINPUT
        {
            public int    dx;
            public int    dy;
            public int    mouseData;
            public int    dwFlags;
            public int    time;
            public IntPtr dwExtraInfo;
        }
    
        // This covers most use cases although complex mice may have additional buttons.
        // There are additional constants you can use for those cases, see the MSDN page.
        const int MOUSEEVENTF_MOVE       = 0x0001;
        const int MOUSEEVENTF_LEFTDOWN   = 0x0002;
        const int MOUSEEVENTF_LEFTUP     = 0x0004;
        const int MOUSEEVENTF_RIGHTDOWN  = 0x0008;
        const int MOUSEEVENTF_RIGHTUP    = 0x0010;
        const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
        const int MOUSEEVENTF_MIDDLEUP   = 0x0040;
        const int MOUSEEVENTF_WHEEL      = 0x0080;
        const int MOUSEEVENTF_XDOWN      = 0x0100;
        const int MOUSEEVENTF_XUP        = 0x0200;
        const int MOUSEEVENTF_ABSOLUTE   = 0x8000;
    
        const int screen_length = 0x10000;
    
        // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    
        public static void LeftClickAtPoint(int x, int y)
        {
            // Move the mouse
            INPUT[] input = new INPUT[3];
    
            input[0].mi.dx = x * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
            input[0].mi.dy = y * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
            input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;
    
            // Left mouse button down
            input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    
            // Left mouse button up
            input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;
    
            SendInput(3, input, Marshal.SizeOf(input[0]));
        }
}
'@
    
    Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing
    
    #Think Smart Hub resolution = 1920x1200
    # первый параметр X = расстояние от левого края главного экрана
    # второй параметр Y = Расстояние сверху главного экрана
    [Clicker]::LeftClickAtPoint(50, 50)
    [Clicker]::LeftClickAtPoint(50, 50)
}




function GetCountMonitor1{
    #Через invoke-command
    #НЕ пиши никакой текст в консоль - он пойдёт в результат функции и всё испортит!

    #$MonitorFile = "C:\AudioCodes\TrueConf\MonitorsCount.txt"

        #получаем кол-во подключенных мониторов
        $username = 'AdminTele25'
        $password = 'Tele25s@pport'

        #Вариант1
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword         

        # create an admin user powershell session
        #$s = New-PSSession -Credential $credential 
        New-PSSession -Credential $credential | Enter-PSSession
        Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams

        # non-interactive for scripts:
        #$result1 = 
        Invoke-Command -Session $s -ScriptBlock { 
            #Restart-Service -DisplayName 'Windows Update'
            $MonitorsNew = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
            Return ($MonitorsNew | Measure-Object).count
        }
        #"result1 : " + $result1
        #

    
        #Вариант2
        $secstr = New-Object -TypeName System.Security.SecureString
        $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
        $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

        $result2 = invoke-command -credential $credential {
            #[System.Windows.Forms.Screen]::AllScreens.Count
            #$MonitorsCountNew = (Get-CimInstance Win32_VideoController).count
            #(Get-WmiObject win32_videocontroller).Count
            #Get-WmiObject WmiMonitorID -Namespace root\wmi
            #$MonitorsCountNew =
            $MonitorsNew = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
            #$MonitorsCountNew = 
            ($MonitorsNew | Measure-Object).count
        }
        "result2 : " + $result2
        #
}

function GetCountMonitor2{
    #Через запуск скрипта от имени админа в фоновом режиме
    #The last run of the task was terminated by the user. (0x41306)
    $MonitorFile = "C:\AudioCodes\TrueConf\MonitorsCount.txt"
    $MonitorsCountNew = 0
    do {
        $MonitorsNew = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
        $MonitorsCountNew = ($MonitorsNew | Measure-Object).count

        #[Environment]::SetEnvironmentVariable('CountMonitors', $MonitorsCountNew , 'Machine')
        $MonitorsCountNew | Out-File -Encoding utf8 -FilePath $MonitorFile

        Start-Sleep -Seconds 10

    } while (
        $true
    )
}

function GetCountMonitor3{
    #Start-Process
    #$MonitorFile = "C:\AudioCodes\TrueConf\MonitorsCount.txt"

    #получаем кол-во подключенных мониторов
    $username = 'AdminTele25'
    $password = 'Tele25s@pport'

    #Вариант1
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
    
    <#
    do {
        $MonitorsNew = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
        $MonitorsCountNew = ($MonitorsNew | Measure-Object).count 
        $MonitorsCountNew | Out-File -Encoding utf8 -FilePath $MonitorFile
        Start-Sleep -Seconds 15
    } while (
        $true
    )#>

    #D:\WorkPC\1\txt.txt
    #Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.caption -ne "Универсальный монитор не PnP") -and ($_.caption -ne "Универсальный монитор PnP") -and ($_.caption -ne "Generic Non-PnP Monitor") -and ($_.caption -ne "Generic PnP Monitor") -and ($_.status -eq "OK")} | Sort-Object | Get-Unique #Format-List

    $command = "-noexit -Command &{
        do{
            'This script count monitor once 15 seconds';
            '!!! DO NOT CLOSE !!!';
            (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | Measure-Object).count | Out-File -Encoding utf8 -FilePath 'C:\AudioCodes\TrueConf\MonitorsCount.txt';
            Start-Sleep -Seconds 15;
        }while(1)
    }"

    #Start-Process Powershell -ArgumentList $command -WindowStyle Minimized
     Start-Process Powershell -Credential $credential -ArgumentList $command -WindowStyle Minimized
    

}

function GetCountMonitor4{
    # без админских прав

    <#Через wmic
    #https://superuser.com/questions/1408377/windows-10-command-to-get-current-display-device
    wmic desktopmonitor get /?
    Availability
    Bandwidth 
    ConfigManagerErrorCode                  N/A                     N/A
    ConfigManagerUserConfig                 N/A                     N/A
    Description                             N/A                     N/A
    DeviceID                                N/A                     N/A
    DisplayType                             N/A                     N/A
    ErrorCleared                            N/A                     N/A
    ErrorDescription                        N/A                     N/A
    InstallDate                             N/A                     N/A
    IsLocked                                N/A                     N/A
    LastErrorCode                           N/A                     N/A
    MonitorManufacturer                     N/A                     N/A
    MonitorType                             N/A                     N/A
    Name
    PNPDeviceID
    PixelsPerXLogicalInch
    PixelsPerYLogicalInch
    PowerManagementCapabilities
    PowerManagementSupported
    ScreenHeight
    ScreenWidth
    Status       
    StatusInfo 
    #>

    #getMonitorsInfo
    #Get-PnpDevice | Where-Object {($_.class -eq "Monitor")}
    #Return (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.caption -ne "Универсальный монитор не PnP") -and ($_.caption -ne "Универсальный монитор PnP") -and ($_.caption -ne "Generic Non-PnP Monitor") -and ($_.caption -ne "Generic PnP Monitor") -and ($_.status -eq "OK")}).count #| Sort-Object | Get-Unique #Format-List
    Return (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.status -eq "OK")}).count

}

function test{
    #$MonitorsCountNew = 0
    <#
    do {
        $MonitorsCountNew++
        
        #$MonitorFile = "C:\AudioCodes\TrueConf\MonitorsCount.txt"
        #[Environment]::SetEnvironmentVariable('CountMonitors', $MonitorsCountNew , 'Machine')
        #$MonitorsCountNew | Out-File -Encoding utf8 -FilePath $MonitorFile

        Start-Sleep -Seconds 10
        #PAUSE
    } while (
        $true
    )#>
    return Get-Random -max 100 -min 1
}

function EditRoomServiceJson {
    $jsonPath = "C:\ProgramData\TrueConfRoomService\settings.json"
    try {
        #$json = Get-Content -Path C:\PS\userroles.json -Raw | ConvertFrom-Json
        $json = Get-Content -Path $jsonPath -Raw -ErrorAction Stop -ErrorVariable ErrGetJson | ConvertFrom-Json
        #вывести все свойства объекта JSON:
        #$json|fl

        #$json.TCRSpid = -1
         $json.roomMonitorIndex = 2
        #$json.SleepModeTimeout = 0
        $json.isRoomMonitorDefault = $true #"true"
        #$json.pin = "123"
        #$json.ScrSaverPath = "" #C:/Program Files/TrueConf/Room/SleepMode.exe
        #$json.interfaceLanguage = "ru"
        #$json.webMonitorIndex = 1
        #$json.isWebMgrMonitorDefault = $true #"true"
        $json.webMgrStartMode = "Manual"

        try {
            #$json |ConvertTo-Json | Set-Content -Path C:\PS\userroles.json
            $json | ConvertTo-Json | Set-Content -Path $jsonPath -ErrorAction Stop -ErrorVariable ErrSetJson
    
            Write-Host "Успешно Отредактирован файл настроек TrueConf Room:" -ForegroundColor Green
            Write-Host $jsonPath -ForegroundColor Green
            [Environment]::NewLine
            Write-Host "Внесены следующие изменения:" -ForegroundColor Green
            #Write-Host "* Выключен спящий режим, который ВОЗМОЖНО приводит к белому экрану" -ForegroundColor Green
            Write-Host "* Для запуска приложения Room выбран дисплей номер 2" -ForegroundColor Green
            Write-Host "* Запуск web manager переведён в ручной режим" -ForegroundColor Green
            [Environment]::NewLine
        }
        catch {
            Write-Host $ErrSetJson -ForegroundColor Red
            Write-Host "Не удалось сохранить файл настроек TrueConf Room" -ForegroundColor Red
            Write-Host "Проверь путь:" -ForegroundColor Red
            Write-Host $jsonPath -ForegroundColor Red
            Write-Host "Это критическая ошибка. Сообщи denis.tirskikh@tele2.ru" -ForegroundColor Red
        }
    }
    catch {
        Write-Host $ErrGetJson -ForegroundColor Red
        Write-Host "Не удалось открыть файл настроек TrueConf Room для редактирования" -ForegroundColor Red
        Write-Host "Проверь путь:" -ForegroundColor Red
        Write-Host $jsonPath -ForegroundColor Red
        Write-Host "Это критическая ошибка. Сообщи denis.tirskikh@tele2.ru" -ForegroundColor Red
    }    
    
    [Environment]::NewLine
}

function StartRoomService{
     #"C:\Program Files\TrueConf\Room\TrueConfRoomService.exe" start
    $exeRoomService = "C:\Program Files\TrueConf\Room\TrueConfRoomService.exe"
    try {
        Start-Process -FilePath $exeRoomService -ArgumentList "--start" # 
        Write-Host "TrueConf Room Service запущен" -ForegroundColor Green
    }
    catch {
        Write-Host "TrueConf Room Service не смог запуститься" -ForegroundColor red
    }
    [Environment]::NewLine
}

function StartRoomSimple{
    $exeRoom = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
    try {
        Start-Process -FilePath $exeRoom -ArgumentList "--monitor 2 --wsport 8765 --pin '123'" # --start
        Write-Host "TrueConf Room запущен" -ForegroundColor Green
    }
    catch {
        Write-Host "TrueConf Room не смог запуститься" -ForegroundColor red
    }
    [Environment]::NewLine
}

function StartRoomCountMonitor {
    
    #$MonitorFile = "C:\AudioCodes\TrueConf\MonitorsCount.txt"
    $MonitorsCountOld = -1

    do {
        <#
        #$MonitorsCountNew = [Environment]::GetEnvironmentVariable('CountMonitors', 'Machine')
        #$MonitorsCountNew = [int16]$MonitorsCountNew

        #$gcm = GetCountMonitor1 #test
        #$MonitorsCountNew = $gcm[0]

        #$MonitorFile = "D:\WorkPC\1\txt.txt"
        #$txt = 
        #Get-Content -Path $MonitorFile | % {$MonitorsCountNew = $_}
        #$json = Get-Content -Path $MonitorFile -Raw -ErrorAction Stop -ErrorVariable ErrGetJson | ConvertFrom-Json
        #$MonitorsCountNew = [int16]$txt
        #>

        $MonitorsCountNew = (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.status -eq "OK")}).count
        #$MonitorsCountNew

        #Вариант 1
        #Если за 15 прошедших секунд число мониторов изменилось
        if ($MonitorsCountNew -ne $MonitorsCountOld){
            [Environment]::NewLine
            "Monitors count changed = $MonitorsCountNew"

            try {
                Get-Process $processNameRoom -ErrorAction Stop
        
                try {
                    Stop-Process -Name $processNameRoom -Force -ErrorAction Stop -ErrorVariable ErrStopRoom
                    #Start-Process -FilePath $exeRoom -ArgumentList "--quit"
                    Write-Host "$processNameRoom закрыт" -ForegroundColor Green
                    Start-Sleep -Seconds 15
                }
                catch {
                    Write-Host $ErrStopRoom -ForegroundColor Red
                    Write-Host "$processNameRoom НЕ был закрыт" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Нет ранее запущенного процесса $processNameRoom" -ForegroundColor Green
            }
            
        
            try {
                Get-Process $processNameRoom -ErrorAction Stop        
                Write-Host "Запущен процесс $processNameRoom. Открыть новый процесс невозможно" -ForegroundColor Red
            }
            catch {
                if ($MonitorsCountNew -eq 1){
                    #если остался 1 экранчик ВКС, запускаем Рум свёрнутым
                    $Arg = "--min"
                }
                if ($MonitorsCountNew -eq 2){
                    #Если включился проектор, запускаем Рум на втором экране
                    $Arg = "--monitor 2"
                }
                if ($MonitorsCountNew -eq 3){
                    #Если есть и проектор и ТВ
                    $Arg = "--monitor 2"
                }
                #Открыть Рум с аргументом
                try {
                    Start-Process -FilePath $exeRoom -ArgumentList "$Arg --wsport 8765 --pin 123" -ErrorAction Stop -ErrorVariable $ErrStartRoom -verbose
                    Write-Host "Приложение Room запустилось с аргументом $Arg" -ForegroundColor Red
                    Start-Sleep -Seconds 10
                }
                catch {
                    $ErrStartRoom
                    Write-Host "Приложение Room не смогло запуститься" -ForegroundColor Red
                }
            }

            <#
            try {
                #Закрыть приложение РУма
                Stop-Process -Name $processNameRoom -ErrorAction Stop -ErrorVariable ErrStopRoom -Verbose
                #Start-Process -FilePath $exeRoom -ArgumentList "--quit"
                Start-Sleep -Seconds 5
                
                #$MonitorsCountNew -lt $MonitorsCountOld
                if ($MonitorsCountNew -eq 1){
                    #если остался 1 экранчик ВКС, запускаем Рум свёрнутым
                    $Arg = "--min"
                }
                if ($MonitorsCountNew -eq 2){
                    #Если включился проектор, запускаем Рум на втором экране
                    $Arg = "--monitor 2"
                }
                if ($MonitorsCountNew -eq 3){
                    #Если есть и проектор и ТВ
                    $Arg = "--monitor 2"
                }
                #Открыть Рум с аргументом
                try {
                    Start-Process -FilePath $exeRoom -ArgumentList "$Arg --wsport 8765 --pin 123" -ErrorAction Stop -ErrorVariable $ErrStartRoom -verbose
                    Write-Host "Приложение Room запустилось с аргументом $Arg" -ForegroundColor Red
                    Start-Sleep -Seconds 10
                }
                catch {
                    $ErrStartRoom
                    Write-Host "Приложение Room не смогло запуститься" -ForegroundColor Red
                }                
            }
            catch {
                $ErrStopRoom
                Write-Host "Приложение Room не смогло закрыться" -ForegroundColor Red
            }#>

            #Перезапускаем хром
            StopStartChromeF11try
        }

        $MonitorsCountOld = $MonitorsCountNew
        Start-Sleep -Seconds 15

    } while (
        $true
    )
}
#StartRoom

function StartRoomPsSession {
    $exeRoom = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
    $username = 'TrueConf'
    $password = 'TeleTK2#'

    #Вариант1
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword         

    # create an admin user powershell session
    #$s = New-PSSession -Credential $credential 
    New-PSSession -Credential $credential | Enter-PSSession
    Start-Process -FilePath $exeRoom -ArgumentList "--monitor 2 --wsport 8765 --pin 123"
}

function StartRoomCoordinates {
    #https://docs.trueconf.com/videosdk/introduction/commandline
    #Add-Type -AssemblyName System.Windows.Forms
    #[System.Windows.Forms.Screen]::AllScreens

    <#
    BitsPerPixel : 32
    Bounds       : {X=0,Y=0,Width=1280,Height=800}
    DeviceName   : \\.\DISPLAY1
    Primary      : True
    WorkingArea  : {X=0,Y=0,Width=1280,Height=800}

    BitsPerPixel : 32
    Bounds       : {X=1920,Y=0,Width=1920,Height=1080}
    DeviceName   : \\.\DISPLAY2
    Primary      : False
    WorkingArea  : {X=1920,Y=0,Width=1920,Height=1080}
    #>

    $exeRoom = "C:\Program Files\TrueConf\Room\TrueConfRoom.exe"
    try {
        Start-Process -FilePath $exeRoom -ArgumentList "--position 1920,0,1920,1080 --wsport 8765 --pin '123'" # --start
        Write-Host "TrueConf Room запущен" -ForegroundColor Green
    }
    catch {
        Write-Host "TrueConf Room не смог запуститься" -ForegroundColor red
    }
    [Environment]::NewLine

    
}



#Какие функции по итогу запускаем
if ($username -eq "admin"){
    
    TimeSync

}
if ($username -eq "trueconf"){
    #$env:USERNAME

    #EditRoomServiceJson
    #StartRoomService
    #Start-Sleep -Seconds 5

    #StartRoomSimple
     StartRoomCountMonitor

    #Start-Sleep -Seconds 40
    #StartChrome
    #StartChromeF11

    #Start-Sleep -Seconds 15
    #PressF11vbs
}
if ($username -eq "trueconf1"){
    #Start-Sleep -Seconds 30
    #ClickLeftMouseToBatDesktopScript
}
if ($username -eq "trueconf2"){
    #StartRoomSimple

    #Start-Sleep -Seconds 40
    #StartChrome
}
if ($username -eq "test"){

    #StartRoomPsSession

} else {

    #StopStartChromeF11try
    #StartRoomCountMonitor

}
pause