@echo off
echo Building Flutter App for Windows Release...
flutter build windows --release

echo.
echo Compiling XDoc Installer...
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\xdoc_installer.iss"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    "C:\Program Files\Inno Setup 6\ISCC.exe" "installer\xdoc_installer.iss"
) else (
    echo Inno Setup not found. Please install Inno Setup or compile manually.
    echo Download from: https://jrsoftware.org/isinfo.php
    pause
    exit /b 1
)

echo.
echo Installer created successfully!
echo Location: installer\XDoc_Setup.exe
pause
