@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        title Running as admin!
    ) ELSE (
        title Not running as admin ^(May cause problems ^if you want to automate PATH^)
        )


echo Since this is a simple batch file. Error checking is quite difficult. 
echo If you have any errors be sure to close this down and launch the file again. 
echo It may also be a good idea to remove any files/directories in case for naming ambiguities.
pause
cls

set /p minGW_Install=" MinGW is needed for compiling C/C++ code, do you wish to install it? (its mandatory for SDL2 development) Y/N "

if %minGW_Install% == y goto MINGW 
if %minGW_Install% == Y goto MINGW 

echo "Grabbing SDL2 from the internet!"

goto SDL2_INSTALL

:MINGW
    set per=mod
    set per=!per:mod=%%!
    set downloadLink="https://downloads.sourceforge.net/project/mingw-w64/Toolchains%per%20targetting%per%20Win64/Personal%per%20Builds/mingw-builds/7.3.0/threads-win32/seh/x86_64-7.3.0-release-win32-seh-rt_v5-rev0.7z?ts=gAAAAABijTB5nhqE6lvsq3lsbwVsfC4kMI6_7l19IX0uiSOSOMZH7x0N9GkNUDYiyQVLt39OCmhLaOCwo9bJUKc3_k4kPpHwrQ%per%3D%per%3D&r=https%per%3A%per%2F%per%2Fsourceforge.net%per%2Fprojects%per%2Fmingw-w64%per%2Ffiles%per%2FToolchains%per%2520targetting%per%2520Win64%per%2FPersonal%per%2520Builds%per%2Fmingw-builds%per%2F7.3.0%per%2Fthreads-win32%per%2Fseh%per%2Fx86_64-7.3.0-release-win32-seh-rt_v5-rev0.7z%per%2Fdownload"

    bitsadmin /Reset
    bitsadmin /create "MinGwInstallProcess"

    ::bitsadmin /SETPROXYSETTINGS "MinGwInstallProcess" NO_PROXY
    cls
    net session >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        set /p adminPath=" You are running this as admin, this means that the download will go to system32. Please enter the path where you want minGW to go, else leave a dot to keep it in system32 (not recommended) "
        if adminPath == . bitsadmin /transfer MinGwInstallProcess /download /DYNAMIC /priority high %downloadLink% "%CD%\MingGW_Setup.7z"
        if adminPath == . goto MINGW2
        bitsadmin /transfer MinGwInstallProcess /download /DYNAMIC /priority high %downloadLink% "%USERPROFILE%\MingGW_Setup.7z" 
        
    ) ELSE (
        bitsadmin /transfer MinGwInstallProcess /download /DYNAMIC /priority high %downloadLink% "%CD%\MingGW_Setup.7z"
        )

:MINGW2

    bitsadmin /resume MinGwInstallProcess
    bitsadmin /complete MinGwInstallProcess
    mkdir %adminPath%
    move "%USERPROFILE%\MingGW_Setup.7z" "%adminPath%\MingGW_Setup.7z"
    start %adminPath%
    echo Please unzip the mingGW zip archive before continuing... ^(This is needed^)
    pause
    if adminPath == . setx /M path "%path%;%CD%\MINGW\mingw\mingw64"
    if adminPath == . gotO SDL2_INSTALL
    setx /M path "%path%;%adminPath%\mingw64\bin"

:SDL2_INSTALL

    set per=mod
    set per=!per:mod=%%!
    set downloadLink="https://www.libsdl.org/release/SDL2-devel-2.0.22-mingw.tar.gz"

    bitsadmin /Reset
    bitsadmin /create "SDL2InstallProcess"
    ::bitsadmin /SETPROXYSETTINGS "SDL2InstallProcess" NO_PROXY
    bitsadmin /transfer SDL2InstallProcess /download /DYNAMIC /priority high %downloadLink% "%USERPROFILE%\Downloads\SDL2-devel-2.0.22-mingw.tar.gz"
    bitsadmin /resume SDL2InstallProcess
    bitsadmin /complete SDL2InstallProcess
 
    cls

    
:ExtractFiles 


    net session >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
            echo tar -xf SDL2-devel-2.0.22-mingw.tar.gz >> tarEXT.bat
            echo del SDL2-devel-2.0.22-mingw.tar.gz >> tarEXT.bat
            echo del tarEXT.bat >> tarEXT.bat
            move tarEXT.bat "%USERPROFILE%\Downloads"
            echo run 'tarEXT.BAT' to extract the tar archive.
            cmd /c "start %USERPROFILE%\Downloads"
            
    ) ELSE (
        
        tar -xf SDL2-devel-2.0.22-mingw.tar.gz
        del SDL2-devel-2.0.22-mingw.tar.gz

    )

    

pause
cls
echo if you want to keep the entire SDL folder, please make a copy and place it somewhere else since this script will move the x86_64 bin to the code folder
pause
cls


mkdir "%USERPROFILE%\Downloads\SLD2_Code_Sample"
move  "%USERPROFILE%\Downloads\SDL2-2.0.22\x86_64-w64-mingw32" "%USERPROFILE%\Downloads\SLD2_Code_Sample"
xcopy "%USERPROFILE%\Downloads\SLD2_Code_Sample\x86_64-w64-mingw32\bin" "%USERPROFILE%\Downloads\SLD2_Code_Sample"
ren "%USERPROFILE%\Downloads\SLD2_Code_Sample\x86_64-w64-mingw32" SDL2

:write_code


    set per2=mod
    set per2=!per2:mod=!!

    
    echo #include ^<stdio.h^> >> main.cpp
    echo #include ^<SDL2/SDL.h^> >> main.cpp

    echo int main^(int argc, char* argv^[^]^)^{  >> main.cpp
    echo ^/* Initializes the timer, audio, video, joystick,  >> main.cpp
    echo haptic, gamecontroller and events subsystems *^/ >> main.cpp
    echo if ^(SDL_Init^(SDL_INIT_EVERYTHING^) ^^!= 0^)^{   >> main.cpp
    echo     printf^("Error initializing SDL: %per%s\n", SDL_GetError^(^)^);    >> main.cpp
    echo     return 0;^} >> main.cpp
    echo printf^("SDL successfully initialized!\n"^); >> main.cpp
    echo SDL_Quit^(^);    >> main.cpp
    echo return 0;  >> main.cpp
    echo }   >> main.cpp
    move main.cpp "%USERPROFILE%\Downloads\SLD2_Code_Sample"

    echo g++ main.cpp -ISDL2/include -LSDL2/lib -Wall -lmingw32 -lSDL2main -lSDL2 -o main >> compile.bat
    echo pause >> compile.bat

    move compile.bat "%USERPROFILE%\Downloads\SLD2_Code_Sample"

    

        
    echo #include ^<stdio.h^>          >> sampleGame.cpp
    echo #include ^<stdbool.h^>          >> sampleGame.cpp
    echo #include ^<SDL2/SDL.h^>          >> sampleGame.cpp
    echo #define WIDTH 640          >> sampleGame.cpp
    echo #define HEIGHT 480          >> sampleGame.cpp
    echo #define SIZE 200          >> sampleGame.cpp
    echo #define SPEED 600          >> sampleGame.cpp
    echo #define GRAVITY 60          >> sampleGame.cpp
    echo #define FPS 60          >> sampleGame.cpp
    echo #define JUMP -1200          >> sampleGame.cpp

    echo int main^(int argc, char* argv^[^]^)^{          >> sampleGame.cpp
    echo ^/* Initializes the timer, audio, video, joystick,          >> sampleGame.cpp
    echo haptic, gamecontroller and events subsystems *^/          >> sampleGame.cpp
    echo if ^(SDL_Init^(SDL_INIT_EVERYTHING^) ^^!= 0^)^{          >> sampleGame.cpp
    echo     printf^("Error initializing SDL: %per%s\n", SDL_GetError^(^)^);          >> sampleGame.cpp
    echo     return 0;^}          >> sampleGame.cpp
    echo  ^/* Create a window *^/          >> sampleGame.cpp
    echo SDL_Window* wind = SDL_CreateWindow^("Hello Platformer!",          >> sampleGame.cpp
    echo                                     SDL_WINDOWPOS_CENTERED,          >> sampleGame.cpp
    echo                                     SDL_WINDOWPOS_CENTERED,          >> sampleGame.cpp
    echo                                     WIDTH, HEIGHT, 0^);          >> sampleGame.cpp
    echo if ^(!wind^)          >> sampleGame.cpp
    echo ^{          >> sampleGame.cpp
    echo     printf^("Error creating window: %per%s\n", SDL_GetError^(^)^);          >> sampleGame.cpp
    echo     SDL_Quit^(^);          >> sampleGame.cpp          >> sampleGame.cpp
    echo     return 0;          >> sampleGame.cpp          >> sampleGame.cpp
    echo ^}          >> sampleGame.cpp          >> sampleGame.cpp
    echo ^/* Create a renderer *^/          >> sampleGame.cpp
    echo Uint32 render_flags = SDL_RENDERER_ACCELERATED ^| SDL_RENDERER_PRESENTVSYNC;          >> sampleGame.cpp
    echo SDL_Renderer* rend = SDL_CreateRenderer^(wind, -1, render_flags^);          >> sampleGame.cpp
    echo if ^(^^!rend^)^{          >> sampleGame.cpp
    echo    printf^("Error creating renderer: %per%s\n", SDL_GetError^(^)^);          >> sampleGame.cpp
    echo     SDL_DestroyWindow^(wind^);          >> sampleGame.cpp
    echo     SDL_Quit^(^);          >> sampleGame.cpp
    echo     return 0;^}          >> sampleGame.cpp
    echo /* Main loop */          >> sampleGame.cpp
    echo bool running = true, jump_pressed = false, can_jump = true,          >> sampleGame.cpp
    echo                 left_pressed = false, right_pressed = false;          >> sampleGame.cpp
    echo float x_pos = ^(WIDTH-SIZE^)/2, y_pos = ^(HEIGHT-SIZE^)/2, x_vel = 0, y_vel = 0;          >> sampleGame.cpp
    echo SDL_Rect rect = ^{^(int^) x_pos, ^(int^) y_pos, SIZE, SIZE^};          >> sampleGame.cpp
    echo SDL_Event event;          >> sampleGame.cpp
    echo while ^(running^)^{          >> sampleGame.cpp
    echo     /* Process events */          >> sampleGame.cpp
    echo     while ^(SDL_PollEvent^(^&event^)^)^{          >> sampleGame.cpp
    echo     switch ^(event.type^)^{          >> sampleGame.cpp
    echo         case SDL_QUIT:          >> sampleGame.cpp
    echo        running = false;          >> sampleGame.cpp
    echo        break;          >> sampleGame.cpp
    echo         case SDL_KEYDOWN:          >> sampleGame.cpp
    echo         switch ^(event.key.keysym.scancode^)^{          >> sampleGame.cpp
    echo             case SDL_SCANCODE_SPACE:          >> sampleGame.cpp
    echo             jump_pressed = true;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             case SDL_SCANCODE_A:          >> sampleGame.cpp
    echo             case SDL_SCANCODE_LEFT:          >> sampleGame.cpp
    echo             left_pressed = true;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             case SDL_SCANCODE_D:          >> sampleGame.cpp
    echo             case SDL_SCANCODE_RIGHT:          >> sampleGame.cpp
    echo             right_pressed = true;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             default:          >> sampleGame.cpp
    echo             break;^}          >> sampleGame.cpp
    echo         break;          >> sampleGame.cpp
    echo         case SDL_KEYUP:          >> sampleGame.cpp
    echo         switch (event.key.keysym.scancode^)^{          >> sampleGame.cpp
    echo             case SDL_SCANCODE_SPACE:          >> sampleGame.cpp
    echo             jump_pressed = false;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             case SDL_SCANCODE_A:          >> sampleGame.cpp
    echo             case SDL_SCANCODE_LEFT:          >> sampleGame.cpp
    echo             left_pressed = false;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             case SDL_SCANCODE_D:          >> sampleGame.cpp
    echo             case SDL_SCANCODE_RIGHT:          >> sampleGame.cpp
    echo             right_pressed = false;          >> sampleGame.cpp
    echo             break;          >> sampleGame.cpp
    echo             default:          >> sampleGame.cpp
    echo             break;^}          >> sampleGame.cpp
    echo         break;          >> sampleGame.cpp
    echo         default:          >> sampleGame.cpp
    echo         break;^}^}          >> sampleGame.cpp
    echo     /* Clear screen */          >> sampleGame.cpp
    echo     SDL_SetRenderDrawColor^(rend, 0, 0, 0, 255^);          >> sampleGame.cpp
    echo     SDL_RenderClear^(rend^);          >> sampleGame.cpp
    echo     /* Move the rectangle */          >> sampleGame.cpp
    echo     x_vel = ^(right_pressed - left_pressed^)*SPEED;          >> sampleGame.cpp
    echo     y_vel += GRAVITY;          >> sampleGame.cpp
    echo     if ^(jump_pressed ^&^& can_jump^)^{          >> sampleGame.cpp
    echo     can_jump = false;          >> sampleGame.cpp
    echo     y_vel = JUMP;^}          >> sampleGame.cpp
    echo     x_pos += x_vel / 60;          >> sampleGame.cpp
    echo     y_pos += y_vel / 60;          >> sampleGame.cpp
    echo     if ^(x_pos <= 0^)          >> sampleGame.cpp
    echo     x_pos = 0;          >> sampleGame.cpp
    echo     if ^(x_pos >= WIDTH - rect.w^)          >> sampleGame.cpp
    echo     x_pos = WIDTH - rect.w;          >> sampleGame.cpp
    echo     if ^(y_pos <= 0^)          >> sampleGame.cpp
    echo     y_pos = 0;          >> sampleGame.cpp
    echo     if ^(y_pos >= HEIGHT - rect.h^)^{          >> sampleGame.cpp
    echo     y_vel = 0;          >> sampleGame.cpp
    echo     y_pos = HEIGHT - rect.h;          >> sampleGame.cpp
    echo     if ^(!jump_pressed^)          >> sampleGame.cpp
    echo         can_jump = true;^}          >> sampleGame.cpp
    echo     rect.x = ^(int^) x_pos;          >> sampleGame.cpp
    echo     rect.y = ^(int^) y_pos;          >> sampleGame.cpp
    echo     /* Draw the rectangle */          >> sampleGame.cpp
    echo     SDL_SetRenderDrawColor^(rend, 255, 0, 0, 255^);          >> sampleGame.cpp
    echo     SDL_RenderFillRect^(rend, ^&rect^);          >> sampleGame.cpp
    echo     /* Draw to window and loop */          >> sampleGame.cpp
    echo     SDL_RenderPresent^(rend^);          >> sampleGame.cpp
    echo     SDL_Delay^(1000/FPS^);^}          >> sampleGame.cpp
    echo /* Release resources */          >> sampleGame.cpp
    echo SDL_DestroyRenderer^(rend^);          >> sampleGame.cpp
    echo SDL_DestroyWindow^(wind^);          >> sampleGame.cpp
    echo SDL_Quit^(^);          >> sampleGame.cpp
    echo return 0;^}          >> sampleGame.cpp

    move sampleGame.cpp "%USERPROFILE%\Downloads\SLD2_Code_Sample"

    echo g++ sampleGame.cpp -ISDL2/include -LSDL2/lib -Wall -lmingw32 -lSDL2main -lSDL2 -o main >> compileSampleGame.bat
    echo pause >> compileSampleGame.bat

    move compileSampleGame.bat "%USERPROFILE%\Downloads\SLD2_Code_Sample"

    pause