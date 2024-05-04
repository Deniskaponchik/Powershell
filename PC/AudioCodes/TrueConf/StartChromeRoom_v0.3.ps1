# Version:      0.3
# STATUS:       НЕ Протестировано
# Цель:         Запуск различных программ для работы Рума. Стремление к незакрыванию процессов при включении проектора
# реализация:   Скрипт запускается в Планировщике задач.
# проблемы:     
# Планы:        Получить обратную связь от инженеров
# Last Update:  Рум не закрывается при включении проектора
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
$exePS = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"

#$pname = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)
$processNameRoom = [System.IO.Path]::GetFileNameWithoutExtension($exeRoom)
$processNamePS = [System.IO.Path]::GetFileNameWithoutExtension($exePS)



### ОБЩИЕ ФУНКЦИИ ###
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
#MoveWindow $processNamePS 1

function Set-TopMost($handle) {
    $FnDef = '
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(int hWnd, int hAfter, int x, int y, int cx, int cy, uint Flags);
    ';
    $user32 = Add-Type -MemberDefinition $FnDef -Name 'User32' -Namespace 'Win32' -PassThru
    $user32::SetWindowPos($handle, -1, 0,0,0,0, 3)
}
### ОБЩИЕ ФУНКЦИИ ###




### C ЗАВЕРШЕНИЕМ ПРОЦЕССОВ ХРОМА И РУМА ###
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

function StopStartRoom{
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
}

function StartRoomCountMonitor {
    
    #развернуть PS на весь экран
    MoveWindow $processNamePS 1

    $MonitorsCountOld = -1

    do {
        $MonitorsCountNew = (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.status -eq "OK")}).count
        #$MonitorsCountNew

        #Вариант 1
        #Если за 15 прошедших секунд число мониторов изменилось
        if ($MonitorsCountNew -ne $MonitorsCountOld){
            [Environment]::NewLine
            "Monitors count changed = $MonitorsCountNew"

            #Завершаем рум и открываем в зависимости от экрана
            StopStartRoom

            #Перезапускаем хром
            StopStartChromeF11try
        }

        $MonitorsCountOld = $MonitorsCountNew
        Start-Sleep -Seconds 15

    } while (
        $true
    )
}
### C ЗАВЕРШЕНИЕМ ПРОЦЕССОВ ХРОМА И РУМА ###




### Что-то при каких-то условиях завершается, что-то нет ###
function MiddleChromeRoom {
    #ЦИКЛ
    
    #развернуть PS на весь экран
    MoveWindow $processNamePS 1
    #Start-Sleep -Seconds 1
    #MoveWindow $processNamePS 1

    $MonitorsCountOld = -1

    do {
        $MonitorsCountNew = (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.status -eq "OK")}).count
        #$MonitorsCountNew

        #Если за прошедшие n секунд число мониторов изменилось
        if ($MonitorsCountNew -ne $MonitorsCountOld){
            [Environment]::NewLine
            "Monitors count changed = $MonitorsCountNew"

            #После смены кол-ва мониторов винда сама начинает перемещать окна. 
            #Необходимо дождаться, когда она закончит этот процесс
            Start-Sleep -Seconds 10

            if ($MonitorsCountNew -gt $MonitorsCountOld){
                #Если экранов стало больше. Только в этом случае нужно что-то менять и распределять по дисплеям

                #Меню управления хрома перенесётся на какое-то время на экран проектора - пусть там и будет, 
                #чтобы пользователи не пытались что-то нажать, пока будет перезапускаться Room

                #Завершаем Рум и открываем ВСЕГДА на 2 экране
                MiddleRoom
                #Если функция MiddleRoom не будет работать корректно
                #StopStartRoom

                #Перезапускаем хром на экранчике ВКС
                StopStartChromeF11try
            }
        }

        $MonitorsCountOld = $MonitorsCountNew
        Start-Sleep -Seconds 15

    } while (
        $true
    )
}

function MiddleRoom {
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
        #Открыть Рум с аргументом
        try {
            Start-Process -FilePath $exeRoom -ArgumentList "--monitor 2 --wsport 8765 --pin 123" -ErrorAction Stop -ErrorVariable $ErrStartRoom -verbose
            Write-Host "Приложение Room запустилось с аргументом --monitor 2" -ForegroundColor Red
            Start-Sleep -Seconds 10
        }
        catch {
            $ErrStartRoom
            Write-Host "Приложение Room не смогло запуститься" -ForegroundColor Red
        }
    }
}
### Что-то при каких-то условиях завершается, что-то нет ###





### БЕЗ ЗАВЕРШЕНИЯ ПРОЦЕССОВ ХРОМА И РУМА. НЕ РАБОТАЕТ ###
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


function StartChromeCountMonitors{
    #$p = (Get-Process $processNameChrome -ErrorAction SilentlyContinue) | ? { $_.MainWindowHandle -ne 0 }
    #if ($p -ne $null) {   
    #Write-Host "Process '$processNameChrome' not found, starting: $exeChrome"}

    #$exeChrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    #$exeChrome = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    #$processNameChrome = [System.IO.Path]::GetFileNameWithoutExtension($exeChrome)

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

    MoveWindow $processNameChrome 1
    Start-Sleep -Seconds 1
    MoveWindow $processNameChrome 1
    #Write-Host "$processNameChrome перемещён на 1 дисплей" -ForegroundColor Green

    #
    $p.MainWindowHandle
    Set-TopMost $p.MainWindowHandle
    #

    <#Если хром НЕ пересекается нигде на экранах с румом, то, наверное, нет необходимости в F11
    #inner vbs f11 input
    #https://stackoverflow.com/questions/66529507/powershell-send-f5-key-to-edge
    $wshell = New-Object -ComObject wscript.shell
    Start-Sleep -Seconds 10                  ### increase time for slow connection
    $wshell.AppActivate($ChromeProcess.Id)
    $wshell.SendKeys('{f11}')
    Write-Host "F11 прожато" -ForegroundColor Green
    Start-Sleep -Seconds 2
    #>
    
    [Environment]::NewLine
}

function ChromeCountMonitors{

    #$MonitorsCountNew спускается с выполняющей функции

    try {
        Get-Process $processNameChrome -ErrorAction Stop

        #Если процесс уже был запущен, перемещаем окно
        try {
            if ($MonitorsCountNew -eq 1){
                #если остался 1 экранчик ВКС
                
                #Предалагю ничего не делать - винда сама переместит на экран вкс
                
                <#Закрыть chrome открыть на 1 экране
                try {
                    Stop-Process -Name $processNameRoom -Force -ErrorAction Stop -ErrorVariable ErrStopRoom
                    #Start-Process -FilePath $exeRoom -ArgumentList "--quit"
                    Write-Host "$processNameRoom закрыт" -ForegroundColor Green
                    Start-Sleep -Seconds 15

                    StartRoomCountMonitors   # s на конце
                }
                catch {
                    Write-Host $ErrStopRoom -ForegroundColor Red
                    Write-Host "$processNameRoom НЕ был закрыт" -ForegroundColor Red
                }#>
            }
            if ($MonitorsCountNew -eq 2){
                #Если включился проектор, перемещаем хром на первый экранчик ВКС
                MoveWindow $processNameChrome 1
                Start-Sleep -Seconds 1
                MoveWindow $processNameChrome 1
                
                Write-Host "Процесс $processNameChrome перемещён на дисплей 1" -ForegroundColor Green
            }
            if ($MonitorsCountNew -eq 3){
                #Если есть и проектор и ТВ. 
                MoveWindow $processNameChrome 1
                Start-Sleep -Seconds 1
                MoveWindow $processNameChrome 1

                Write-Host "Процесс $processNameChrome перемещён на дисплей 1" -ForegroundColor Green
            }
            Start-Sleep -Seconds 15
        }
        catch {
            Write-Host "Процесс $processNameChrome НЕ был перемещён на дисплей 1" -ForegroundColor Red
        }

    }
    catch {
        #Если ранее запущенного процесса не было
        Write-Host "Нет ранее запущенного процесса $processNameChrome" -ForegroundColor Yellow

        StartChromeCountMonitors
    }
}



function StartRoomCountMonitors{

    #$MonitorsCountNew спускается с выполняющей функции

    if ($MonitorsCountNew-eq 1){
        #ВКС запустилось без проектора
        #$Arg = "--min"
        #
        $Arg = "--monitor 2"
    }
    if ($MonitorsCountNew -eq 2){
        #ВКС запустилось с включенным проектором
        $Arg = "--monitor 2"
    }
    if ($MonitorsCountNew -eq 3){
        #Если есть и проектор и ТВ
        $Arg = "--monitor 2"
    }
    #Открыть Рум с аргументом
    try {
        #Start-Process -FilePath $exeRoom -ArgumentList "$Arg --wsport 8765 --pin 123" -ErrorAction Stop -ErrorVariable $ErrStartRoom -verbose
        #Write-Host "Приложение Room запустилось с аргументом $Arg" -ForegroundColor Green
        Start-Process -FilePath $exeRoom -ArgumentList "--wsport 8765 --pin 123" -ErrorAction Stop -ErrorVariable $ErrStartRoom -verbose
        Write-Host "Приложение Room запустилось без мониторного аргумента" -ForegroundColor Green
        Start-Sleep -Seconds 15
    }
    catch {
        $ErrStartRoom
        Write-Host "Приложение Room не смогло запуститься с аргументом $Arg" -ForegroundColor Red
    }
}

function RoomCountMonitors{

    #$MonitorsCountNew спускается с выполняющей функции

    try {
        Get-Process $processNameRoom -ErrorAction Stop

        #Если процесс уже был запущен, перемещаем окно
        #RoomMoveWindow $MonitorsCountNew
        try {
            if ($MonitorsCountNew -eq 1){
                #если остался 1 экранчик ВКС
                #Предлагаю ничего не делать.

                <#Закрыть рум и открыть свёрнутым
                try {
                    Stop-Process -Name $processNameRoom -Force -ErrorAction Stop -ErrorVariable ErrStopRoom
                    #Start-Process -FilePath $exeRoom -ArgumentList "--quit"
                    Write-Host "$processNameRoom закрыт" -ForegroundColor Green
                    Start-Sleep -Seconds 15

                    StartRoomCountMonitors   # s на конце
                }
                catch {
                    Write-Host $ErrStopRoom -ForegroundColor Red
                    Write-Host "$processNameRoom НЕ был закрыт" -ForegroundColor Red
                }
                #>
            }
            if ($MonitorsCountNew -eq 2){
                #Если включился проектор, пытаемся переместить Рум на него
                #НЕ РАБОТАЕТ. Если Рум первоначально запускался с отключенным проектором не важно с каким аргументом, то он всё равно пытается переместиться на 1 экран
                MoveWindow $processNameRoom 2
                Write-Host "Процесс $processNameRoom перемещён на дисплей 2" -ForegroundColor Green
            }
            if ($MonitorsCountNew -eq 3){
                #Если есть и проектор и ТВ. Тут зависит от обстоятельств, кому что потребуется. Предсказать невозможно
                MoveWindow $processNameRoom 2
                Write-Host "Процесс $processNameRoom перемещён на дисплей 2" -ForegroundColor Green
            }
            Start-Sleep -Seconds 15
        }
        catch {
            Write-Host "Процесс $processNameRoom НЕ был перемещён на дисплей $MonitorsCountNew" -ForegroundColor Red
        }

    }
    catch {
        #Если ранее запущенного процесса не было
        Write-Host "Нет ранее запущенного процесса $processNameRoom" -ForegroundColor Yellow

        StartRoomCountMonitors
        #НЕ РАБОТАЕТ. Если рум запускать без аргументов с подключенным проектором, то после мувинга на 2 дисплей он сам возвращается на первый экран
        MoveWindow $processNameRoom 2
    }
}

function ChromeRoomCountMonitors {
    
    #развернуть PS на весь экран
    MoveWindow $processNamePS 1
    #Start-Sleep -Seconds 1
    #MoveWindow $processNamePS 1

    $MonitorsCountOld = -1

    do {
        $MonitorsCountNew = (Get-PnpDevice | Where-Object {($_.class -eq "Monitor") -and ($_.status -eq "OK")}).count
        #$MonitorsCountNew

        #Если за прошедшие n секунд число мониторов изменилось
        if ($MonitorsCountNew -ne $MonitorsCountOld){
            [Environment]::NewLine
            "Monitors count changed = $MonitorsCountNew"

            #После смены кол-ва мониторов винда сама начинает перемещать окна. 
            #Необходимо дождаться, когда она закончит этот процесс
            Start-Sleep -Seconds 10

            if ($MonitorsCountNew -gt $MonitorsCountOld){
                #Если экранов стало больше. Только в этом случае нужно что-то менять и распределять по дисплеям

                #Или запускаем Хром или пытаемся его перенести на 1 дисплей
                #Start-Job -ScriptBlock{}
                ChromeCountMonitors

                #
                RoomCountMonitors  
            }                     

        }

        $MonitorsCountOld = $MonitorsCountNew
        Start-Sleep -Seconds 15

    } while (
        $true
    )
}
### БЕЗ ЗАВЕРШЕНИЯ ПРОЦЕССОВ ХРОМА И РУМА. НЕ РАБОТАЕТ ###




### Какие функции по итогу запускаем ###
if ($username -eq "admin"){
 
}
if ($username -eq "trueconf"){

    #StartRoomCountMonitor      #C завершением процессов хрома и рума
     MiddleChromeRoom           #Всё перезапускаем только при увеличении кол-ва внешних дисплеев
    #ChromeRoomCountMonitors    #без завершения процессов хрома и рума

}
if ($username -eq "test"){

} else {

}
pause