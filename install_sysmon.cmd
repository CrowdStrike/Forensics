@echo off
REM	Install Sysmon
echo.
echo #######################################
echo Create Remote Directory for symson
echo #######################################
echo.
for /F %%i in (hosts.txt) do md \\%%i\c$\windows\sysmon

echo.
echo #######################################
echo Copy sysmon and config file
echo #######################################
echo.
for /F %%i in (hosts.txt) do xcopy /y tools\sysmon\* \\%%i\c$\windows\sysmon\

echo.
echo #######################################
echo Install sysmon
echo #######################################
echo.
for /F %%i in (hosts.txt) do tools\psexec\psexec64.exe -accepteula \\%%i c:\windows\sysmon\sysmon64.exe -i c:\windows\sysmon\config-client.xml