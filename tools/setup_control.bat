@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0.."
set "BUNDLE_ROOT=%CD%"

echo ================================================================
echo FOXPRO CONTROL ENVIRONMENT SETUP
echo ================================================================
echo.
echo This script expects the GitHub repository itself to be this folder.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%BUNDLE_ROOT%\tools\setup_control.ps1"
if errorlevel 1 (
  echo.
  echo SETUP FAILED.
  pause
  exit /b 1
)

echo.
echo SETUP FINISHED.
echo.
echo Next action: run START_CONTROL_RUN.bat
pause
exit /b 0
