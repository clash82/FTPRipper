@echo off
del "release\*.dcu"
del "release\*.log"
del "release\*.exe"
"dcc32.exe" "ftp_rip.dpr"
"release\ftp_rip.exe"