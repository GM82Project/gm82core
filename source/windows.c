#include "gm82core.h"

static int has_started=0;
static HWND window_handle;
static HWND outer_handle;

static PROCESS_INFORMATION pi;
static int process_running=0;
static WINDOWPLACEMENT placement;
static double windows_version;

static char regsz[4096];
static char shortfn[MAX_PATH];

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

double __gm82core_winver() {
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

/*-*/


GMREAL __gm82core_getmaximized() {
    ///window_is_maximized()
    ///returns: whether the window is maximized.
    
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(window_handle,&placement);
    return (double)(placement.showCmd==3);
}

GMREAL __gm82core_getminimized() {
    ///window_is_minimized()
    ///returns: whether the window is minimized.
    
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(outer_handle,&placement);
    return (double)(placement.showCmd==2);
}

GMREAL __gm82core_setmaximized() {
    ///window_maximize()
    //Maximizes the window.
    
    ShowWindow(window_handle,3);
    return 0;
}

GMREAL __gm82core_setminimized() {
    ///window_minimize()
    //Minimizes the window.
    
    ShowWindow(outer_handle,2);
    return 0;
}

GMREAL window_restore() {
    ///window_restore()
    //Restores the window from a maximized state.
    
    placement.length=sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(outer_handle,&placement);
    
    BOOL minimized=(placement.showCmd & SW_SHOWMINIMIZED) != 0;
    if (!minimized) return 0;
    
    placement.showCmd = SW_SHOWNORMAL;
    SetWindowPlacement(outer_handle,&placement);
    
    return 0;
}

GMREAL __gm82core_set_foreground(double gm_hwnd) {
    ///window_set_foreground()
    //Puts the game window on top of all other windows.
    
    SetForegroundWindow(window_handle);
    return 0;
}

GMREAL get_foreground_window() {
    return (double)(GetForegroundWindow()==window_handle);
}

GMREAL get_windows_version() {
    ///get_windows_version()
    //returns: Windows version as a number.
    //Windows XP: 5.0
    //Windows Vista: 6.0
    //Windows 7: 7.0
    //Windows 8: 8.0
    //Windows 8.1: 8.1
    //Windows 10: 10.0
    //Windows 11: 11.0
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

GMSTR __gm82core_shortfn(const char* fname) {
	GetShortPathNameA(fname,shortfn,MAX_PATH);
    return shortfn;
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
    ///keyboard_get_capslock()
    //returns: if the keyboard caps led is on.
    
    return (double)(GetKeyState(VK_CAPITAL) & 1);
}

GMREAL get_scrolllock() {
    ///keyboard_get_scrolllock()
    //returns: if the keyboard scroll led is on.
    
    return (double)(GetKeyState(VK_SCROLL) & 1);
}

GMREAL get_ram_usage() {
    ///get_ram_usage()
    //returns: An approximate amount of bytes used in main system memory.
    //A GM8.2 game may use a maximum of 3500MB of ram.
    
    DWORD dwProcessId;
    HANDLE Process;
    PROCESS_MEMORY_COUNTERS_EX pmc;
    
    dwProcessId = GetCurrentProcessId();
    Process = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,FALSE,dwProcessId);
    GetProcessMemoryInfo(Process,(PROCESS_MEMORY_COUNTERS*)&pmc,sizeof(pmc));
    CloseHandle(Process);
    
    return pmc.PrivateUsage;
}

GMREAL set_working_directory(const char* dir) {
    ///set_working_directory(directory)
    //directory: path to use
    //Changes the current working directory.
    
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
    ///io_get_language()
    //returns: system language in Windows LCID (locale code id) form.
    
    return (double)GetUserDefaultUILanguage();
}

GMREAL get_window_col() {
    ///window_get_caption_color()
    //returns: Windows Metro window title accent color.
    //In Windows XP, the default Luna Blue color is returned.
    
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
    ///sleep_ext(ms)
    //ms: milliseconds to sleep
    //Sleeps while not updating keyboard and mouse state.
    
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

GMSTR __registry_read_sz(const char* dir, const char* keyname) {
    HKEY key;
	wstr wdir=make_wstr(dir);
    HRESULT res = RegOpenKeyExW(HKEY_CURRENT_USER, wdir, 0, KEY_READ, &key);
	free(wdir);
    if (res == 0) {
        int size = 8192;
		res = RegQueryValueExA(key, keyname, NULL, NULL, (LPBYTE)&regsz, &size);
		RegCloseKey(key);
        if (res == 0) {
            regsz[size]=0;                     
        } else { strcpy(regsz,"<undefined>"); }
    } else { strcpy(regsz,"<undefined>"); }
    
    return regsz;
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

GMREAL file_get_timestamp(const char *filename) {
    ///file_get_timestamp(filename)
    //filename: string - name of file to check
    //returns: The last modified date of a file on disk.
    
    WIN32_FILE_ATTRIBUTE_DATA attr;

    if (!GetFileAttributesExA(filename, GetFileExInfoStandard, &attr))
        return -1.0;
    
    TIME_ZONE_INFORMATION TimeZoneInformation;
    GetTimeZoneInformation(&TimeZoneInformation);
    uint64 timezone=(TimeZoneInformation.Bias) * 60.0 * 1000.0 * 1000.0 * 10.0;
    
    FILETIME time=attr.ftLastWriteTime;
    
    uint64 wintime=(uint64)time.dwLowDateTime | ((uint64)time.dwHighDateTime << 32);
    
    double base = -109205.0;
    double step = 24.0 * 60.0 * 60.0 * 1000.0 * 1000.0 * 10.0;
    
    return (wintime-timezone)/step+base;
}

GMREAL date_get_current_timezone() {
    ///date_get_current_timezone()
    //returns: The current timezone correction, in hours, based on GMT.
    
    TIME_ZONE_INFORMATION TimeZoneInformation;
    GetTimeZoneInformation(&TimeZoneInformation);
    double timezone=(TimeZoneInformation.Bias)/60;
   
    return -timezone;
}

GMREAL get_battery_level() {
    SYSTEM_POWER_STATUS status;
    GetSystemPowerStatus(&status);
    return status.BatteryLifePercent;
}

GMREAL get_battery_status() {
    SYSTEM_POWER_STATUS status;
    GetSystemPowerStatus(&status);
    if (status.BatteryFlag>=128) return 0;
    if (status.ACLineStatus==1) return 2;
    return 1;
}