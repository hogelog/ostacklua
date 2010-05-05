@echo off
cd "D:\moge\lang\lua\mylua\src"
@setlocal
@set DIR=%CD%
cd ..
call "C:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
@echo on
call etc\luavs.bat
@echo off
cd %DIR%
@echo on
pause
