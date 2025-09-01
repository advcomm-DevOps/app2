@echo off
echo Building Flutter App for Windows Release...
call flutter build windows --release

echo.
echo Compiling XDoc Installer...
call "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" "installer\xdoc_installer.iss"

echo.
echo Installer created successfully!
echo Location: installer\XDoc_Setup.exe
pause
pause
