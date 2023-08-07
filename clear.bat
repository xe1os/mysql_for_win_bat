@echo off
setlocal enabledelayedexpansion

rem Save the current path
set currentPath=%~dp0
rem Save the current drive letter
set currentDriver=%~d0
rem Change to the directory of the batch file
%currentDriver%
cd "%currentPath%"

rem Specify the base installation path for MySQL
set mysql_basedir=%currentPath%
rem Specify the bin directory for MySQL
set mysql_bin=%mysql_basedir%\bin

if not exist "%mysql_bin%\mysqld.exe" (
    echo Please confirm the mysql_basedir parameter, mysqld.exe not found in %mysql_bin%
    goto success_exit
)

if not exist "%mysql_bin%\mysql.exe" (
    echo Please confirm the mysql_basedir parameter, mysql.exe not found in %mysql_bin%
    goto success_exit
)

rem Clear data
if exist "%currentPath%\uninstall_service.bat" (
    call "%currentPath%\uninstall_service.bat"
    del /q "%currentPath%\uninstall_service.bat"
)

if exist "%currentPath%\install_service.bat" (
    del /q "%currentPath%\install_service.bat"
)

if exist "%currentPath%\start_service.bat" (
    del /q "%currentPath%\start_service.bat"
)

if exist "%currentPath%\stop_service.bat" (
    del /q "%currentPath%\stop_service.bat"
)

if exist "%currentPath%\reset_root_password.bat" (
    del /q "%currentPath%\reset_root_password.bat"
)

if exist "%currentPath%\get5.bat" (
    del /q "%currentPath%\get5.bat"
)

if exist "%currentPath%\my.ini" (
    del /q "%currentPath%\my.ini"
)

if exist "%currentPath%\my.cnf" (
    del /q "%currentPath%\my.cnf"
)

if exist "%currentPath%data" (
    del /q /s "%currentPath%data"
    rd /q /s "%currentPath%data"
)

:success_exit

@echo off
