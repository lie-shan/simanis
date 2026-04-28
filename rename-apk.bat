@echo off
set VERSION=1.0.1

echo Renaming APK files for version %VERSION%...

cd build\app\outputs\flutter-apk

if exist app-arm64-v8a-release.apk (
    copy app-arm64-v8a-release.apk siakad-v%VERSION%-arm64-v8a.apk
    echo [OK] arm64-v8a
)

if exist app-armeabi-v7a-release.apk (
    copy app-armeabi-v7a-release.apk siakad-v%VERSION%-armeabi-v7a.apk
    echo [OK] armeabi-v7a
)

if exist app-x86_64-release.apk (
    copy app-x86_64-release.apk siakad-v%VERSION%-x86_64.apk
    echo [OK] x86_64
)

echo.
echo Done! Files renamed to:
dir siakad-*.apk /b
pause
