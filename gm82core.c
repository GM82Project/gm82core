#define GMREAL __declspec(dllexport) double __cdecl
#define GMSTR __declspec(dllexport) char* __cdecl
#define _USE_MATH_DEFINES
#define _WIN32_WINNT 0x0601
#include <windows.h>
#include <versionhelpers.h>
#include <math.h>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "user32.lib")

static int has_started;

GMREAL __gm82core_checkstart() {
    if (has_started) return 0;
    has_started = 1;
    return 1;
}

//begin high resolution timer//

ULONGLONG resolution = 1000000, lastTime = 0, frequency = 1;

GMREAL hrt_init() {
    if (QueryPerformanceFrequency((LARGE_INTEGER *)&frequency) && QueryPerformanceCounter((LARGE_INTEGER*)&lastTime)) {
        return 1;
    } else {
        return 0;
    }
}

GMREAL hrt_now() {
    ULONGLONG now;
    if (QueryPerformanceCounter((LARGE_INTEGER*)&now)) {
        return (double)(now*resolution/frequency);
    } else {
        return -1.0;
    }
}

GMREAL hrt_delta() {
    ULONGLONG now, lt;
    if (QueryPerformanceCounter((LARGE_INTEGER*)&now)) {
        lt = lastTime;
        lastTime = now;
        return (double)((now - lt)*resolution/frequency);
    } else {
        return -1.0;
    }
}

//end high resolution timer//

//begin really terrible gm hacking//

const void* delphi_clear = (void*)0x4072d8;
static char* retstr = NULL;

static char* tokenstore = NULL;
static char* tokenpos = NULL;
static char tokensep[256] = {0};
static size_t tokenseplen = 0;

//GMREAL funny_test(double ptr, double value) {int a = (int)ptr;int* where = (int*)a;int what = (int)value;*where = what;return 0;

typedef struct {
    int is_string;
    int padding;    
    double real;    
    char* string;
    int padding2;    
}GMVAL;

double internal_call_real(double func,GMVAL* args,int argc) {
    int addr = (int)func;
    char* (*callptr)()=(void*)addr;
    
    GMVAL ret={0};
    GMVAL* retptr = &ret;    
    
    __asm {
        mov ecx, argc //argc
        push args //pointer to gml argument array
        push 16 //args length (unused)
        push retptr        
        call callptr
    }   

    return ret.real;
}

char* internal_call_string(double func,GMVAL* args,int argc) {
    int addr = (int)func;
    char* (*callptr)()=(void*)addr;
    
    GMVAL ret={0};    
    GMVAL* retptr = &ret;

    char** retstrptr = &retstr;

    __asm {
        mov ecx, argc //argc
        push args //pointer to gml argument array
        push 16 //args length (unused)
        push retptr        
        call callptr
    
        mov eax, retstrptr
        call delphi_clear
    }   

    retstr=ret.string;

    return retstr;
}

GMREAL internal_call_real0(double func) {
    return internal_call_real(func,NULL,0);
}

GMREAL internal_call_real1r(double func, double arg0) {
    GMVAL args[1];
    args[0].is_string=0; args[0].real=arg0;

    return internal_call_real(func,args,1);
}
GMREAL internal_call_real2rr(double func, double arg0, double arg1) {
    GMVAL args[2];
    args[0].is_string=0; args[0].real=arg0;
    args[1].is_string=0; args[1].real=arg1;

    return internal_call_real(func,args,2);
}
GMREAL internal_call_real3rrr(double func, double arg0, double arg1, double arg2) {
    GMVAL args[3];
    args[0].is_string=0; args[0].real=arg0;
    args[1].is_string=0; args[1].real=arg1;
    args[2].is_string=0; args[2].real=arg2;

    return internal_call_real(func,args,3);
}

GMSTR internal_call_string0(double func) {
    return internal_call_string(func,NULL,0);
}

/*GMSTR internal_call_string1s(double func, char* arg0) {
    GMVAL args[1];
    args[0].is_string=1; args[0].string=arg0;

    return internal_call_string(func,args,1);
}*/

//end really terrible gm hacking//

GMREAL get_window_col() {
    HKEY key;
    HRESULT res = RegOpenKeyExA(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\DWM", 0, KEY_READ, &key);
    if (res == 0) {
        int col;
        int size = 4;
        res = RegQueryValueExA(key, "ColorPrevalence", NULL, NULL, (LPBYTE)&col, &size);
        if (res==0) {
            //if color prevalence is turned off, window titles are just colored white
            if (col==0) return 0xffffff;
        }        
        res = RegQueryValueExA(key, "ColorizationColor", NULL, NULL, (LPBYTE)&col, &size);
        RegCloseKey(key);
        if (res == 0) {
            return ((col & 0xff0000) >> 16) | (col & 0xff00) | ((col & 0xff) << 16);
        } else { return res; }
    } else { return res; }
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

GMREAL win_ver() {
    if (IsWindows8OrGreater()) return 8;
    if (IsWindows7OrGreater()) return 7;
    if (IsWindowsVistaOrGreater()) return 6;
    if (IsWindowsXPOrGreater()) return 5;
    return 4;
}

GMREAL modwrap(double val, double minv, double maxv) {
    double f=val-minv;
    double w=maxv-minv;
    return f-floor(f/w)*w+minv;
}

double pointdir(double x1,double y1,double x2,double y2) {
    return modwrap(atan2(y1-y2,x1-x2)*180/M_PI,0,360);
}
double pointdis(double x1,double y1,double x2,double y2) {
    return hypot(x2-x1,y2-y1);
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
    return acos(ang/180*M_PI);    
}

GMREAL darcsin(double ang) {
    return asin(ang/180*M_PI);    
}

GMREAL darctan(double ang) {
    return atan(ang/180*M_PI);    
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

GMREAL rgb_to_bgr(double color) {
    int col=round(color);
    return ((col & 0xff)<<16) + (col & 0xff00) + ((col & 0xff0000)>>16);
}

GMREAL lengthdir_zx(double len,double dir,double dirz) {
    return len*dcos(dirz)*dcos(dir);
}

GMREAL lengthdir_zy(double len,double dir,double dirz) {
    return -len*dsin(dirz)*dcos(dir);
}

GMREAL lengthdir_zz(double len,double dir,double dirz) {
    return -len*dsin(dirz);
}

GMREAL point_in_circle(double px, double py, double x1, double y1, double r) {
    return (pointdis(px,py,x1,y1)<r);
}

GMREAL point_in_rectangle(double px, double py, double x1, double y1, double x2, double y2) {
    return (px>=x1 && px<x2 && py>=y1 && py<y2);
}

GMREAL point_in_triangle(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
    return (
        !triangle_is_clockwise(x0,y0,x1,y1,x3,y3) &&
        !triangle_is_clockwise(x1,y1,x2,y2,x3,y3) &&
        !triangle_is_clockwise(x2,y2,x0,y0,x3,y3)
    );
}

GMREAL real_hex(const char *str) {
  //(c) Lovey01
  // Avoids subtraction at the cost of more memory
  static const unsigned long long lookup[256] = {
    // First 32 chars
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,

    // ASCII map
    0,  // Space
    0,  // !
    0,  // "
    0,  // #
    0,  // $
    0,  // %
    0,  // &
    0,  // '
    0,  // (
    0,  // )
    0,  // *
    0,  // +
    0,  // ,
    0,  // -
    0,  // .
    0,  // /
    0,  // 0
    1,  // 1
    2,  // 2
    3,  // 3
    4,  // 4
    5,  // 5
    6,  // 6
    7,  // 7
    8,  // 8
    9,  // 9
    0,  // :
    0,  // ;
    0,  // <
    0,  // =
    0,  // >
    0,  // ?
    0,  // @
    10, // A
    11, // B
    12, // C
    13, // D
    14, // E
    15, // F
    0,  // G
    0,  // H
    0,  // I
    0,  // J
    0,  // K
    0,  // L
    0,  // M
    0,  // N
    0,  // O
    0,  // P
    0,  // Q
    0,  // R
    0,  // S
    0,  // T
    0,  // U
    0,  // V
    0,  // W
    0,  // X
    0,  // Y
    0,  // Z
    0,  // [
    0,  // |
    0,  // ]
    0,  // ^
    0,  // _
    0,  // `
    10, // a
    11, // b
    12, // c
    13, // d
    14, // e
    15, // f

    // The rest are zeros
  };

  unsigned char c;
  unsigned long long ret = 0;

  // Process 16 chars at a time
#define LOOP                                      \
  if (!(c = *(unsigned char*)str++)) return ret;  \
  ret = ret<<4 | lookup[c]

  for (;;) {
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
  }

#undef LOOP
}
    
GMSTR string_hex(double num) {
  //(c) Lovey01
  // Return buffer  
  static char retbuf[17] = {0}; // Initialize to all 0's

  static const char lookup[] = {
    '0', '1', '2', '3',
    '4', '5', '6', '7',
    '8', '9', 'A', 'B',
    'C', 'D', 'E', 'F'
  };

  unsigned long long i = num;
  char *ret = retbuf+15; // Last character minus one, NULL terminator required

  *ret = lookup[i&0xf];
  while ((i >>= 4) != 0) {
    *--ret = lookup[i&0xf];
  }

  return (char*)ret;
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
