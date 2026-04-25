@echo off  

set "dir=C:\CrashDump"

if exist "%dir%" (

    rd /s /q "%dir%"

    echo delete all files 
) else (
    echo no %dir%
)


reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps" /f  
echo Dump Stop 
pause  
@echo on 