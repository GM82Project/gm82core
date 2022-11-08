#ifndef gm82core
#define gm82core

#define GMREAL __declspec(dllexport) double __cdecl
#define GMSTR __declspec(dllexport) char* __cdecl
#define _USE_MATH_DEFINES
#include <windows.h>
#include <versionhelpers.h>
#include <math.h>
#include <psapi.h>
#include <wingdi.h>
#include <commctrl.h>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "Psapi.lib")
#pragma comment(lib, "GDI32.lib")
#pragma comment(lib, "comctl32.lib")

#define wstr wchar_t*

#endif