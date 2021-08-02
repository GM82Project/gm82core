#define GMREAL __declspec(dllexport) double __cdecl
#define GMSTR __declspec(dllexport) char* __cdecl
#define _USE_MATH_DEFINES
#define _WIN32_WINNT 0x0601
#include <windows.h>
#include <versionhelpers.h>
#include <math.h>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "user32.lib")

//begin really terrible gm hacking//

const void* delphi_clear = (void*)0x4072d8;
static char* retstr = NULL;

//GMREAL funny_test(double ptr, double value) {int a = (int)ptr;int* where = (int*)a;int what = (int)value;*where = what;return 0;

GMREAL __gm82core_setfullscreen(double hz) {
    int z = (int)hz;
    
    *(int*)0x85af74 = 0;  //multisample off
    *(int*)0x85af7c = 3;  //swap effect copy
    *(int*)0x85b3a8 = !z; //windowed mode
    *(int*)0x85b3b8 = z;  //refresh rate
    
    ((void (*)())0x61f9f4)(); //display_reset()

    return 1;
}

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

GMSTR internal_call_string1s(double func, char* arg0) {
    GMVAL args[1];
    args[0].is_string=1; args[0].string=arg0;

    return internal_call_string(func,args,1);
}

//end really terrible gm hacking//

GMREAL get_window_col() {
	HKEY key;
	HRESULT res = RegOpenKeyExA(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\DWM", 0, KEY_READ, &key);
	if (res == 0) {
		int col;
		int size = 4;
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

GMREAL resize_backbuffer(double width, double height) {
    int iwidth = width;
    int iheight = height;
    const void *fun = (void*)0x61fbc0; //YoYo_resize_backbuffer
    __asm {
        mov eax, iwidth
        mov edx, iheight
        call fun
    }
    return 0;
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
