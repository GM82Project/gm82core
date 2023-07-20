#include "gm82core.h"

GMREAL modwrap(double,double,double);

double signnum_c(double x) {
    if (x > 0.0) return 1.0;
    if (x < 0.0) return -1.0;
    return x;
}
double pointdir(double x1,double y1,double x2,double y2) {
    return modwrap(atan2(-(y2-y1),x2-x1)*180/M_PI,0,360);
}
double pointdis(double x1,double y1,double x2,double y2) {
    return hypot(x2-x1,y2-y1);
}
double pointdis3d(double x1,double y1,double z1,double x2,double y2,double z2) {
    return sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
}
double dot(double x1,double y1,double x2,double y2) {
    return (x1*x2+y1*y2);
}
double dot3d(double x1,double y1,double z1,double x2,double y2,double z2) {
    return (x1*x2+y1*y2+z1*z2);
}

//-//

GMREAL modwrap(double val, double minv, double maxv) {
    ///modwrap(val,min,max)
    //val: real - value to bound
    //min: real - minimum value
    //max: real - maximum value
    //Bounds the value between min and max - maximum exclusive.
    
    double f=val-minv;
    double w=maxv-minv;
    return f-floor(f/w)*w+minv;
}
GMREAL lerp2(double fromA, double fromB, double toA, double toB, double value) {
    ///lerp2(fromA,fromB,toA,toB,value)
    //fromA: real - start value from
    //fromB: real - end value from
    //toA: real - start value to
    //toB: real - end value to
    //value: real - value to project
    //Projects a value from line segment 'from' to segment 'to'.
    
    return ((value-fromA)/(fromB-fromA))*(toB-toA)+toA;
}
GMREAL unlerp(double a, double b, double val) {
    ///unlerp(a,b,val)
    //a: real - start value
    //b: real - end value
    //val: real - value to convert
    //Returns the reverse lerp of value between a and b.
    
    return (val-a)/(b-a);
}
GMREAL esign(double x, double def) {
    ///esign(x,default)
    //x: real - value to get the sign of
    //default: real - default value to return
    //Returns the default value when x is zero, otherwise returns the sign of x.
    if (x==0.0) return def;
    if (x>0.0) return 1;
    return -1;
}
GMREAL saturate(double val) {
    return max(0,min(val,1));
}
GMREAL inch(double val, double go, double step) {
    if (val<go) return min(go,val+step);
    return max(go,val-step);
}
GMREAL round_unbiased(double val) {
    return floor(val+0.5);
}
GMREAL roundto(double val, double to) {
    return round(val/to)*to;
}
GMREAL roundto_unbiased(double val, double to) {
    return floor(val/to+0.5)*to;
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
    return modwrap(ang2-ang1+540.0,0.0,360.0)-180.0;
}
GMREAL inch_angle(double ang1, double ang2, double step) {
    double d=fmod(ang2-ang1+540.0,360.0)-180.0;
    if (d>0.0) return fmod(ang1+min(d,step),360.0);
    return fmod(360.0-fmod(360.0-(ang1+max(-step,d)),360.0),360.0);
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
GMREAL secant(double ang) {
    return 1/cos(ang);
}
GMREAL dsecant(double ang) {
    return 1/cos(ang/180*M_PI);
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
GMREAL lengthdir_zx(double len,double dir,double dirz) {
    return len*dcos(dirz)*dcos(dir);
}
GMREAL lengthdir_zy(double len,double dir,double dirz) {
    return -len*dcos(dirz)*dsin(dir);
}
GMREAL lengthdir_zz(double len,double dir,double dirz) {
    return -len*dsin(dirz);
}
GMREAL lendirx(double len,double dir) {
    return len*dcos(dir);
}
GMREAL lendiry(double len,double dir) {
    return -len*dsin(dir);
}
GMREAL point_direction_pitch(double x1, double y1, double z1, double x2, double y2, double z2) {
    return pointdir(0.0,z1,pointdis(x1,y1,x2,y2),z2);
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
    if (tx < x1) tx = x1;
    else if (tx > x2) tx = x2;

    if (ty < y1) ty = y1;
    else if (ty > y2) ty = y2;

    return (pointdis(tx,ty,cx,cy)<cr);
}
GMREAL point_in_rectangle(double px, double py, double x1, double y1, double x2, double y2) {
    return (px>=x1 && px<x2 && py>=y1 && py<y2);
}
GMREAL rectangle_in_rectangle(double ax1, double ay1, double ax2, double ay2, double bx1, double by1, double bx2, double by2) {
    if (ax1>=bx1 && ax2<=bx2 && ay1>=by1 && ay2<=by2) return 1;
    if (ax1>bx2 || ax2<bx1 || ay1>by2 || ay2<by1) return 0;
    return 2;
}
GMREAL point_in_triangle(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
    double a, b, c;
    a = (x1-x0)*(y2-y0)-(x2-x0)*(y1-y0);
    b = (x2-x0)*(y3-y0)-(x3-x0)*(y2-y0);
    c = (x3-x0)*(y1-y0)-(x1-x0)*(y3-y0);
    return (signnum_c(a) == signnum_c(b) && signnum_c(b) == signnum_c(c))?1.0:0.0;
}
GMREAL in_range(double val, double vmin, double vmax) {
    return (val>=vmin && val<=vmax)?1.0:0.0;
}
GMREAL point_line_lerp(double px, double py, double x1, double y1, double x2, double y2, double segment) {
    ///point_line_lerp(px,py,x1,y1,x2,y2,segment)
    //
    //  Returns the projected value from the given point to the given line.
    //
    //      px,py       point to measuring from
    //      x1,y1       1st end point of line
    //      x2,y2       2nd end point of line
    //      segment     set to true to limit to the line segment
    //
    /// GMLscripts.com/license
    double dx = x2-x1;
    double dy = y2-y1;
    if ((dx == 0) && (dy == 0)) {
        return 0;
    } else {
        double t = (dx*(px-x1) + dy*(py-y1)) / (dx*dx+dy*dy);
        if (segment>0.5) t = min(max(t, 0), 1);
        return t;
    }
}
GMREAL point_line_distance(double px, double py, double x1, double y1, double x2, double y2, double segment) {
    double t=point_line_lerp(px,py,x1,y1,x2,y2,segment);
    double xs = x1 + t * (x2-x1);
    double ys = y1 + t * (y2-y1);

    return pointdis(xs, ys, px, py);
}
GMREAL dot_product_3d_normalised(double x1, double y1, double z1, double x2, double y2, double z2) {
    double a=pointdis3d(0,0,0,x1,y1,z1);
    double b=pointdis3d(0,0,0,x2,y2,z2);
    
    if (a*b==0) return 1;

    return dot3d(x1/a,y1/a,z1/a,x2/b,y2/b,z2/b);
}
GMREAL dot_product_normalised(double x1, double y1, double x2, double y2) {
    double a=pointdis(0,0,x1,y1);
    double b=pointdis(0,0,x2,y2);
    
    if (a*b==0) return 1;

    return dot(x1/a,y1/a,x2/b,y2/b);
}
GMREAL angle_difference_3d(double x1, double y1, double z1, double x2, double y2, double z2) {
    return darccos(dot_product_3d_normalised(x1,y1,z1,x2,y2,z2));
}