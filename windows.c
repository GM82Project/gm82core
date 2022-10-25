#include "gm82core.h"

static PROCESS_INFORMATION pi;

wstr make_wstr(const char* input) {
    int len = MultiByteToWideChar(CP_UTF8, 0, input, -1, NULL, 0);
    wstr output = malloc(len*2);
    MultiByteToWideChar(CP_UTF8, 0, input, -1, output, len);
    return output;
}

GMREAL __gm82core_winver() {
    if (IsWindows8OrGreater()) return 8;
    if (IsWindows7OrGreater()) return 7;
    if (IsWindowsVistaOrGreater()) return 6;
    if (IsWindowsXPOrGreater()) return 5;
    return 4;
}
GMREAL __gm82core_set_foreground(double handle) {
    return SetForegroundWindow((HWND)(int)handle);
}
GMREAL __gm82core_addfonttemp(const char* fname) {
    return (double)AddFontResource(fname);
}
GMREAL __gm82core_remfonttemp(const char* fname) {
    return (double)RemoveFontResource(fname);
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
    SetCurrentDirectory(dir);
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
GMREAL window_minimize(const char* winname) {
    ShowWindow(FindWindowA(NULL, winname), 6);
    return 0;
}
GMREAL sleep_ext(double ms) {
    SleepEx((DWORD)ms,TRUE);
    return 0;
}

GMREAL __registry_read_dword(char* dir, char* keyname) {
    HKEY key;
    HRESULT res = RegOpenKeyExA(HKEY_CURRENT_USER, dir, 0, KEY_READ, &key);
    if (res == 0) {
        int buffer;
        int size = 4;
        res = RegQueryValueExA(key, keyname, NULL, NULL, (LPBYTE)&buffer, &size);
        RegCloseKey(key);
        if (res == 0) {
            return buffer;
        } else { return -4; }
    } else { return -4; }
}
GMREAL __registry_write_dword(char* dir, char* keyname, double dword) {
    HKEY key;
    HRESULT res = RegOpenKeyExA(HKEY_CURRENT_USER, dir, 0, KEY_SET_VALUE, &key);
    if (res == 0) {
        int buffer=(int)dword;
        res = RegSetValueExA(key, keyname, 0, REG_DWORD, (LPBYTE)&buffer, 4);
        RegCloseKey(key);
        if (res == 0) {
            return buffer;
        } else { return res; }
    } else { return res; }
}