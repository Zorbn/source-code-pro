@echo off
setlocal

set FAMILY=SourceCodePro
set ROMAN_WEIGHTS=Black Bold ExtraLight Light Medium Regular Semibold
set ITALIC_WEIGHTS=BlackIt BoldIt ExtraLightIt LightIt MediumIt It SemiboldIt

:: find makeotf
for /f %%a in ('where makeotf') do set MAKEOTF_PATH=%%a
if "%MAKEOTF_PATH%" == "" goto error_makeotf_not_found

call :GetDirectoryName PYTHON_PATH "%MAKEOTF_PATH%"

set HINTING_PATH=%~dp0\Hinter\in
set TARGET_PATH=%~dp0\target\
set TARGET_OTF_PATH=%TARGET_PATH%OTF\
set TARGET_TTF_PATH=%TARGET_PATH%TTF\

if exist "%TARGET_PATH%" rmdir /s /q "%TARGET_PATH%"
mkdir "%TARGET_OTF_PATH%"
mkdir "%TARGET_TTF_PATH%"

set x=%ROMAN_WEIGHTS%
:loop_roman
for /f "tokens=1*" %%a in ("%x%") do (
    call :build_font Roman %%a
    set x=%%b
)
if defined x goto :loop_roman

set x=%ITALIC_WEIGHTS%
:loop_italic
for /f "tokens=1*" %%a in ("%x%") do (
    call :build_font Italic %%a
    set x=%%b
)
if defined x goto :loop_italic

endlocal
goto :eof

:: Build Font
:: %1 - Roman/Italic
:: %2 - Weight
:build_font
call cd "%~dp0\%1\Instances\%2"
call makeotf -f "%~dp0\%1\Instances\%2\font.ufo" -r -gs -omitMacNames -o "%TARGET_OTF_PATH%\%FAMILY%-%2.otf"
call otf2ttf -o "%FAMILY%-%2.ttf" "%TARGET_OTF_PATH%\%FAMILY%-%2.otf"
call ttfcomponentizer "%FAMILY%-%2.ttf"
call move "%FAMILY%-%2.ttf" "%HINTING_PATH%"
call cd "%~dp0\Hinter"
call python hint.py %TARGET_TTF_PATH%
call del "%HINTING_PATH%\%FAMILY%-%2.ttf"
goto :eof

:error_makeotf_not_found
echo makeotf command not found. Install Adobe Font Development Kit for OpenType (http://www.adobe.com/devnet/opentype/afdko.html).
endlocal
exit /b 1

::
:: Get directory name from full path name.
:: Usage:
::   GetDirectoryName VARIABLE VALUE
::
:GetDirectoryName
call set %~1=%~dp2
goto :eof
