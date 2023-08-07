@echo off
setlocal enabledelayedexpansion

rem Save current path
set currentPath=%~dp0
rem Save current drive letter
set currentDriver=%~d0
rem Change directory to the batch file's location
%currentDriver%
cd "%currentPath%"

echo currentPath=%currentPath%

rem *****************************************************************************************************
rem * Tested with mysql5.7.21: https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-winx64.zip
rem * 1. Initialize the database from the current directory
rem * 2. Set the default password to root123
rem *****************************************************************************************************

rem Specify the base installation path for MySQL
set mysql_basedir=%currentPath%
rem Set the default password to root123
set mysql_default_pwd=root123
set mysql_default_port=3306
set mysql_service_name=mysql

rem *****************************************************************************************************
rem * Remove trailing slashes from the parameter mysql_basedir begin
rem *****************************************************************************************************
set /a n = 0
set str=%mysql_basedir%
:next_str_cal
if not "x%str%"=="x" (
    set /a n=n+1
    set curChar=%str:~0,1%
    set "str=%str:~1%"
    goto next_str_cal
)

set newstr=%mysql_basedir%
echo newstr=%newstr%
set new_basedir=
set /a i = 0
if not "x%curChar%"=="x\" (
    set new_basedir=%mysql_basedir%
)
if "x%curChar%"=="x\" (
    :next_str_cat
    if not "x%newstr%"=="x" (
        set /a i=i+1
        set cur_Char=%newstr:~0,1%
        set "newstr=%newstr:~1%"
        if %i% LSS %n% (
            set new_basedir=%new_basedir%%cur_Char%
        )
        goto next_str_cat
    )
)
set mysql_basedir=%new_basedir%
echo mysql_basedir=%mysql_basedir%
rem *****************************************************************************************************
rem * Remove trailing slashes from the parameter mysql_basedir end
rem *****************************************************************************************************

rem Specify the bin directory for MySQL
set mysql_bin=%mysql_basedir%\bin
rem Specify the directory to store data (must be a non-existent empty directory)
set mysql_data=%mysql_basedir%\data
rem Specify the auto-generated MySQL configuration files
set mysql_ini_file=%currentPath%my.ini
set mysql_cnf_file=%mysql_basedir%\my.cnf
set mysql_install_bat=%currentPath%\install_service.bat
set mysql_uninstall_bat=%currentPath%\uninstall_service.bat
set mysql_start_bat=%currentPath%\start_service.bat
set mysql_stop_bat=%currentPath%\stop_service.bat
set mysql_reset_root_password_bat=%currentPath%\reset_root_password.bat

rem ** Modify parameters as needed **
set mysql_data=%currentPath%data

if not exist "%mysql_bin%\mysqld.exe" (
    echo Please confirm the mysql_basedir parameter, %mysql_bin%\mysqld.exe was not found
    goto success_exit
)

if not exist "%mysql_bin%\mysql.exe" (
    echo Please confirm the mysql_basedir parameter, %mysql_bin%\mysql.exe was not found
    goto success_exit
)

rem Display the current MySQL version
"%mysql_bin%\mysql.exe" --version
set mysql_ver=5.7.21
cd %mysql_bin%
for /f "tokens=3,4*" %%i in ('mysql.exe --version ^| findstr /i "Ver "') do (
    set mysql_ver=%%i
    echo %%i
)
cd %mysql_basedir%
echo mysql_ver=%mysql_ver%

if exist "%mysql_data%" (
    echo Please confirm the mysql_data parameter=%mysql_data%, it must be a non-existent empty directory, detected directory already exists!
    goto success_set
)

rem --initialize-insecure initializes root without a password
rem --initialize generates a root password that is unclear
echo "%mysql_bin%\mysqld.exe" --initialize-insecure --user=mysql --basedir="%mysql_basedir%" --datadir="%mysql_data%"
"%mysql_bin%\mysqld.exe" --initialize-insecure --user=mysql --basedir="%mysql_basedir%" --datadir="%mysql_data%"
if %errorlevel% neq 0 (
    echo Error initializing data directory "%mysql_data%"!
    goto success_exit
)

rem SET PASSWORD FOR 'some_user'@'some_host' = PASSWORD('password');
rem SET PASSWORD FOR 'root'@'%' = PASSWORD('root123');
rem Use --skip-grant-tables on startup to bypass password validation (allows data operations, but can't reset password)
rem Reset password using: mysqladmin -u root -h 127.0.0.1 -P 3306 password "root123"
echo "%mysql_bin%\mysqld.exe" --defaults-file="%mysql_ini_file%" --console


:success_set

rem ***************************************************************************
rem Process ini path parameter ini_mysql_basedir
set replaceValue=
set curChar=
set newStrValue=%mysql_basedir%
:next_mysql_basedir
if not "%newStrValue%"=="" (
    set curChar=%newStrValue:~0,1%
    if "%curChar%"=="\" (
        set replaceValue=%replaceValue%\\
    )
    if not "%curChar%"=="\" (
        set replaceValue=%replaceValue%%curChar%
    )
    set newStrValue=%newStrValue:~1%
    goto next_mysql_basedir
)
if "%curChar%"=="\" (
    set curChar=\\
)
if not "%curChar%"=="\" (
    set replaceValue=%replaceValue%%curChar%
)
set ini_mysql_basedir=%replaceValue%
echo ini_mysql_basedir=%replaceValue%

rem ***************************************************************************
rem Process ini path parameter ini_mysql_data
set replaceValue=
set curChar=
set newStrValue=%mysql_data%
:next_mysql_data
if not "%newStrValue%"=="" (
    set curChar=%newStrValue:~0,1%
    if "%curChar%"=="\" (
        set replaceValue=%replaceValue%\\
    )
    if not "%curChar%"=="\" (
        set replaceValue=%replaceValue%%curChar%
    )
    set newStrValue=%newStrValue:~1%
    goto next_mysql_data
)
if "%curChar%"=="\" (
    set curChar=\\
)
if not "%curChar%"=="\" (
    set replaceValue=%replaceValue%%curChar%
)
set ini_mysql_data=%replaceValue%
echo ini_mysql_data=%replaceValue%

rem Generate my.cnf configuration file
echo [client] > "%mysql_cnf_file%"
echo port=%mysql_default_port% >> "%mysql_cnf_file%"
echo character-sets-dir=%ini_mysql_basedir%\\share\\charsets >> "%mysql_cnf_file%"
echo default-character-set=utf8mb4 >> "%mysql_cnf_file%"

rem Generate my.ini configuration file
echo [client] > "%mysql_ini_file%"
echo default-character-set=utf8mb4 >> "%mysql_ini_file%"
echo port=%mysql_default_port% >> "%mysql_ini_file%"
echo [mysqld] >> "%mysql_ini_file%"
echo # set basedir to your installation path >> "%mysql_ini_file%"
echo basedir=%ini_mysql_basedir% >> "%mysql_ini_file%"
echo # set datadir to the location of your data directory >> "%mysql_ini_file%"
echo datadir=%ini_mysql_data% >> "%mysql_ini_file%"
echo character-set-server=utf8mb4 >> "%mysql_ini_file%"
echo port=%mysql_default_port% >> "%mysql_ini_file%"
if "%mysql_ver:~0,1%" == "8" (
    echo # mysql8 >> "%mysql_ini_file%"
    echo default_authentication_plugin=mysql_native_password >> "%mysql_ini_file%"
)

rem Generate batch script to install Windows service (install_service.bat)
echo "%mysql_bin%\mysqld.exe" --install %mysql_service_name% --defaults-file="%mysql_ini_file%" > "%mysql_install_bat%"

rem Generate batch script to uninstall service
echo net stop %mysql_service_name% > "%mysql_uninstall_bat%"
echo "%mysql_bin%\mysqld.exe" --remove %mysql_service_name% >> "%mysql_uninstall_bat%"

rem Generate batch script to start service
echo net start %mysql_service_name% > "%mysql_start_bat%"

rem Generate batch script to stop service
echo net stop %mysql_service_name% > "%mysql_stop_bat%"

rem Generate batch script to reset root password
echo "%mysql_bin%\mysqladmin.exe" -u root -h 127.0.0.1 -P %mysql_default_port% password "%mysql_default_pwd%" > "%mysql_reset_root_password_bat%"

rem Generate batch script to create get5 database (get5.bat)
set mysql_create_get5_bat=%currentPath%\get5.bat
echo @echo off > "%mysql_create_get5_bat%"
echo "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port% -e "CREATE DATABASE IF NOT EXISTS get5;" >> "%mysql_create_get5_bat%"
echo "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port% -e "CREATE USER 'get5'@'localhost' IDENTIFIED BY 'admin123';" >> "%mysql_create_get5_bat%"
echo "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port% -e "GRANT ALL PRIVILEGES ON get5.* TO 'get5'@'localhost';" >> "%mysql_create_get5_bat%"
echo exit >> "%mysql_create_get5_bat%"

echo To start from command line: "%mysql_bin%\mysqld.exe" --defaults-file="%mysql_ini_file%" --console
echo To change root password: "%mysql_bin%\mysqladmin.exe" -u root -h 127.0.0.1 -P %mysql_default_port% password "%mysql_default_pwd%"
echo To connect from command line: "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port%
echo To install service: install_service.bat
echo To uninstall service: uninstall_service.bat
echo To start service: start_service.bat
echo To stop service: stop_service.bat
echo To reset root password: reset_root_password.bat

call "%mysql_install_bat%"
call "%mysql_start_bat%"
call "%mysql_reset_root_password_bat%"

ping 127.0.0.1 -n 3 > nul

:success_exit

@echo off
if "%mysql_ver:~0,1%" == "8" (
    echo use mysql;alter user 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '%mysql_default_pwd%'; | "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port%

)

echo show variables like "%char%"; | "%mysql_bin%\mysql.exe" -uroot -p%mysql_default_pwd% -h 127.0.0.1 -P %mysql_default_port%
