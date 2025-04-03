#!/bin/sh

i686-w64-mingw32-cmake -B build -DINSTALL_GEX=ON -G"Ninja Multi-Config" && cmake --build build --config Release
