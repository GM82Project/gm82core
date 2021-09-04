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
    draw_set_color($ffffff)


#define __gm82core_update
    var tmp,i;
    
    __gm82core_hasfocus=(__gm82core_getfore()==window_handle())
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


#define draw_enable_alphablend
YoYo_EnableAlphaBlend(argument0)


#define window_resize_buffer
//window_resize_buffer(w,h)
//this function uses an offset specific to 8.1.141 so we need to check first
//thanks chernov <3
if (execute_string("return get_function_address('display_get_orientation')") <= 0) {
    //THANKS FLOOGLE <3 <3 <3 <3
    __gm82core_resizebuffer(argument0,argument1)
    return 1
}

show_error("We're sorry, but the gm82core function 'window_resize_buffer()' needs GM 8.1.141.",0)
return 0


#define string_number
    var p,m,str;
    if (string_pos("-",argument0)) m="-"
    else m=""
    p=string_pos(".",argument0)
    if (p) {
        str=string_digits(string_copy(argument0,1,p-1))+"."+string_digits(string_delete(argument0,1,p))
    } else str=string_digits(argument0)
    while (string_char_at(str,1)=="0") str=string_delete(str,1,1)
    if (str="") return "0"
    return m+str


#define string_better
    ///string_better(real):string
    // string(1.012562536) = "1.01"
    // string_better(1.012562536) = "1.01256254"
    var s;

    s=string_format(argument0,0,8)+";"
    repeat (8) s=string_replace(s,"0;",";")
    return string_replace(string_replace(s,".;",""),";","")


#define draw_make_opaque
    draw_set_blend_mode(bm_add)
    draw_rectangle_color(-9999999,-9999999,9999999,9999999,0,0,0,0,0)
    draw_set_blend_mode(0)


#define surface_engage
///surface_engage(id,width,height)
    var s;
    if (surface_exists(argument0)) {
        surface_set_target(argument0)
        return argument0
    } else {
        s=surface_create(argument1,argument2)
        surface_set_target(s)
        return s
    }


#define surface_disengage
    surface_reset_target()//internal_call_real0(6298932)
    d3d_reset_projection()


#define base64_encode
/// base64_encode(str)
//
//  Returns a string of base64 digits (RFC 3548), 6 bits each.
//
//      str         raw bytes, 8 bits each, string
//
/// GMLscripts.com/license
{
    var str, len, pad, tab, b64, i, bin;
    str = argument0;
    len = string_length(str);
    pad = "=";
    tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    b64 = "";
    for (i=0; i<len; i+=3) {
        bin[0] = ord(string_char_at(str,i+1));
        bin[1] = ord(string_char_at(str,i+2));
        bin[2] = ord(string_char_at(str,i+3));
        b64 += string_char_at(tab,1+(bin[0]>>2));
        b64 += string_char_at(tab,1+(((bin[0]&3)<<4)|(bin[1]>>4)));
        if (i+1 >= len) b64 += pad;
        else b64 += string_char_at(tab,1+(((bin[1]&15)<<2)|(bin[2]>>6)));
        if (i+2 >= len) b64 += pad;
        else b64 += string_char_at(tab,1+(bin[2]&63));
    }
    return b64;
}

#define base64_decode
/// base64_decode(b64)
//
//  Returns a string of raw bytes, 8 bits each. b64 strings with 
//  characters outside of the RFC 3548 standard or with excess
//  padding characters at the end will not decode correctly.
//
//      b64         base64 digits (RFC 3548), 6 bits each, string
//
/// GMLscripts.com/license
{
    var b64, len, pad, tab, str, i, bin;
    b64 = argument0;
    len = string_length(b64);
    pad = "=";
    tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    str = "";
    while (string_length(b64) mod 4) b64 += pad;
    for(i=0; i<len; i+=4) {
        bin[0] = string_pos(string_char_at(b64,i+1),tab)-1;
        bin[1] = string_pos(string_char_at(b64,i+2),tab)-1;
        bin[2] = string_pos(string_char_at(b64,i+3),tab)-1;
        bin[3] = string_pos(string_char_at(b64,i+4),tab)-1;
        str += chr(255&(bin[0]<<2)|(bin[1]>>4));
        if (bin[2] >= 0) str += chr(255&(bin[1]<<4)|(bin[2]>>2));
        if (bin[3] >= 0) str += chr(255&(bin[2]<<6)|(bin[3]));
    }
    return str;
}


#define d3d_reset_projection
    if (view_enabled)
        d3d_set_projection_ortho(view_xview[view_current],view_yview[view_current],view_wview[view_current],view_hview[view_current],view_angle[view_current])
    else
        d3d_set_projection_ortho(0,0,room_width,room_height,0)


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


#define event_step
    event_perform(ev_step, ev_step_normal)


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


#define gauss
    ///gauss(range)
    var i;
    i=0
    repeat (12) i+=random(1)
    return ((i-6)/6+0.5)*argument0


#define file_text_read_all
    var f,str;
    
    if (file_exists(argument0)) {
        str=""
        f=file_text_open_read(argument0)
        do {
            str+=file_text_read_string(f)+chr(13)+chr(10)
            file_text_readln(f)
        } until (file_text_eof(f))        
        file_text_close(f)
        return str
    }
    return noone


#define registry_read_dword
    var ret;
    ret=__registry_read_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0))
    if (argument_count==2) {
        if (ret==noone) return argument[1]        
    }
    return ret


#define registry_write_dword
    return __registry_write_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0),real(argument1)&$ffffffff)


#define merge_color_corrected
///merge_color_corrected(col1,col2,factor)
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


#define color_get_luminance
///color_get_luminance(color)
//kodak human luminance perception factors

return (color_get_red(argument0)*0.2126+color_get_green(argument0)*0.7152+color_get_blue(argument0)*0.0722)


#define instance_destroy_id
    with (argument0) instance_destroy()


#define strong
    var __i,__str;
    
    __str=""
    for (__i=0;__i<argument_count;__i+=1) __str+=string(argument[__i])
    return __str


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


#define pick
    return argument[(argument0 mod (argument_count-1))+1]


#define alarm_get
    return alarm[argument0]


#define alarm_set
    alarm[argument0]=argument1


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
    var x1,y1,x2,y2,a,b;
                
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


#define ds_map_get
    ///ds_map_get(map,key)

    if (ds_map_exists(argument0,argument1)) return ds_map_find_value(argument0,argument1,argument2)
    return undefined


#define string_pad
    ///string_pad(number,digits)
    return string_repeat("-",argument0<0)+string_replace_all(string_format(abs(argument0),argument1,0)," ","0")


#define get_timer
    return (date_current_time()*1000)/__gm82core_second


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
    return __gm82core_object.__gm82core_hasfocus


#define window_minimize
    var owo;
    owo=string(game_id)+string(irandom(1000000))
    set_application_title(owo)
    __gm82core_min(owo)
    set_application_title(room_caption)

    
#define window_set_exclusive_fullscreen
///window_set_exclusive_fullscreen(enabled)
    with (__gm82core_object) {
        if (argument0 ^ window_get_fullscreen()) {
            if (window_get_fullscreen()) {
                __gm82core_setfullscreen(0)
                window_set_fullscreen(0)
                return 1
            } else {
                window_set_fullscreen(1)
                __gm82core_setfullscreen(display_get_frequency())
                return 1
            }
        }
    }
    
    return 0


#define mouse_check_direct
    switch (argument0) {
        case mb_left  : return keyboard_check_direct(1)
        case mb_right : return keyboard_check_direct(2)
        case mb_middle: return keyboard_check_direct(4)
        default: return 0
    }


#define mouse_back_button
    if (__gm82core_object.__gm82core_hasfocus) return keyboard_check_direct(5)
    return 0

    
#define mouse_forward_button
    if (__gm82core_object.__gm82core_hasfocus) return keyboard_check_direct(6)
    return 0


#define d3d_set_projection_simple
///d3d_set_projection_simple(x,y,w,h,angle,dollyzoom,depthmin,depth,depthmax)
    var xfrom,yfrom,zfrom;

    if (argument5<=0) {
        // ¯\_(º_o)_/¯
        d3d_set_projection_ortho(argument0,argument1,argument2,argument3,argument4)
    } else {
        xfrom=argument0+argument2/2
        yfrom=argument1+argument3/2    
        zfrom=min(-tan(degtorad(90*(1-argument5)))*argument3/2,argument6-argument7)

        d3d_set_projection_ext(
            xfrom,yfrom,zfrom+argument7,                               //from
            xfrom,yfrom,argument7,                                     //to
            lengthdir_x(1,-argument4+90),lengthdir_y(1,-argument4+90),0, //up
            -point_direction(zfrom,0,0,argument3/2)*2,                 //angle
            -argument2/argument3,                                      //aspect
            max(1,argument6-argument7-zfrom),                          //znear
            argument8-argument7-zfrom                                  //zfar
        )
        d3d_start()
    }
    

#define mouse_in_window
///mouse_in_window()
    var dx,dy,wx,wy,ww,wh;

    dx=display_mouse_get_x();
    dy=display_mouse_get_y();
    wx=window_get_x();
    wy=window_get_y();
    ww=window_get_width();
    wh=window_get_height();

    return (dx >= wx && dy >= wy && dx < wx + ww && dy < wy + wh);


#define directory_previous
///directory_previous(dir)
    var fn,l;

    fn=string_replace_all(argument0,"/","\")
    l=string_length(fn)
    if (string_char_at(fn,l)=="\") fn=string_copy(fn,1,l-2)
    return filename_dir(fn)+"\"


#define is_undefined
    return string(argument0)==undefined


#define filename_remove_ext
    return string_copy(argument0,1,string_pos(".",argument0)-1)

