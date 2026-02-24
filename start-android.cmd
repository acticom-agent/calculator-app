@echo off
REM Build and run Calculator on Android emulator

if not defined ANDROID_HOME set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
if not defined JAVA_HOME set JAVA_HOME=C:\Program Files\Java\jdk-17

set ADB=%ANDROID_HOME%\platform-tools\adb.exe
set EMULATOR=%ANDROID_HOME%\emulator\emulator.exe

for /f "tokens=*" %%a in ('"%EMULATOR%" -list-avds 2^>nul') do (
    set AVD=%%a
    goto :found
)
echo Error: No Android AVD found. Create one first.
exit /b 1

:found
echo === Starting Android Emulator (%AVD%) ===
start "" "%EMULATOR%" -avd %AVD% -no-audio

echo Waiting for emulator to boot...
"%ADB%" wait-for-device

:waitboot
for /f "tokens=*" %%b in ('"%ADB%" shell getprop sys.boot_completed 2^>nul') do set BOOT=%%b
if not "%BOOT%"=="1" (
    timeout /t 2 /nobreak >nul
    goto :waitboot
)
echo Emulator booted!

echo === Building Calculator Android ===
cd /d "%~dp0android"
call gradlew.bat installDebug

echo === Launching app ===
"%ADB%" shell am start -n com.example.calculator/.MainActivity
echo Calculator is running on Android!
pause
