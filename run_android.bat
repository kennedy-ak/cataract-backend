@echo off
setlocal enabledelayedexpansion

REM Project root: %~dp0
pushd %~dp0

REM Resolve Flutter CLI path
set "FLUTTER=C:\Users\User2\develop\flutter\bin\flutter.bat"
where flutter >nul 2>nul
if %errorlevel%==0 set "FLUTTER=flutter"

REM Resolve ADB path
set "ADB=C:\Users\User2\AppData\Local\Android\sdk\platform-tools\adb.exe"
if exist "%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe" set "ADB=%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe"

echo.
echo Using Flutter: %FLUTTER%
echo Using ADB    : %ADB%
echo.

REM Start emulator (no-op if already running)
echo Launching Android emulator: Medium_Phone_API_36.1
%FLUTTER% emulators --launch Medium_Phone_API_36.1 1>nul 2>nul

REM Wait for device to be online
echo Waiting for emulator device...
"%ADB%" wait-for-device

REM Wait for boot complete
:wait_boot
for /f "usebackq delims=" %%G in (`"%ADB%" shell getprop sys.boot_completed 2^>nul`) do set BOOTED=%%G
if not "!BOOTED!"=="1" (
  echo Emulator booting... (sys.boot_completed=!BOOTED!)
  timeout /t 3 >nul
  goto wait_boot
)

REM Unlock screen
"%ADB%" shell input keyevent 82 >nul 2>nul

REM Fetch dependencies
echo Running: flutter pub get
%FLUTTER% pub get
if errorlevel 1 (
  echo flutter pub get failed. Exiting.
  exit /b 1
)

REM Build & run on the emulator
echo Running: flutter run -d emulator-5554
echo Hot reload: press r    Hot restart: R    Quit: q
%FLUTTER% run -d emulator-5554

popd
endlocal