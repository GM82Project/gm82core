#define angle_difference_3d
    ///angle_difference_3d(x1,y1,z1,x2,y2,z2)
    //x1, y1, z1: vector - angle 1
    //x2, y2, z2: vector - angle 2
    //Returns the angle difference between two 3d vectors (0-180)
    var __x1,__y1,__z1,__x2,__y2,__z2,__a,__b;
                
    __x1=argument0
    __y1=argument1
    __z1=argument2
    __x2=argument3
    __y2=argument4
    __z2=argument5

    __a=point_distance_3d(0,0,0,__x1,__y1,__z1)
    __b=point_distance_3d(0,0,0,__x2,__y2,__z2)

    if (__a*__b==0) return 180

    return radtodeg(arccos(median(-1,dot_product_3d(__x1/__a,__y1/__a,__z1/__a,__x2/__b,__y2/__b,__z2/__b),1)))


#define choose_weighted
    ///choose_weighted(val1,weight1,val2,weight2...)
    //Returns a weighted choice between each pair of arguments.
    
    //(c) YellowAfterlife
    
    var __n,__i;
    
    __n=0
    
    for (__i=1;__i<argument_count;__i+=2) {
        if (argument[__i]<=0) continue
        __n+=argument[__i]
    }

    __n=random(__n)
    for (__i=1;__i<argument_count;__i+=2) {
        if (argument[__i]<=0) continue
        __n-=argument[__i]
        if (__n<0) return argument[__i-1]
    }

    return argument[0]


#define color_blend
    ///color_blend(col1,col2)
    //col1: real - color 1
    //col2: real - color 2
    //Returns the multiplication result of the two color values.
    
    var __r1,__g1,__b1,__r2,__g2,__b2;
    
    __r1=color_get_red  (argument0)
    __g1=color_get_green(argument0)
    __b1=color_get_blue (argument0)
                                   
    __r2=color_get_red  (argument1)
    __g2=color_get_green(argument1)
    __b2=color_get_blue (argument1)

    return make_color_rgb(
        (__r1*__r2)/255,
        (__g1*__g2)/255,
        (__b1*__b2)/255
    )


#define color_get_luminance
    ///color_get_luminance(color)
    //color: real - color value
    //Returns the perceived luminance value for the color (0-255)
    
    //kodak human luminance perception factors:
    return (color_get_red(argument0)*0.2126+color_get_green(argument0)*0.7152+color_get_blue(argument0)*0.0722)


#define distance_to_path
    ///distance_to_path(x,y,path)
    //x,y: vector - point to check
    //path: path - path to check
    //Returns the approximate distance to the nearest segment of a path.
    
    var __px,__py,__path,__closed,__prec,__len,__pos,__mind,__d,__close;

    __px=argument0
    __py=argument1
    __path=argument2

    __num=path_get_number(__path)
    __len=path_get_length(__path)
    __closed=path_get_closed(__path)

    if (path_get_kind(__path)) {
        //smooth path - brute force algorithm
        __prec=1
        while (__len/__prec+__prec>__prec*2) __prec*=2
        __prec/=2
        
        __pos=0
        __close=0
        __mind=infinity
        repeat (__len/__prec+1) {
            __d=point_distance(__px,__py,path_get_x(__path,__pos),path_get_y(__path,__pos))
            if (__d<__mind) {
                __close=__pos
                __mind=__d
            }
            __pos+=__prec/__len
        }
         
        __pos=__close-(__prec/2)/__len
        if (__pos<0) __pos+=1
        repeat (__prec) {
            __d=point_distance(__px,__py,path_get_x(__path,__pos),path_get_y(__path,__pos))
            if (__d<__mind) {
                __close=__pos
                __mind=__d
            }
            __pos=(__pos+1/__len) mod 1
        }
        
        return __mind
    } else {
        //line path - optimized algorithm
        
        //find closest line segment
        __mind=infinity
        __i=0 repeat (__num-!__closed) {
            __d=point_line_distance(__px,__py,path_get_point_x(__path,__i),path_get_point_y(__path,__i),path_get_point_x(__path,(__i+1) mod __num),path_get_point_y(__path,(__i+1) mod __num),1)
            if (__d<__mind) {
                __mind=__d
            }
        __i+=1}
        
        return __mind
    }


#define dot_product_3d_normalised
    ///dot_product_3d_normalised(x1,y1,z1,x2,y2,z2)
    //x1, y1, z1: vector - angle 1
    //x2, y2, z2: vector - angle 2
    //Returns the normalized dot product between two 3d vectors.
    
    var __x1,__y1,__z1,__x2,__y2,__z2,__a,__b;
                
    __x1=argument0
    __y1=argument1
    __z1=argument2
    __x2=argument3
    __y2=argument4
    __z2=argument5

    __a=point_distance_3d(0,0,0,__x1,__y1,__z1)
    __b=point_distance_3d(0,0,0,__x2,__y2,__z2)

    return dot_product_3d(__x1/__a,__y1/__a,__z1/__a,__x2/__b,__y2/__b,__z2/__b)


#define dot_product_normalised
    ///dot_product_normalised(x1,y1,x2,y2)
    //x1, y1: vector - angle 1
    //x2, y2: vector - angle 2
    //Returns the normalized dot product between two vectors.
    
    var __x1,__y1,__x2,__y2,__a,__b;
                
    __x1=argument0
    __y1=argument1
    __x2=argument2
    __y2=argument3

    __a=point_distance(0,0,__x1,__y1)
    __b=point_distance(0,0,__x2,__y2)

    return dot_product(__x1/__a,__y1/__a,__x2/__b,__y2/__b)


#define gauss
    ///gauss(range)
    //range: real - range to randomize
    //Returns a gaussian distributed random number between 0 and range.
    
    var __i;
    __i=0
    repeat (12) __i+=random(1)
    return ((__i-6)/6+0.5)*argument0


#define gauss_range
    ///gauss_range(min,max)
    //min,max: real - range to randomize
    //Returns a gaussian distributed random number inside the range.
    
    var __i;
    __i=0
    repeat (12) __i+=random(1)
    return ((__i-6)/6+0.5)*(argument1-argument0)+argument0


#define irandom_fresh
    ///irandom_fresh(oldval,min,max):val
    //oldval: integer - old value
    //min, max: integer - range to randomize in
    //Randomizes an integer within supplied range without repeating the old value.

    return modwrap(argument0+1+irandom(argument2-argument1-1),argument1,argument2+1)


#define make_color_hsv_standard
    ///make_color_hsv_standard(hue,sat,val)
    //hue: angle - hue (0-360)
    //sat: percent - saturation (0-100)
    //val: percent - value (0-100)
    //Returns a color based on standard HSV values.
    
    return make_color_hsv(argument0/360*255,argument1*2.55,argument2*2.55)


#define merge_color_corrected
    ///merge_color_corrected(col1,col2,factor)
    //col1: color - color 1
    //col2: color - color 2
    //factor: real - amount to merge
    //Returns a more accurate color merge.
    
    var __r1,__g1,__b1,__r2,__g2,__b2;
    
    __r1=sqr(color_get_red  (argument0))
    __g1=sqr(color_get_green(argument0))
    __b1=sqr(color_get_blue (argument0))

    __r2=sqr(color_get_red  (argument1))
    __g2=sqr(color_get_green(argument1))
    __b2=sqr(color_get_blue (argument1))

    return make_color_rgb(
        sqrt(lerp(__r1,__r2,argument2)),
        sqrt(lerp(__g1,__g2,argument2)),
        sqrt(lerp(__b1,__b2,argument2))
    )


#define path_get_approximate_pos
    ///path_get_approximate_pos(x,y,path)
    //x,y: vector - position to check
    //path: path - path to check against
    //Returns an approximate path position that's closest to the point.
    
    var __px,__py,__path,__closed,__prec,__len,__pos,__mind,__d,__close;

    __px=argument0
    __py=argument1
    __path=argument2

    __num=path_get_number(__path)
    __len=path_get_length(__path)
    __closed=path_get_closed(__path)

    if (path_get_kind(__path)) {
        //smooth path - brute force algorithm
        __prec=1
        while (__len/__prec+__prec>__prec*2) __prec*=2
        __prec/=2
        
        __pos=0
        __close=0
        __mind=__infinity
        repeat (__len/__prec+1) {
            __d=point_distance(__px,__py,path_get_x(__path,__pos),path_get_y(__path,__pos))
            if (__d<__mind) {
                __close=__pos
                __mind=__d
            }
            __pos+=__prec/__len
        }
         
        __pos=__close-(__prec/2)/__len
        if (__pos<0) __pos+=1
        repeat (__prec) {
            __d=point_distance(__px,__py,path_get_x(__path,__pos),path_get_y(__path,__pos))
            if (__d<__mind) {
                __close=__pos
                __mind=__d
            }
            __pos=(__pos+1/__len) mod 1
        }
        
        if (path_get_closed(__path)) return modwrap(__close,0,1)
        return median(0,__close,1)
    } else {
        //line path - optimized algorithm
        
        //find closest line segment
        __mind=infinity
        __i=0 repeat (__num-!__closed) {
            __d=point_line_distance(__px,__py,path_get_point_x(__path,__i),path_get_point_y(__path,__i),path_get_point_x(__path,(__i+1) mod __num),path_get_point_y(__path,(__i+1) mod __num),1)
            if (__d<__mind) {
                __mind=d
                __closest=i
            }
        __i+=1}
        
        //find length leading up to it
        __pos=0
        __i=0 repeat (__closest) {
            __pos+=point_distance(path_get_point_x(__path,__i),path_get_point_y(__path,__i),path_get_point_x(__path,(__i+1) mod __num),path_get_point_y(__path,(__i+1) mod __num))
        __i+=1}
        __pos/=__len
        
        //find length within last segment
        __len=point_distance(path_get_point_x(__path,__i),path_get_point_y(__path,__i),path_get_point_x(__path,(__i+1) mod __num),path_get_point_y(__path,(__i+1) mod __num))/__len
        __pos+=point_line_lerp(__px,__py,path_get_point_x(__path,__closest),path_get_point_y(__path,__closest),path_get_point_x(__path,(__closest+1) mod __num),path_get_point_y(__path,(__closest+1) mod __num),1)*__len
        
        return __pos
    }
//
//