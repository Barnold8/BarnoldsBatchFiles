@echo off
setlocal enabledelayedexpansion


@REM start sysdm.cpl
@REM setx sets environment variable 
@REM setx TEST 12

cls

set /p minGW=" Do you have minGW installed? Y/N (NOTE: it is needed for compiling code) "

if %minGW% == N goto MINGW 
if %minGW% == n goto MINGW 

echo "Grabbing SDL2 from the internet!"

goto SDL2_INSTALL

:MINGW
    set per=mod
    set per=!per:mod=%%!
    set downloadLink="https://downloads.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-win32/seh/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z?ts=gAAAAABijRezKL48CgiTkLOY-vCFQxM7TExCTHlh6ir7VNVCE8_kl6kXlw-_HSF71kVgRK4n4PksPKfumweJU6FDmAcV66bSqg%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fmingw-w64%2Ffiles%2FToolchains%2520targetting%2520Win64%2FPersonal%2520Builds%2Fmingw-builds%2F8.1.0%2Fthreads-win32%2Fseh%2Fx86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z%2Fdownload"

    bitsadmin /Reset
    bitsadmin /create "MinGw_Install_Process"
    ::bitsadmin /SETPROXYSETTINGS "MinGw_Install_Process" NO_PROXY

    bitsadmin /transfer MinGw_Install_Process /download /DYNAMIC /priority high %downloadLink% "%CD%\MingGW_Setup.exe"

    bitsadmin /resume MinGw_Install_Process
    bitsadmin /complete MinGw_Install_Process

    cls

    echo Please run the setup tool, or cancel it, to continue. 

    start MingGW_Setup.exe

    cls




:SDL2_INSTALL

    set per=mod
    set per=!per:mod=%%!
    set downloadLink="https://www.libsdl.org/release/SDL2-devel-2.0.22-mingw.tar.gz"

    bitsadmin /Reset
    bitsadmin /create "SDL2_Install_Process"
    ::bitsadmin /SETPROXYSETTINGS "SDL2_Install_Process" NO_PROXY

    bitsadmin /transfer SDL2_Install_Process /download /DYNAMIC /priority high %downloadLink% "%CD%\SDL2-devel-2.0.22-mingw.tar.gz"

    bitsadmin /resume SDL2_Install_Process
    bitsadmin /complete SDL2_Install_Process

    cls

    
:ExtractFiles 

    tar -xf SDL2-devel-2.0.22-mingw.tar.gz
    del SDL2-devel-2.0.22-mingw.tar.gz
    
:Code_FLDR_Setup:

    set /p dir=" Please enter the exact directory you want the SDL library to reside in "

    if %dir% == . goto Leave_as_is


:Move_Process

    xcopy "SDL2-2.0.22/x86_64-w64-mingw32" %dir%


:Leave_as_is
    
    set /p Code_dir=" Please enter the exact directory you want your code project. Or alternatively you can type . to abort thus far "
    mkdir %Code_dir%
    if %Code_dir% == . exit

    echo "To allow this process to write, please write D when you see '(F = file, D = directory)' "

    xcopy "%dir%/bin" "%Code_dir%/SDL"
    

:write_code
    
    move "%Code_dir%/SDL/SDL2.dll" %Code_dir%
    
    echo #include ^<stdio.h^> >> main.cpp
    echo #include ^<SDL2/SDL.h^> >> main.cpp

    echo int main^(int argc, char* argv^[^]^)^{  >> main.cpp
    echo ^/* Initializes the timer, audio, video, joystick,  >> main.cpp
    echo haptic, gamecontroller and events subsystems *^/ >> main.cpp
    echo if ^(SDL_Init^(SDL_INIT_EVERYTHING^) ^!= 0^)^{   >> main.cpp
    echo     printf^("Error initializing SDL: ^%s\n", SDL_GetError^(^)^);    >> main.cpp
    echo     return 0;^} >> main.cpp
    echo printf^("SDL successfully initialized!\n"^); >> main.cpp
    echo SDL_Quit^(^);    >> main.cpp
    echo return 0;  >> main.cpp
    echo }   >> main.cpp
    move main.cpp %Code_dir%
