@echo off
set "LOCALAPPDATA=%~dp0localappdata"
call "%~dp0node_modules\.bin\gm-cli.cmd" %*
