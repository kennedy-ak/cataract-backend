Param([switch]$Clean)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

# Resolve Flutter CLI path
$flutter = "C:\Users\User2\develop\flutter\bin\flutter.bat"
if (Get-Command flutter -ErrorAction SilentlyContinue) { $flutter = "flutter" }

# Resolve ADB path
$adb = "$Env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { $adb = "adb" }

Write-Host "`nUsing Flutter: $flutter"
Write-Host "Using ADB    : $adb`n"

# 1) Launch emulator (no-op if already running)
Write-Host "Launching emulator Medium_Phone_API_36.1 ..."
& $flutter emulators --launch Medium_Phone_API_36.1 | Out-Null

# 2) Wait for device
Write-Host "Waiting for device to connect ..."
& $adb wait-for-device

# 3) Wait for full boot
Write-Host "Waiting for boot completion ..."
do {
  Start-Sleep -Seconds 2
  $boot = (& $adb shell getprop sys.boot_completed 2>$null).Trim()
  Write-Host "  sys.boot_completed = '$boot'"
} until ($boot -eq '1')

# 4) Unlock screen
Write-Host "Unlocking screen ..."
& $adb shell input keyevent 82 | Out-Null

# Optional clean
if ($Clean) {
  Write-Host "flutter clean ..."
  & $flutter clean
}

# 5) Dependencies
Write-Host "flutter pub get ..."
& $flutter pub get

# 6) Run the app on the emulator
Write-Host "`nLaunching app on emulator-5554 ..."
Write-Host "Hot reload: r  |  Hot restart: R  |  Quit: q`n"
& $flutter run -d emulator-5554

exit $LASTEXITCODE