#define GMREAL __declspec(dllexport) double __cdecl
#include <windows.h>

#pragma comment(lib, "user32.lib")

GMREAL set_dll_loaddir(const char* name) {
    int len = MultiByteToWideChar(CP_UTF8, 0, name, -1, NULL, 0);
    wchar_t *wname = malloc(len*2);
    MultiByteToWideChar(CP_UTF8, 0, name, -1, wname, len);
    SetDllDirectoryW(wname); 
    free(wname);
    return 0;    
}

GMREAL get_foreground_window() {
	return (double)(int)GetForegroundWindow();
}

GMREAL window_minimize(const char* winname) {
	ShowWindow(FindWindowA(NULL, winname), 6);
	return 0;
}