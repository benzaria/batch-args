@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul


call :_parse_ %*

:: access the variables here
:: echo user: !user!
:: echo password: !password!
:: echo action: !action!

:_end_
endlocal
goto :eof

:_label_
    echo best-practice: !best-practice!
    exit /b 0

:_help_
    echo Usage: %~n0 [Options]
    echo.
    echo Options:
    echo   -u, --user ^<user^>          Set the user name
    echo   -p, --password ^<password^>  Set the password
    echo   -a, --action ^<action^> ...  Set the action
    echo   -v, --version              Show the version
    echo   -h, --help                 Show this help message
    exit /b 0

:: Arguments Parser v1.0.0 by benzaria
:_parse_  args => _args_
    set "args=%*" && set "_args_="
    if not defined args call :--help & exit /b 1
    for %%i in (!args!) do (
        set "arg=%%i"
        call :!arg! 2>nul || (
            if !n! equ 0 (
                set "_args_=!_args_!!arg! "
            ) else (
                call set "next=%%next[!n!]%%"
                echo !next!=!arg!
                set "!next!=!arg!"
                set /a n -= 1
            )
            if defined run if !n! equ 0 call :!run! & set "run="
        )
    )
    :: default value are the arguments that have no flag before them
    echo default: !_args_!
    if !n! neq 0 echo Unexpected argument: !arg! ... & exit /b 1
    exit /b 0

:: Arguments definition
    :-bp
    :--best-practice
        set /a n = 2
        :: default n = 0, set it to for many arguments to be taken as values for the variables
        set "next[2]=variable-1"
        set "next[1]=variable-2"
        :: the next argument will be placed in the variable name, 
        :: make sure to make the order of the index in reverse.
        :: e.g. -bd value-1 value-2 => next[2]=variable-1=value-1, next[1]=variable-2=value-2
        set "run=_label_" || rem call :_label_
        :: call a label function now or wait for the varialble to be set
        set "best-practice=true"
        :: optional, set the flag as part of the arguments to call some function later
        exit /b 0

:: Exapmles
    :-u
    :--user
        set /a n = 1
        set "next[1]=user"
        exit /b 0
        
    :-p
    :--password
        set /a n = 2
        set "next[2]=password"
        set "run=_save-pass_"
        exit /b 0
        
    :-a
    :--action
        :: reverse order !
        set /a n = 3
        set "next[3]=action"
        set "next[2]=permission"
        set "next[1]=force"
        set "run=_do-action_"
        exit /b 0
        
    :-v
    :--version
        echo 1.0.0
        echo Made by benzaria
        exit /b 0
        
    :-h
    :--help
        call :_help_
        exit /b 0