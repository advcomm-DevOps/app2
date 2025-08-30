@echo off
echo Building Flutter App for Windows Release...
call flutter build windows --release

echo.
echo Installing/Updating MSIX package...
call flutter pub get

echo.
echo Creating MSIX package...
call flutter pub run msix:create

echo.
echo MSIX package created successfully!
echo Location: build\windows\x64\runner\Release\xdoc.msix
pause
