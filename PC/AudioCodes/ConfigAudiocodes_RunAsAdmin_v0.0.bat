@echo off
chcp 65001 >nul

rem PSx64
powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -NoLogo -File "%~dp0ConfigAudiocodes_v0.0.ps1"

rem PSx32
rem C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -NoLogo -File "%~dp0ConfigAudiocodes_Part1_v0.0.ps1"