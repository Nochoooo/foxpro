@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0snapshot_control.ps1"
if errorlevel 1 (
  echo.
  echo SNAPSHOT FAILED.
  pause
  exit /b 1
)
pause
exit /b 0
