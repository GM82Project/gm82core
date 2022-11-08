#include "gm82core.h"
#define window_handle(X) (HWND)(int)X

static PROCESS_INFORMATION pi;
static WINDOWPLACEMENT placement;

wstr make_wstr(const char* input) {
    int len = MultiByteToWideChar(CP_UTF8, 0, input, -1, NULL, 0);
    wstr output = malloc(len*2);
    MultiByteToWideChar(CP_UTF8, 0, input, -1, output, len);
    return output;
}

GMREAL __gm82core_getmaximized(double gm_hwnd) {
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(window_handle(gm_hwnd),&placement);
    return (double)(placement.showCmd==3);
}
GMREAL __gm82core_getminimized(double gm_hwnd) {
    HWND outer_hwnd=GetWindow(window_handle(gm_hwnd),GW_OWNER);
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(outer_hwnd,&placement);
    return (double)(placement.showCmd==2);
}
GMREAL __gm82core_setmaximized(double gm_hwnd) {
    ShowWindow(window_handle(gm_hwnd),3);
    return 0;
}
GMREAL __gm82core_setminimized(double gm_hwnd) {
    HWND outer_hwnd=GetWindow(window_handle(gm_hwnd),GW_OWNER);
    ShowWindow(outer_hwnd,2);
    return 0;
}
GMREAL __gm82core_set_foreground(double gm_hwnd) {
    SetForegroundWindow(window_handle(gm_hwnd));
    return 0;
}

GMREAL __gm82core_winver() {
    if (IsWindows8OrGreater()) return 8;
    if (IsWindows7OrGreater()) return 7;
    if (IsWindowsVistaOrGreater()) return 6;
    if (IsWindowsXPOrGreater()) return 5;
    return 4;
}
GMREAL __gm82core_addfonttemp(const char* fname) {
	wstr wname=make_wstr(fname);
	double out = (double)AddFontResourceW(wname);
	free(wname);
    return out;
}
GMREAL __gm82core_remfonttemp(const char* fname) {
	wstr wname=make_wstr(fname);
	double out = (double)RemoveFontResourceW(wname);
	free(wname);
    return out;
}
GMREAL __gm82core_execute_program_silent(const char* command) {
    STARTUPINFOW si = { sizeof(si) };
    
    wstr wcommand=make_wstr(command);
    
    int proc=CreateProcessW(0, wcommand, NULL, NULL, TRUE, 0x08000000, NULL, NULL, &si, &pi);
    
    free(wcommand);
    
    return (double)!!proc;
}
GMREAL __gm82core_execute_program_silent_exitcode() {
    DWORD ret;

    GetExitCodeProcess(pi.hProcess,&ret);    
    
    if (ret==259) return -4;
    
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    
    return (double)ret;        
}

GMREAL get_capslock() {
    return (double)(GetKeyState(VK_CAPITAL) & 1);
}
GMREAL get_scrolllock() {
    return (double)(GetKeyState(VK_SCROLL) & 1);
}
GMREAL get_ram_usage() {
    DWORD dwProcessId;
    HANDLE Process;
    PROCESS_MEMORY_COUNTERS pmc;
    
    dwProcessId = GetCurrentProcessId();
    Process = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,FALSE,dwProcessId);
    GetProcessMemoryInfo(Process,&pmc,sizeof(pmc));
    CloseHandle(Process);
    
    return pmc.WorkingSetSize;
}
GMREAL set_working_directory(const char* dir) {
	wstr wdir=make_wstr(dir);
    SetCurrentDirectoryW(wdir);
	free(wdir);
    return 0;
}
GMREAL set_dll_loaddir(const char* name) {
    wstr wname=make_wstr(name);
    SetDllDirectoryW(wname); 
    free(wname);
    return 0;    
}
GMREAL io_get_language() {
    return (double)GetUserDefaultUILanguage();
}
GMREAL get_window_col() {
    if (__gm82core_winver()==5) {
        //windows xp: reading theme information was over 100 lines long and too complicated so i just return luna blue
        return 0xe55500;
    }
    HKEY key;
    HRESULT res = RegOpenKeyExA(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\DWM", 0, KEY_READ, &key);
    if (res == 0) {
        int col;
        int size=4;
        res = RegQueryValueExA(key, "ColorPrevalence", NULL, NULL, (LPBYTE)&col, &size);
        if (res==0) {
            //if color prevalence is turned off, window titles are just colored white
            if (col==0) return 0xffffff;
        }        
        res = RegQueryValueExA(key, "ColorizationColor", NULL, NULL, (LPBYTE)&col, &size);
        RegCloseKey(key);
        if (res == 0) {
            return ((col & 0xff0000) >> 16) | (col & 0xff00) | ((col & 0xff) << 16);
        }
    }
    return -1;
}
GMREAL get_foreground_window() {
    return (double)(int)GetForegroundWindow();
}
GMREAL sleep_ext(double ms) {
    SleepEx((DWORD)ms,TRUE);
    return 0;
}

GMREAL __registry_read_dword(const char* dir, const char* keyname) {
    HKEY key;
	wstr wdir=make_wstr(dir);
    HRESULT res = RegOpenKeyExW(HKEY_CURRENT_USER, wdir, 0, KEY_READ, &key);
	free(wdir);
    if (res == 0) {
        int buffer;
        int size = 4;
		wstr wkeyname=make_wstr(keyname);
        res = RegQueryValueExW(key, wkeyname, NULL, NULL, (LPBYTE)&buffer, &size);
		free(wkeyname);
        RegCloseKey(key);
        if (res == 0) {
            return buffer;
        } else { return -4; }
    } else { return -4; }
}
GMREAL __registry_write_dword(const char* dir, const char* keyname, double dword) {
    HKEY key;
	wstr wdir=make_wstr(dir);
    HRESULT res = RegOpenKeyExW(HKEY_CURRENT_USER, wdir, 0, KEY_READ, &key);
	free(wdir);
    if (res == 0) {
        int buffer=(int)dword;
		wstr wkeyname=make_wstr(keyname);
        res = RegSetValueExW(key, wkeyname, 0, REG_DWORD, (LPBYTE)&buffer, 4);
		free(wkeyname);
        RegCloseKey(key);
        if (res == 0) {
            return buffer;
        } else { return res; }
    } else { return res; }
}