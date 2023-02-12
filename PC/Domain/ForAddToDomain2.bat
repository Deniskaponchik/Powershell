@echo off
chcp 65001 >nul

powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -NoLogo -File "%~dp0ForAddToDomain2.ps1"