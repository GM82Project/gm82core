call "%VS120COMNTOOLS%vsvars32.bat"

cl gm82core.c /O2 /GS- /nologo /link /nologo /dll /out:gm82core.dll

pause