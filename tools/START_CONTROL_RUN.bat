@echo off
setlocal
set "CONTROL=C:\FOXPRO_CONTROL"
set "ADMIN=%CONTROL%\ADMINSTR"

if not exist "%ADMIN%" (
  echo ERROR: control environment is not prepared.
  echo Run tools\setup_control.bat first.
  pause
  exit /b 1
)

cd /d "%ADMIN%"
set "PATH=C:\PDO;%PATH%"

echo ================================================================
echo FOXPRO CONTROL RUN
echo ================================================================
echo Working directory: %CD%
echo Runtime directory : C:\PDO
echo.
echo Network MUST remain disconnected.
echo Do NOT run C:\PDO\N_NSI.bat
echo.

if exist "%CD%\administ.exe" (
  start "FOXPRO CONTROL" /D "%CD%" "%CD%\administ.exe"
  exit /b 0
)
if exist "%CD%\ADMINSTR.EXE" (
  start "FOXPRO CONTROL" /D "%CD%" "%CD%\ADMINSTR.EXE"
  exit /b 0
)

echo ERROR: no administrator EXE found in %ADMIN%.
pause
exit /b 1
