#include "gm82core.h"

GMREAL modwrap(double,double,double);
GMREAL dcos(double);
GMREAL dsin(double);

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
double lendirx(double len,double dir) {
    return len*dcos(dir);
}
double lendiry(double len,double dir) {
    return -len*dsin(dir);
}

//-//

GMREAL modwrap(double val, double minv, double maxv) {
    ///modwrap(val,min,max)
    //val: value to wrap
    //min: minimum value
    //max: maximum value
    //returns: wrapped value
    //Repeats the value inside the window defined by min and max - max exclusive.
    
    double f=val-minv;
    double w=maxv-minv;
    return f-floor(f/w)*w+minv;
}

GMREAL lerp2(double fromA, double fromB, double toA, double toB, double value) {
    ///lerp2(fromA,fromB,toA,toB,value)
    //fromA: start value from
    //fromB: end value from
    //toA: start value to
    //toB: end value to
    //value: value to project
    //returns: projected value
    //Projects 'value' from line segment 'from' to segment 'to'.
    
    return ((value-fromA)/(fromB-fromA))*(toB-toA)+toA;
}

GMREAL unlerp(double a, double b, double val) {
    ///unlerp(a,b,val)
    //a: start value
    //b: end value
    //val: real - value to convert
    //returns: the reverse lerp of 'value' between 'a' and 'b'.
    
    return (val-a)/(b-a);
}

GMREAL esign(double x, double def) {
    ///esign(x,default):sign
    //x: value to get the sign of
    //default: default value to return
    //returns: the default value when x is zero, otherwise returns the sign of x.
    
    if (x==0.0) return def;
    if (x>0.0) return 1;
    return -1;
}

GMREAL saturate(double val) {
    ///saturate(x)
    //x: value
    //returns: x clamped between 0 and 1.
    
    return max(0,min(val,1));
}

GMREAL approach(double val, double go, double step) {
    ///approach(val,go,step)
    //val: value to increment
    //go: target value
    //step: size of step to take
    //returns: 'value' approximated to 'go' by 'step'.
    
    if (val<go) return min(go,val+step);
    return max(go,val-step);
}

GMREAL round_unbiased(double val) {
    ///round_unbiased(x)
    //x: value
    //returns: non-banker's rounding of x.
    
    return floor(val+0.5);
}

GMREAL roundto(double val, double to) {
    ///roundto(val,to)
    //val: value to round
    //to: grid size
    //returns: 'val' rounded to the nearest multiple of 'to'.
    
    return round(val/to)*to;
}

GMREAL roundto_unbiased(double val, double to) {
    ///roundto_unbiased(val,to)
    //val: value to round
    //to: grid size
    //returns: 'val' rounded to the nearest multiple of 'to', using non-banker's round.
    
    return floor(val/to+0.5)*to;
}

GMREAL floorto(double val, double to) {
    ///floorto(val,to)
    //val: value to floor
    //to: grid size
    //returns: 'val' floored to the nearest multiple of 'to'.
    
    return floor(val/to)*to;
}

GMREAL ceilto(double val, double to) {
    ///ceilto(val,to)
    //val: value to ceil
    //to: grid size
    //returns: 'val' ceiled to the nearest multiple of 'to'.
    
    return ceil(val/to)*to;
}

GMREAL cosine(double a, double b, double amount) {
    ///cosine(a,b,amount)
    //a,b: start and end values
    //amount: interpolation factor
    //returns: cosine interpolation of ab.
    
    double mu = (1-cos(amount*M_PI))/2;     
    return (a*(1-mu)+b*mu);
}

GMREAL angle_difference(double ang1, double ang2) {
    ///angle_difference(ang1,ang2)
    //ang1,ang2: angles to compare
    //returns: the relative difference between two angles.
    
    return modwrap(ang2-ang1+540.0,0.0,360.0)-180.0;
}

GMREAL approach_angle(double ang1, double ang2, double step) {
    ///approach_angle(ang1,ang2,step)
    //ang1: angle to increment
    //go: target angle
    //step: size of step to take
    //returns: 'ang1' approximated to 'ang2' by 'step'.
    
    double d=fmod(ang2-ang1+540.0,360.0)-180.0;
    if (d>0.0) return fmod(ang1+min(d,step),360.0);
    return fmod(360.0-fmod(360.0-(ang1+max(-step,d)),360.0),360.0);
}

GMREAL darccos(double ang) {
    ///darccos(ang)
    //ang: angle in degrees
    //returns: arc cosine in degrees.
    
    return acos(ang)*180/M_PI;    
}

GMREAL darcsin(double x) {
    ///darcsin(ang)
    //ang: angle in degrees
    //returns: arc sine in degrees.
    
    return asin(x)*180/M_PI;    
}

GMREAL darctan(double x) {
    ///darccos(ang)
    //ang: angle in degrees
    //returns: arc tangent in degrees.
    
    return atan(x)*180/M_PI;    
}

GMREAL darctan2(double y, double x) {
    ///darctan2(y,x)
    //returns: arc tangent 2 in degrees.
    
    return atan2(y, x)*180/M_PI;    
}

GMREAL dcos(double ang) {
    ///dcos(x)
    //x: angle in degrees
    //returns: cosine in degrees.
    
    return cos(ang/180*M_PI);    
}

GMREAL dsin(double ang) {
    ///dsin(x)
    //x: angle in degrees
    //returns: sine in degrees.
    
    return sin(ang/180*M_PI);    
}

GMREAL dtan(double ang) {
    ///dtan(x)
    //x: angle in degrees
    //returns: tangent in degrees.
    
    return tan(ang/180*M_PI);    
}

GMREAL secant(double ang) {
    ///secant(rad)
    //rad: angle in radians
    //returns: secant of an angle in radians.
    
    return 1/cos(ang);
}

GMREAL dsecant(double ang) {
    ///dsecant(ang)
    //ang: angle in degrees
    //returns: secant of an angle in degrees.
    
    return 1/cos(ang/180*M_PI);
}

GMREAL triangle_is_clockwise(double x0, double y0, double x1, double y1, double x2, double y2) {
    ///triangle_is_clockwise(x1,y1,x2,y2,x3,y3):bool
    //x1,y1: first point.
    //x2,y2: second point.
    //x3,y3: third point.
    //returns: whether the triangle defined by 3 points is clockwise.
    
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
    ///lengthdir_zx(len,dir,dirz)
    //len: length of vector
    //dir,dirz: pitch 3d direction
    //returns: x component of 3d vector
    
    return len*dcos(dirz)*dcos(dir);
}

GMREAL lengthdir_zy(double len,double dir,double dirz) {
    ///lengthdir_zy(len,dir,dirz)
    //len: length of vector
    //dir,dirz: pitch 3d direction
    //returns: y component of 3d vector
    
    return -len*dcos(dirz)*dsin(dir);
}

GMREAL lengthdir_zz(double len,double dir,double dirz) {
    ///lengthdir_zz(len,dir,dirz)
    //len: length of vector
    //dir,dirz: pitch 3d direction
    //returns: z component of 3d vector
    
    return -len*dsin(dirz);
}

GMREAL point_direction_pitch(double x1, double y1, double z1, double x2, double y2, double z2) {
    ///point_direction_pitch(x1,y1,z1,x2,y2,z2)
    //x1,y1,z1: first point
    //x2,y2,z2: second point
    //returns: pitch-component of 3d direction between two 3d points.
    
    return pointdir(0.0,z1,pointdis(x1,y1,x2,y2),z2);
}

GMREAL pivot_pos_x(double px,double py,double dir) {
    ///pivot_pos_x(px,py,dir)
    //px,py: point to rotate
    //dir: angle to rotate by
    //returns: x component of two-dimensional lengthdir of a point.
    
    return lendirx(px,dir)+lendirx(py,dir-90);
}

GMREAL pivot_pos_y(double px,double py,double dir) {
    ///pivot_pos_y(px,py,dir)
    //px,py: point to rotate
    //dir: angle to rotate by
    //returns: y component of two-dimensional lengthdir of a point.
    
    return lendiry(px,dir)+lendiry(py,dir-90);
}

GMREAL point_in_circle(double px, double py, double x1, double y1, double r) {
    ///point_in_circle(px,py,x,y,r)
    //px,py: point to check
    //x,y,r: circle to check
    //returns: whether the point is inside the circle.
    
    return (pointdis(px,py,x1,y1)<r);
}

GMREAL circle_in_circle(double ax, double ay, double ar, double bx, double by, double br) {
    ///point_in_circle(x1,y1,r1,x2,y2,r2)
    //x1,y1,r1: first circle to check
    //x2,y2,r2: second circle to check
    //returns: whether the circles intersect.
    
    return (pointdis(ax,ay,bx,by)<(ar+br));
}

GMREAL rectangle_in_circle(double x1, double y1, double x2, double y2, double cx, double cy, double cr) {
    ///rectangle_in_circle(x1,y1,x2,y2,cx,cy,cr)
    //x1,y1,x2,y2: rectangle to check
    //cx,cy,cr: circle to check
    //returns: whether the circle intersects the rectangle.    
    
    double tx = cx;
    double ty = cy;
    if (tx < x1) tx = x1;
    else if (tx > x2) tx = x2;

    if (ty < y1) ty = y1;
    else if (ty > y2) ty = y2;

    return (pointdis(tx,ty,cx,cy)<cr);
}

GMREAL point_in_rectangle(double px, double py, double x1, double y1, double x2, double y2) {
    ///point_in_rectangle(px,py,x1,y1,x2,y2)
    //px,py: point to check
    //x1,y1,x2,y2: rectangle to check
    //returns: whether the point is inside the rectangle.    
    
    return (px>=x1 && px<x2 && py>=y1 && py<y2);
}

GMREAL rectangle_in_rectangle(double ax1, double ay1, double ax2, double ay2, double bx1, double by1, double bx2, double by2) {
    ///rectangle_in_rectangle(ax1,ay1,ax2,ay2,bx1,by1,bx2,by2)
    //ax1,ay1,ax2,ay2: first rectangle to check
    //bx1,by1,bx2,by2: second rectangle to check
    //returns: 1 if the rectangles totally overlap, 2 if they partially overlap, 0 otherwise
    
    if (ax1>=bx1 && ax2<=bx2 && ay1>=by1 && ay2<=by2) return 1;
    if (ax1>bx2 || ax2<bx1 || ay1>by2 || ay2<by1) return 0;
    return 2;
}

GMREAL point_in_triangle(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
    ///point_in_triangle(px,py,x1,y1,x2,y2,x3,y3)
    //px,py: point to check
    //x1,y1,x2,y2,x3,y3: triangle to check
    //returns: whether the point is inside the triangle.
    
    double a, b, c;
    a = (x1-x0)*(y2-y0)-(x2-x0)*(y1-y0);
    b = (x2-x0)*(y3-y0)-(x3-x0)*(y2-y0);
    c = (x3-x0)*(y1-y0)-(x1-x0)*(y3-y0);
    return (signnum_c(a) == signnum_c(b) && signnum_c(b) == signnum_c(c))?1.0:0.0;
}

GMREAL in_range(double val, double vmin, double vmax) {
    ///in_range(val,min,max)
    //val: value to check
    //min,max: range
    //returns: whether the value is inside the range.
    
    return (val>=vmin && val<=vmax)?1.0:0.0;
}

GMREAL point_line_lerp(double px, double py, double x1, double y1, double x2, double y2, double segment) {
    ///point_line_lerp(px,py,x1,y1,x2,y2,segment)
    //px,py: point to measure
    //x1,y1,x2,y2: line segment
    //segment: whether to limit the point to the segment
    //returns: the projected value from the given point to the given line.
    //GMLscripts.com/license
    
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
    ///point_line_distance(px,py,x1,y1,x2,y2,segment)
    //px,py: point to measure
    //x1,y1,x2,y2: line segment
    //segment: whether to limit the line to the segment
    //returns: distance from the point to the line segment.
    
    double t=point_line_lerp(px,py,x1,y1,x2,y2,segment);
    double xs = x1 + t * (x2-x1);
    double ys = y1 + t * (y2-y1);

    return pointdis(xs, ys, px, py);
}

GMREAL dot_product_3d_normalized(double x1, double y1, double z1, double x2, double y2, double z2) {
    ///dot_product_3d_normalized(x1,y1,z1,x2,y2,z2)
    //x1,y1,z1: first vector
    //x2,y2,z2: second vector
    //returns: normalized dot product of two 3d vectors.
    
    double a=pointdis3d(0,0,0,x1,y1,z1);
    double b=pointdis3d(0,0,0,x2,y2,z2);
    
    if (a*b==0) return 1;

    return dot3d(x1/a,y1/a,z1/a,x2/b,y2/b,z2/b);
}

GMREAL dot_product_normalized(double x1, double y1, double x2, double y2) {
    ///dot_product_normalized(x1,y1,x2,y2)
    //x1,y1: first vector
    //x2,y2: second vector
    //returns: normalized dot product of two vectors.
    
    double a=pointdis(0,0,x1,y1);
    double b=pointdis(0,0,x2,y2);
    
    if (a*b==0) return 1;

    return dot(x1/a,y1/a,x2/b,y2/b);
}

GMREAL angle_difference_3d(double x1, double y1, double z1, double x2, double y2, double z2) {
    ///angle_difference_3d(x1,y1,z1,x2,y2,z2)
    //x1,y1,z1: first vector
    //x2,y2,z2: second vector
    //returns: difference in degrees between the two vectors.
    
    return darccos(dot_product_3d_normalized(x1,y1,z1,x2,y2,z2));
}

GMREAL box_distance(double length, double angle) {
    return dsecant(45-abs(45-fmod(angle,90)))*length;
}

GMREAL angle_abs(double angle) {
    return abs(modwrap(angle+540.0,0.0,360.0)-180.0);
}