SET MATLABROOT="C:\Program Files\MATLAB\R2019b"
PATH=%MATLABROOT%;%PATH%
set SCRIPT="%~dp0BuildPackages.m"
set SCRIPT=%SCRIPT:\=/%
echo %SCRIPT%
START matlab.exe -batch -sd "%~dp0"
PAUSE