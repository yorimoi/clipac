@echo off

openfiles >nul
if errorlevel 1 (
  powershell start-process %~f0 -ArgumentList '/k ""cd /d %CD%""' -verb runas
  exit /b
)

REM init
title clipac
SET PS1=clipac
SET CONF=#^ 
SET GLOCONF=(config)#^ 
SET INTCONF=(config-if)#^ 
SET MODE=%CONF%
SET INTERFACE=
SET IPADDR=
SET NETMASK=
SET GATEWAY=
SET MARKER=                                                                ^^^^


:LOOP
setlocal enabledelayedexpansion
set command=nullptr
set /p command="%PS1%%MODE%"

if "%command%"=="nullptr" (
  goto :LOOP
)

if "%MODE%"=="%CONF%" (
  echo %command% | findstr /I "show" >nul
  if not errorlevel 1 (
    CALL :Show %command%
    goto :LOOP
  )

) else if "%MODE%"=="%GLOCONF%" (
  echo %command% | findstr /I "hostname" >nul
  if not errorlevel 1 (
    CALL :Hostname %command%
    goto :LOOP
  )

  echo %command% | findstr /I "int" >nul
  if not errorlevel 1 (
    CALL :Interface %command%
    goto :LOOP
  )

) else if "%MODE%"=="%INTCONF%" (
  echo %command% | findstr /I "ip" >nul
  if not errorlevel 1 (
    CALL :Ip %command%
    goto :LOOP
  )

)

echo %command% | findstr /I "exit conf end" >nul
if not errorlevel 1 (
  CALL :Mode %command%
  goto :LOOP
)

echo %command% | findstr /I "help" >nul
if not errorlevel 1 (
  CALL :Help
  goto :LOOP
)

echo %command% | findstr /I "quit" >nul
if not errorlevel 1 (
  title & exit /b
)


CALL :Error %command%
CALL :Usage

goto :LOOP


:Hostname
SET PS1=%2
exit /b


:Interface
if "%MODE%"=="%GLOCONF%" (
  netsh interface ip show interface | findstr /I "%2" >nul
  if not errorlevel 1 (
    SET INTERFACE=%2
    SET MODE=%INTCONF:)=^)%
    exit /b
  )
)
CALL :Error %*
exit /b


:Mode
echo %* | findstr /I "conf" >nul
if not errorlevel 1 (
  SET MODE=%GLOCONF:)=^)%
  exit /b
)
echo %* | findstr /I "exit" >nul
if not errorlevel 1 (
  if "%MODE%"=="%INTCONF%" (
    SET MODE=%GLOCONF:)=^)%
  ) else if "%MODE%"=="%GLOCONF%" (
    SET MODE=%CONF:)=^)%
  )
  exit /b
)
echo %* | findstr /I "end" >nul
if not errorlevel 1 (
  SET MODE=%CONF:)=^)%
  exit /b
)
CALL :Error %*
exit /b


:Show
echo %* | findstr /I "int" >nul
if not errorlevel 1 (
  netsh interface ip show interface
  exit /b
)
CALL :Error %*
exit /b


:Ip
echo %2 | findstr /I "add" >nul
if not errorlevel 1 (
  echo %3 | findstr /I "dhcp" >nul
  if not errorlevel 1 (
  netsh interface ip set address %INTERFACE% dhcp
  if not errorlevel 1 (
    echo success!
  )
  exit /b
  ) else (
  set IPADDR=%3
  set NETMASK=%4
  set GATEWAY=%5
  netsh interface ip set address %INTERFACE% static %3 %4 %5
  if not errorlevel 1 (
    echo success!
  )
  exit /b
  )
)
CALL :Error %*
exit /b


:STRLEN
set str=%*
:STRLOOP
if not "%str%"=="" (
  set str=%str:~1%
  set /a len=%len%+1
  goto :STRLOOP
)
exit /b


:Help
echo Usage:
echo     ToDo
echo     This is help.
exit /b


:Usage
echo Try ^`help^` for more information.
exit /b


:Error
set len=0
CALL :STRLEN %*
set argslen=%len%
if "%MODE%"=="%CONF%" (
  set len=2
) else if "%MODE%"=="%GLOCONF%" (
  set len=10
) else (
  set len=13
)
CALL :STRLEN %PS1%
CALL :STRLEN %command%
set /a len=%len%-%argslen%+2
set len=!MARKER:~-%len%!
echo %len%
rem echo %%^*:%*
rem echo argslen:%argslen%
rem echo len:%len%
echo Invalid input detected at '^^' marker.