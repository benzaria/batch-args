@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

call :_parse_ %*

:main
:: start of main code


rem access the variables in main code
:: echo user: !user!
:: echo password: !password!
:: echo action: !action!
:: echo default: !_args_!

:: end of main code
:_end_
endlocal
goto :eof


:: Arguments Parser v1.0.0 by benzaria
:_parse_  args => _args_
    set "args=%*" && set "_args_="
    if not defined args call :--help & exit /b 1
    for %%i in (!args!) do (
        set "arg=%%i"
        call :!arg! 2>nul || (
            rem if u want match the order of arguments, add the line that have `rem add:`,
            rem remove `set /a n -=1` and switch !n! with !m!, in the folowing lines:
            rem add: if not !m! equ !n! set /a m += 1
            if !n! equ 0 (
                :: set unused arguments to default variable: _args_
                set "_args_=!_args_!!arg! "
            ) else (
                :: set the next argument to the variable name
                call set "next=%%next[!n!]%%"
                echo !next!=!arg!
                set "!next!=!arg!"
                set /a n -= 1 & rem remove this line if u want to use the `rem add:` lines
            )
            rem add: if !m! equ !n! set /a n = 0 & set /a m = 0
            :: run a label function after the varialbles are set
            if defined run if !n! equ 0 call :!run! & set "run="
        )
    )
    :: default value are the arguments that have no flag before them, and never used
    echo default: !_args_!
    if !n! neq 0 echo Unexpected argument: !arg! ... & exit /b 1
    exit /b 0

:: Arguments definition
    :-bp
    :--best-practice
        set /a n = 2
        :: default n = 0, set it to how many arguments after to be taken as values for the variables
        set "next[2]=variable-1"
        set "next[1]=variable-2"
        :: the next arguments will be placed in the variables name, 
        :: make sure to make the order of the indexs in reverse, to get the right order
        :: e.g. -bp value-1 value-2 => next[2]=variable-1=value-1, next[1]=variable-2=value-2
        :: if u want match the order of arguments, checkout the argument handler for the option.
        set "run=_label_" || rem call :_label_
        :: call a label function now or wait for the defined varialbles to be set with the 'run' flag
        set "best-practice=true"
        :: optional, set the flag as part of the arguments to call some function later
        exit /b 0
        :: exit the function with success code 0 to continue, else the handler will do some errors

:: Exapmles
    :-u
    :--user
        set /a n = 1
        set "next[1]=user"
        exit /b 0
        
    :-p
    :--password
        set /a n = 1
        set "next[1]=password"
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

:: functions
:_label_
    echo best-practice: !best-practice!
    exit /b 0

:_save-pass_
    echo password: !password! is saved
    exit /b 0

:_do-action_
    echo action, permission, force: !action!, !permission!, !force!
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