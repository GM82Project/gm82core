call "%VS120COMNTOOLS%vsvars32.bat"

cl gm82core.c hrt.c lovey01.c terrible_gm8_hacking.c /O2 /W2 /WX /GS- /nologo /link /nologo /dll /out:gm82core.dll

if not exist gm82core.dll pause && exit

del *.obj
del *.exp
del *.lib

cd helpdoc
if not exist gm82core.chm call rebuild_help.bat
cd ..

build_gex.py gm82core.ged

pause