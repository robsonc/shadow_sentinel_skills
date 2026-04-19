@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{{RUNNER_PATH}}"
set EXITCODE=%ERRORLEVEL%
endlocal & exit /b %EXITCODE%
