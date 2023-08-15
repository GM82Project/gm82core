del build\release\gm82core.dll

cmake -B build -A Win32 -DINSTALL_GEX=ON && cmake --build build --config Release

pause
