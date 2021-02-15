#define __gm82core_init
    object_event_add(__gm82core_object,ev_create,0,"
        if (instance_number(__gm82core_object)>1) instance_destroy()
        __gm82core_timer=get_timer()
        __gm82core_dtmemi=0
        __gm82core_dtmema[10]=0
    ")
    object_event_add(__gm82core_object,ev_step,ev_step_begin,"__gm82core_update()")
    object_event_add(__gm82core_object,ev_destroy,0,"if (instance_number(__gm82core_object)==1) instance_create(x,y,__gm82core_object)")
    object_set_persistent(__gm82core_object,1)
    room_instance_add(room_first,0,0,__gm82core_object)
        
    globalvar delta_time;
    globalvar fps_real;
    
    surface_free(surface_create(8,8))
    

#define __gm82core_update
    var tmp,i;
    
    tmp=get_timer()
    delta_time=tmp-__gm82core_timer
    __gm82core_timer=tmp
    
    if (delta_time!=0) {
        __gm82core_dtmema[__gm82core_dtmemi]=1000/delta_time
        __gm82core_dtmemi=(__gm82core_dtmemi+1) mod 10
        if (!__gm82core_dtmemi) {
            fps_real=0 for (i=0;i<10;i+=1) fps_real+=__gm82core_dtmema[i]/10
        }
    }


#define move_towards_gravity
///move_towards_gravity(xto,yto,gravity)
    var dX, dY, ang;
    
    if (argument2==0) {
        show_error("Calling move_towards_gravity with gravity==0.",1)
        exit
    }

    gravity=argument2
    dX=argument0-x
    dY=argument1-y
    ang=(arctan2(-dY,dX)+degtorad(90))/2
    if (ang!=pi/2) {
        speed=dX/(cos(ang)*sqrt(2*(dY+tan(ang)*dX)/gravity))
        direction=radtodeg(ang)
    }

#define cosine
///cosine(a,b,amount)
    var mu;
    mu = (1-cos(argument2*pi))/2;
     
    return (argument0*(1-mu2)+argument1*mu2)
    
#define string_hex
    var n,r;
    n=argument0
    r=""
    
    while (n) {
        r=string_char_at("0123456789ABCDEF",n mod 16+1)+r
        n=n div 16
    }
    return r


#define real_hex
    var d,r,l,i;
    r=0
    d=string_upper(argument0)
    l=string_length(d)
    
    for (i=1;i<=l;i+=1) r=r*16+(string_pos(string_char_at(d,i),"0123456789ABCDEF")-1)
    return r


#define esign
///esign(val,default)
    if (argument0=0) return argument1
    return sign(argument0)


#define gauss
    ///gauss(range)
    var i;
    i=0
    repeat (12) i+=random(1)
    return ((i-6)/6+0.5)*argument0


#define merge_color_corrected
///merge_color_corrected(col1,col2,factor)
    var r1,g1,b1,r2,g2,b2;
    r1=sqr(color_get_red  (argument0))
    g1=sqr(color_get_green(argument0))
    b1=sqr(color_get_blue (argument0))

    r2=sqr(color_get_red  (argument1))
    g2=sqr(color_get_green(argument1))
    b2=sqr(color_get_blue (argument1))

    return make_color_rgb(
        sqrt(lerp(r1,r2,argument2)),
        sqrt(lerp(g1,g2,argument2)),
        sqrt(lerp(b1,b2,argument2))
    )


#define roundto
///roundto(val,to)
    return floor(argument0/argument1)*argument1


#define inch
///inch(val,goto,stepsize)

    if (argument[0]<argument[1]) return min(argument[1],argument[0]+argument[2])
    return max(argument[1],argument[0]-argument[2])


#define instance_destroy_id
    with (argument0) instance_destroy()


#define strong
    var i,str;
    
    str=""
    for (i=0;i<argument_count;i+=1) str+=string(argument[i])
    return str


#define instance_some
    return instance_find(argument0,irandom(instance_number(argument0)-1))


#define ds_map_read_ini
///ds_map_read_ini(map,filename)
    var map,f,section,str,p;

    if (file_exists(argument1)) {
        map=argument0
        
        f=file_text_open_read(argument1)
        section=""
        do {            
            str=file_text_read_string(f)
            file_text_readln(f)
            if (str!="") {
                p=string_pos("=",str)
                if (string_pos("[",str) && string_pos("]",str) && !p)
                    section=string_replace(string_replace(str,"[",""),"]","")+" "
                else if (p) {
                    ds_map_add(map,section+string_copy(str,1,p-1),string_delete(str,1,p))
                }            
            }
        } until (file_text_eof(f))        
        file_text_close(f)
        
        return 1
    }

    return 0


#define rgb_to_bgr
    return make_color_rgb(color_get_blue(argument0),color_get_green(argument0),color_get_red(argument0))

#define wrap
    //note: benchmark vs. temp vars
    return (argument0-argument1)-floor((argument0-argument1)/(argument2-argument1))*(argument2-argument1)+argument1


#define pick
    return argument[(argument0 mod (argument_number-1))+1]


#define alarm_get
    return alarm[argument0]


#define alarm_set
    alarm[argument0]=argument1


#define angle_difference
    return ((argument0-argument1+540) mod 360)-180


#define angle_difference_3d
    ///angle_difference_3d(x1,y1,z1,x2,y2,z2)
    var x1,y1,z1,x2,y2,z2,a,b;
                
    x1=argument0
    y1=argument1
    z1=argument2
    x2=argument3
    y2=argument4
    z2=argument5

    a=point_distance_3d(0,0,0,x1,y1,z1)
    b=point_distance_3d(0,0,0,x2,y2,z2)

    if (a*b==0) return 180

    return radtodeg(arccos(median(-1,dot_product_3d(x1/a,y1/a,z1/a,x2/b,y2/b,z2/b),1)))


#define triangle_is_clockwise
    /*
    **  Usage:
    **      clockwise = is_clockwise(x0, y0, x1, y1, x2, y2);
    **
    **  Description:
    **      Given a sequence of three 2D points, return whether or not
    **      the sequence is in clockwise or counter-clockwise order.
    **
    **  Arguments:
    **      x0, y0    coordinate pair for the first point
    **      x1, y1    coordinate pair for the second point
    **      x2, y2    coordinate pair for the third point
    **
    **  Returns:
    **      TRUE if the points are in clockwise order,
    **      FALSE if the points are in counter-clockwize order,
    **      or (-1) if there is no solution.
    **
    **  copyright (c) 2006, John Leffingwell
    **  www.planetxot.com
    */
    var x0, y0, x1, y1, x2, y2, m, b, clockwise;
    x0 = argument0;
    y0 = argument1;
    x1 = argument2;
    y1 = argument3;
    x2 = argument4;
    y2 = argument5;
    clockwise = -1;
    if ((x0 != x1) || (y0 != y1)) {
        if (x0 == x1) {
            clockwise = (x2 < x1) xor (y0 > y1);
        }else{
            m = (y0 - y1) / (x0 - x1);
            b = y0 - m * x0;
            clockwise = (y2 > (m * x2 + b)) xor (x0 > x1);
        }
    }
    return clockwise;
    
    
#define darccos
    return arccos(degtorad(argument0))


#define darcsin
    return arcsin(degtorad(argument0))


#define darctan
    return arctan(degtorad(argument0))


#define dcos
    return cos(degtorad(argument0))


#define dot_product_3d_normalised
    ///dot_product_3d_normalised(x1,y1,z1,x2,y2,z2)
    var x1,y1,z1,x2,y2,z2,a,b;
                
    x1=argument0
    y1=argument1
    z1=argument2
    x2=argument3
    y2=argument4
    z2=argument5

    a=point_distance_3d(0,0,0,x1,y1,z1)
    b=point_distance_3d(0,0,0,x2,y2,z2)

    return dot_product_3d(x1/a,y1/a,z1/a,x2/b,y2/b,z2/b)


#define dot_product_normalised
    ///dot_product(x1,y1,x2,y2)
    var x1,y1,x2,y2,z2,a,b;
                
    x1=argument0
    y1=argument1
    x2=argument2
    y2=argument3

    a=point_distance(0,0,x1,y1)
    b=point_distance(0,0,x2,y2)

    return dot_product(x1/a,y1/a,x2/b,y2/b)


#define ds_map_set
    ///ds_map_set(map,key,value)
    //convenience for existing key replacement

    if (ds_map_exists(argument0,argument1)) ds_map_replace(argument0,argument1,argument2)
    else ds_map_add(argument0,argument1,argument2)


#define dsin
    return sin(degtorad(argument0))


#define dtan
    return tan(degtorad(argument0))


#define get_timer
    return (date_current_time()*1000)/__gm82core_second


#define lengthdir_zx
    ///lengthdir_zx(len,dir,dirz)

    return lengthdir_x(lengthdir_x(argument0,argument2),argument1)


#define lengthdir_zy
    ///lengthdir_zy(len,dir,dirz)

    return lengthdir_y(lengthdir_x(argument0,argument2),argument1)


#define lengthdir_zz
    ///lengthdir_zz(len,dir,dirz)

    return lengthdir_y(argument0,argument2)

    //discard argument1
    return argument1


#define point_direction_z
    ///point_direction_z(x1,y1,z1,x2,y2,z2)
    var x1,y1,z1,x2,y2,z2;
                
    x1=argument0
    y1=argument1
    z1=argument2
    x2=argument3                  
    y2=argument4
    z2=argument5

    return point_direction(0,z1,point_distance(x1,y1,x2,y2),z2)


#define string_ord_at
    return ord(string_char_at(argument0,argument1))


#define url_open
    execute_shell(argument0,"")


#define variable_instance_exists
    with (argument0) return variable_local_exists(argument1)


#define variable_instance_get
    with (argument0) return variable_local_get(argument1)


#define variable_instance_set
    with (argument0) variable_local_set(argument1,argument2)


#define window_has_focus
    return __gm82core_getfore()==window_handle()


#define window_minimize
    set_application_title(string(game_id))
    __gm82core_min(string(game_id))
    set_application_title(room_caption)
    

#define point_in_circle
///point_in_circle(px, py, x1, y1, r);
    return (point_distance(argument0,argument1,argument2,argument3)<argument4)


#define point_in_rectangle
    ///point_in_rectangle(px,py,x1,y1,x2,y2)
    return (argument0>=argument2 && argument0<argument4 && argument1>=argument3 && argument1<argument5)


#define point_in_triangle
    /*
    **  Usage:
    **      inside = point_in_triangle(x0, y0, x1, y1, x2, y2, x3, y3);
    **
    **  Description:
    **      Determines if a given point lays within a given triangle.
    **
    **  Arguments:
    **      x0, y0    1st coordinate pair for the triangle
    **      x1, y1    2nd coordinate pair for the triangle
    **      x2, y2    3rd coordinate pair for the triangle
    **      x3, y3    Coordinate pair of the test point
    **
    **  Returns:
    **      TRUE when the test point is inside of the given triangle,
    **      or FALSE otherwise.
    **
    **  Dependencies:
    **      is_clockwise()
    **
    **  Notes:
    **      Triangle coordinates should be given in traditional
    **      counter-clockwise order.
    **
    **  copyright (c) 2006, John Leffingwell
    **  www.planetxot.com
    */
    var x0, y0, x1, y1, x2, y2, x3, y3;
    x0 = argument0;
    y0 = argument1;
    x1 = argument2;
    y1 = argument3;
    x2 = argument4;
    y2 = argument5;
    x3 = argument6;
    y3 = argument7;
    return (not triangle_is_clockwise(x0,y0,x1,y1,x3,y3) && not triangle_is_clockwise(x1,y1,x2,y2,x3,y3) && not triangle_is_clockwise(x2,y2,x0,y0,x3,y3));
