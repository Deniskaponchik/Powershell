@echo off
chcp 65001 >nul

powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -NoLogo -File "%~dp0ConfigZabbix_v0.0.ps1"