call "%VS120COMNTOOLS%vsvars32.bat"

cl gm82core.c /O1 /MD /GS- /nologo /link /nologo /dll /out:gm82core.dll

pause