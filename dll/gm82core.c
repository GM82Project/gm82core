#define GMREAL __declspec(dllexport) double __cdecl
#define _USE_MATH_DEFINES
#include <windows.h>
#include <math.h>

#pragma comment(lib, "user32.lib")

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

GMREAL cosine(double a, double b, double amount) {
    double mu = (1-cos(amount*M_PI))/2;     
    return (a*(1-mu)+b*mu);
}

GMREAL angle_difference(double ang1, double ang2) {
    return fmod(ang2-ang1+540.0,360.0)-180.0;
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
