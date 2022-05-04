#define GMREAL __declspec(dllexport) double __cdecl
#define GMSTR __declspec(dllexport) char* __cdecl
#define _USE_MATH_DEFINES
#include <windows.h>
#include <versionhelpers.h>
#include <math.h>
#include <psapi.h>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "Psapi.lib")
