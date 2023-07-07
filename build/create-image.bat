@echo off

set PATH=bin\cygwin;%PATH%
bash ./create-image.sh %1 %2 %3 %4 %5 %6 %7 %8 %9

echo.
pause
