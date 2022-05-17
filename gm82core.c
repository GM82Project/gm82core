#include "gm82core.h"

static int has_started;

static char* tokenstore = NULL;
static char* tokenpos = NULL;
static char tokensep[256] = {0};
static size_t tokenseplen = 0;

GMREAL __gm82core_checkstart() {
    if (has_started) return 0;
    has_started = 1;
    return 1;
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

GMREAL set_working_directory(char* dir) {
    SetCurrentDirectory(dir);
    return 0;
}

GMREAL __gm82core_winver() {
    if (IsWindows8OrGreater()) return 8;
    if (IsWindows7OrGreater()) return 7;
    if (IsWindowsVistaOrGreater()) return 6;
    if (IsWindowsXPOrGreater()) return 5;
    return 4;
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

GMREAL modwrap(double val, double minv, double maxv) {
    double f=val-minv;
    double w=maxv-minv;
    return f-floor(f/w)*w+minv;
}

GMREAL lerp2(double fromA, double fromB, double toA, double toB, double value) {
    return ((value-fromA)/(fromB-fromA))*(toB-toA)+toA;
}

GMREAL unlerp(double a, double b, double val) {
    return (val-a)/(b-a);
}

double pointdir(double x1,double y1,double x2,double y2) {
    return modwrap(atan2(y1-y2,x1-x2)*180/M_PI,0,360);
}
double pointdis(double x1,double y1,double x2,double y2) {
    return hypot(x2-x1,y2-y1);
}

GMREAL lendirx(double len,double dir) {
    return len*dcos(dir);
}
GMREAL lendiry(double len,double dir) {
    return -len*dsin(dir);
}

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

GMREAL esign(double x, double def) {
    if (x==0.0) return def;
    if (x>0.0) return 1;
    return -1;
}

GMREAL inch(double val, double go, double step) {
    if (val<go) return min(go,val+step);
    return max(go,val-step);
}

GMREAL roundto(double val, double to) {
    return round(val/to)*to;
}

GMREAL floorto(double val, double to) {
    return floor(val/to)*to;
}

GMREAL ceilto(double val, double to) {
    return ceil(val/to)*to;
}

GMREAL cosine(double a, double b, double amount) {
    double mu = (1-cos(amount*M_PI))/2;     
    return (a*(1-mu)+b*mu);
}

GMREAL angle_difference(double ang1, double ang2) {
    return fmod(ang2-ang1+540.0,360.0)-180.0;
}

GMREAL inch_angle(double ang1, double ang2, double step) {
    double d=fmod(ang2-ang1+540.0,360.0)-180.0;
    if (d>0.0) return fmod(ang1+min(d,step),360.0);
    return 360.0-fmod(360.0-(ang1+max(-step,d)),360.0);
}

GMREAL darccos(double ang) {
    return acos(ang)*180/M_PI;    
}

GMREAL darcsin(double x) {
    return asin(x)*180/M_PI;    
}

GMREAL darctan(double x) {
    return atan(x)*180/M_PI;    
}

GMREAL darctan2(double y, double x) {
    return atan2(y, x)*180/M_PI;    
}

GMREAL dcos(double ang) {
    return cos(ang/180*M_PI);    
}

GMREAL dsin(double ang) {
    return sin(ang/180*M_PI);    
}

GMREAL dtan(double ang) {
    return tan(ang/180*M_PI);    
}

GMREAL point_direction_pitch(double x1, double y1, double z1, double x2, double y2, double z2) {
    return pointdir(0.0,z1,pointdis(x1,y1,x2,y2),z2);
}

GMREAL triangle_is_clockwise(double x0, double y0, double x1, double y1, double x2, double y2) {
    int clockwise = 0;
    if ((x0 != x1) || (y0 != y1)) {
        if (x0 == x1) {
            clockwise = (x2 < x1) ^ (y0 > y1);
        } else {
            double m = (y0 - y1) / (x0 - x1);
            clockwise = (y2 > (m * x2 + y0 - m * x0)) ^ (x0 > x1);
        }
    }
    return (double)clockwise;
}

GMREAL color_reverse(double color) {
    int col=(int)round(color);
    return ((col & 0xff)<<16) + (col & 0xff00) + ((col & 0xff0000)>>16);
}

GMREAL color_inverse(double color) {
    return 0xffffff-(int)round(color);
}

GMREAL lengthdir_zx(double len,double dir,double dirz) {
    return len*dcos(dirz)*dcos(dir);
}

GMREAL lengthdir_zy(double len,double dir,double dirz) {
    return -len*dcos(dirz)*dsin(dir);
}

GMREAL lengthdir_zz(double len,double dir,double dirz) {
    return -len*dsin(dirz);
}

GMREAL pivot_pos_x(double px,double py,double dir) {
    return lendirx(px,dir)+lendirx(py,dir-90);
}

GMREAL pivot_pos_y(double px,double py,double dir) {
    return lendiry(px,dir)+lendiry(py,dir-90);
}

GMREAL point_in_circle(double px, double py, double x1, double y1, double r) {
    return (pointdis(px,py,x1,y1)<r);
}

GMREAL circle_in_circle(double ax, double ay, double ar, double bx, double by, double br) {
    return (pointdis(ax,ay,bx,by)<(ar+br));
}

GMREAL rectangle_in_circle(double x1, double y1, double x2, double y2, double cx, double cy, double cr) {
    double tx = cx;
    double ty = cy;
    if (tx < x1)
        tx = x1;
    else if (tx > x2)
        tx = x2;

    if (ty < y1)
        ty = y1;
    else if (ty > y2)
        ty = y2;

    return (pointdis(tx,ty,cx,cy)<cr);
}

GMREAL point_in_rectangle(double px, double py, double x1, double y1, double x2, double y2) {
    return (px>=x1 && px<x2 && py>=y1 && py<y2);
}

GMREAL rectangle_in_rectangle(double ax1, double ay1, double ax2, double ay2, double bx1, double by1, double bx2, double by2) {
    return (ax1>=bx1 && ax2<=bx2 && ay1>=by1 && ay2<=by2);
}

GMREAL point_in_triangle(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
    return (
        !triangle_is_clockwise(x0,y0,x1,y1,x3,y3) &&
        !triangle_is_clockwise(x1,y1,x2,y2,x3,y3) &&
        !triangle_is_clockwise(x2,y2,x0,y0,x3,y3)
    );
}

GMREAL in_range(double val, double vmin, double vmax) {
    return (val>=vmin && val<=vmax)?1.0:0.0;
}

GMREAL string_token_start(const char* str, const char* sep) {
    tokenseplen = min(255,strlen(sep));
    tokenstore = realloc(tokenstore, strlen(str)+1);
    strcpy(tokenstore, str);
    strncpy(tokensep, sep, tokenseplen);
    tokenpos = tokenstore;
    return 0;
}

GMSTR string_token_next() {
    char* startpos = tokenpos;
    if (startpos) {
        tokenpos = strstr(tokenpos, tokensep);        
        if (tokenpos) {
            tokenpos[0]=0;
            tokenpos+=tokenseplen;
        }
    }
    return startpos;
}

GMREAL sleep_ext(double ms) {
    SleepEx((DWORD)ms,TRUE);
    return 0;
}
