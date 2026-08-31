@echo off
setlocal
cd /d C:\FOXPRO_CONTROL\ADMINSTR
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
  start "FOXPRO CONTROL" "%CD%\administ.exe"
  exit /b 0
)
if exist "%CD%\ADMINSTR.EXE" (
  start "FOXPRO CONTROL" "%CD%\ADMINSTR.EXE"
  exit /b 0
)

echo ERROR: no administrator EXE found.
pause
exit /b 1
