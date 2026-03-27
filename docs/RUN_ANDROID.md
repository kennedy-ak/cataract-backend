# Android emulator → app on screen (copy/paste commands)

Entry point: [lib.main()](lib/main.dart:12) • Android launcher: [android.app.MainActivity](android/app/src/main/kotlin/com/example/cataract_detection/MainActivity.kt:1)

PowerShell (recommended)
1) Launch emulator
& "C:\Users\User2\develop\flutter\bin\flutter.bat" emulators --launch Medium_Phone_API_36.1

2) Wait for device online
& "$Env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" wait-for-device

3) Wait for full boot
do { Start-Sleep -Seconds 2; $b = (& "$Env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" shell getprop sys.boot_completed 2>$null).Trim(); Write-Host "sys.boot_completed=$b" } until ($b -eq '1')

4) Unlock screen
& "$Env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" shell input keyevent 82

5) Fetch dependencies
& "C:\Users\User2\develop\flutter\bin\flutter.bat" pub get

6) Run the app on the emulator
& "C:\Users\User2\develop\flutter\bin\flutter.bat" run -d emulator-5554

Tips: Hot reload r • Hot restart R • Quit q

If the app didn’t open automatically after build
& "$Env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" shell am start -n com.example.cataract_detection/.MainActivity

Optional: run backend API locally (for training data collection)
python -m venv .venv
.\.venv\Scripts\activate
pip install -r backend/requirements.txt
python backend/app.py  # Starts [backend.app.app.run()](backend/app.py:212) at http://localhost:8080

Note: You can instead run the one-shot script [run_android.ps1](run_android.ps1) via:
PowerShell -ExecutionPolicy Bypass -File .\run_android.ps1