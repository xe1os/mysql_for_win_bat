# Installation windows version mysql batch

The test passed under mysql5.7.21, mysql-5.7.23, mysql-8.0.12

Download link: https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.21-winx64.zip

Put setup.bat in the corresponding path, for example:

```
G:\GREENSOFT\MYSQL-5.7.21-WINX64
├──bin
├──docs
├──include
├──lib
├──share
├─setup.bat
└─clear.bat
```

run setup.bat

1. Initialize data
2. Generate my.ini, my.cnf
3. Start the service
4. Reset the root password to root123

## Notice

If you use **Download zip**, you need to convert the .bat to Windows (CR LF) style carriage return and line feed to execute correctly
