call "%VS120COMNTOOLS%vsvars32.bat"

cl gm82core.c /O2 /GS- /nologo /link /nologo /dll /out:gm82core.dll
del gm82core.obj
del gm82core.exp
del gm82core.lib

if exist gm82core.dll build_gex.py gm82core.ged

pause