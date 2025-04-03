#pragma once

#define _USE_MATH_DEFINES
#define VC_EXTRALEAN
#define WIN32_LEAN_AND_MEAN

#include <stdio.h>
#include <windows.h>
#include <versionhelpers.h>
#include <math.h>
#include <psapi.h>
#include <wingdi.h>
#include <commctrl.h>
#include <stdint.h>
#include <stdlib.h>

#define GMREAL __declspec(dllexport) double __cdecl
#define GMSTR __declspec(dllexport) char* __cdecl

typedef wchar_t* wstr;
typedef unsigned long long int uint64;

//force msbuild to not mangle the "secret" windows api function definition
extern VOID WINAPI RtlGetNtVersionNumbers(LPDWORD pMajor, LPDWORD pMinor, LPDWORD pBuild);
