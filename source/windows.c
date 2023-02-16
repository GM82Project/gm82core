#include "gm82core.h"

static int has_started=0;
static HWND window_handle;
static HWND outer_handle;

static PROCESS_INFORMATION pi;
static int process_running=0;
static WINDOWPLACEMENT placement;
static double windows_version;

//custom window procedure to ignore menu keys
LRESULT CALLBACK RenexWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam, UINT_PTR uIdSubclass, DWORD_PTR dwRefData) {
    switch(uMsg) {
        case WM_SYSCOMMAND:
            //ignore f10 as menu
            if (wParam==SC_KEYMENU) {
                return 0;
            }
        break;
        case WM_SYSKEYDOWN:
            //ignore alt key as menu
            DefSubclassProc(hWnd, WM_KEYDOWN, wParam, lParam);
            return 0; 
        case WM_SYSKEYUP:
            //ignore alt key as menu
            DefSubclassProc(hWnd, WM_KEYUP, wParam, lParam);
            return 0;
    }

    return DefSubclassProc(hWnd, uMsg, wParam, lParam);
}

void prepare_window(double gm_hwnd) {
    //get window handle of inner & outer windows
    //(outer window is needed for minimize)
    window_handle=(HWND)(int)gm_hwnd;
    outer_handle=GetWindow(window_handle,GW_OWNER);
    //patch game window procedure to ignore alt and f10 as a menu key
    SetWindowSubclass(window_handle, &RenexWndProc, 1, 0);
}

wstr make_wstr(const char* input) {
    int len = MultiByteToWideChar(CP_UTF8, 0, input, -1, NULL, 0);
    wstr output = (wstr)malloc(len*2);
    MultiByteToWideChar(CP_UTF8, 0, input, -1, output, len);
    return output;
}

GMREAL __gm82core_winver() {
    //THANKS VIRI
    int major;
    int minor;
    int build;
    
    RtlGetNtVersionNumbers(&major,&minor,&build);
    
    if (major==6) {
        if (minor==3) return 8.1;
        if (minor==2) return 8;
        if (minor==1) return 7;
        if (minor==0) return 6;
    }
    return (double)major;
}

GMREAL __gm82core_checkstart(double gm_hwnd) {
    if (has_started) return 0;
    has_started=1;
    prepare_window(gm_hwnd);
    windows_version=__gm82core_winver();
    return 1;
}

GMREAL __gm82core_getmaximized(double gm_hwnd) {
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(window_handle,&placement);
    return (double)(placement.showCmd==3);
}

GMREAL __gm82core_getminimized(double gm_hwnd) {
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(outer_handle,&placement);
    return (double)(placement.showCmd==2);
}

GMREAL __gm82core_setmaximized(double gm_hwnd) {
    ShowWindow(window_handle,3);
    return 0;
}

GMREAL __gm82core_setminimized(double gm_hwnd) {
    ShowWindow(outer_handle,2);
    return 0;
}

GMREAL __gm82core_set_foreground(double gm_hwnd) {
    SetForegroundWindow(window_handle);
    return 0;
}

GMREAL get_foreground_window() {
    return (double)(GetForegroundWindow()==window_handle);
}

GMREAL get_windows_version() {
    return windows_version;
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
    if (process_running) return 75;
    
    STARTUPINFOW si = { sizeof(si) };
    
    wstr wcommand=make_wstr(command);
    
    int proc=CreateProcessW(0, wcommand, NULL, NULL, TRUE, 0x08000000, NULL, NULL, &si, &pi);
    
    free(wcommand);
    
    process_running=1;
    
    return (double)!!proc;
}

GMREAL __gm82core_execute_program_silent_exitcode() {
    if (!process_running) return 75;
    DWORD ret;

    GetExitCodeProcess(pi.hProcess,&ret);    
    
    if (ret==259) return 259;
    
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    
    process_running=0;
    
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
    HRESULT res = RegOpenKeyExW(HKEY_CURRENT_USER, wdir, 0, KEY_WRITE, &key);
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