#define __gm82core_init
    object_event_add(__gm82core_object,ev_create,0,"__dead=0 if (instance_number(__gm82core_object)>1) {__dead=1 instance_destroy()} else if (!__gm82core_checkstart()) show_error('game_restart() is currently not supported by the GM 8.2 extensions due to potential memory leaks.',1)")
    object_event_add(__gm82core_object,ev_step,ev_step_begin,"__gm82core_update()")
    object_event_add(__gm82core_object,ev_destroy,0,"if (!__dead) instance_copy(0)")
    object_event_add(__gm82core_object,ev_other,ev_room_end,"persistent=true")
    object_event_add(__gm82core_object,ev_other,ev_animation_end,"fps_real=1/max(0.00000001,(get_timer()-__gm82core_timer)/1000000)")
    
    object_set_persistent(__gm82core_object,1)
    room_instance_add(room_first,0,0,__gm82core_object)
        
    globalvar delta_time,fps_real,fps_fast,windows_version;
    globalvar __gm82core_timer,__gm82core_fpsmem,__gm82core_fps_queue;
    globalvar __gm82core_version;
    
    __gm82core_hrt_init()
    
    windows_version=__gm82core_winver()
    
    delta_time=1000/30
    fps_real=1
    __gm82core_fps_queue=ds_queue_create()
    __gm82core_fpsmem=1
    __gm82core_timer=get_timer()
    __gm82core_version=140
    
    surface_free(surface_create(8,8))
    draw_set_color($ffffff)


#define __gm82core_update
    var __tmp,__stamp;
    
    __gm82core_hasfocus=(__gm82core_getfore()==window_handle())
    __tmp=get_timer()
    delta_time=(__tmp-__gm82core_timer)/1000
    __gm82core_timer=__tmp
    
    while 1 {
        __stamp=ds_queue_head(__gm82core_fps_queue)
        if (__stamp && __tmp-__stamp>=1000000-(500000/room_speed)) {
            //why is the correction value half a frame?
            //no clue! i just don't question it at this point.
            ds_queue_dequeue(__gm82core_fps_queue)
        }
        else break
    }
    ds_queue_enqueue(__gm82core_fps_queue,__tmp)

    __gm82core_fpsmem=mean(__gm82core_fpsmem,ds_queue_size(__gm82core_fps_queue))
    fps_fast=round(__gm82core_fpsmem)


#define collision_check_fast
    ///collision_check_fast(obj)
    return (distance_to_object(instance_nearest(x,y,argument0)) <= 0);


#define direction_to_object
    ///direction_to_object(obj)
    var __n;__n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_direction(x,y,__n.x,__n.y)


#define distance_to_instance
    //you've heard of elf on the shelf, now get ready for 
    ///distance_to_instance(obj)
    var __n;__n=instance_nearest(x,y,argument0)
    if (__n==noone) return -1
    return point_distance(x,y,__n.x,__n.y)


#define string_number
    ///string_number(string)
    var __p,__m,__str;
    if (string_pos("-",argument0)) __m="-"
    else __m=""
    __p=string_pos(".",argument0)
    if (__p) {
        __str=string_digits(string_copy(argument0,1,__p-1))+"."+string_digits(string_delete(argument0,1,__p))
    } else __str=string_digits(argument0)
    while (string_char_at(__str,1)=="0") __str=string_delete(__str,1,1)
    if (__str="") return __m+"0"
    return __m+__str


#define string_better
    ///string_better(real)
    // string(1.012562536) = "1.01"
    // string_better(1.012562536) = "1.01256254"
    var __s;

    __s=string_format(argument0,0,8)+";"
    repeat (8) __s=string_replace(__s,"0;",";")
    return string_replace(string_replace(__s,".;",""),";","")


#define base64_encode
    /// base64_encode(str)
    //
    //  Returns a string of base64 digits (RFC 3548), 6 bits each.
    //
    //      str         raw bytes, 8 bits each, string
    //
    /// GMLscripts.com/license
    {
        var __str, __len, __pad, __tab, __b64, __i, __bin;
        __str = argument0;
        __len = string_length(__str);
        __pad = "=";
        __tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        __b64 = "";
        for (__i=0; __i<__len; __i+=3) {
            __bin[0] = ord(string_char_at(__str,__i+1));
            __bin[1] = ord(string_char_at(__str,__i+2));
            __bin[2] = ord(string_char_at(__str,__i+3));
            __b64 += string_char_at(__tab,1+(__bin[0]>>2));
            __b64 += string_char_at(__tab,1+(((__bin[0]&3)<<4)|(__bin[1]>>4)));
            if (__i+1 >= __len) __b64 += __pad;
            else __b64 += string_char_at(__tab,1+(((__bin[1]&15)<<2)|(__bin[2]>>6)));
            if (__i+2 >= __len) __b64 += __pad;
            else __b64 += string_char_at(__tab,1+(__bin[2]&63));
        }
        return __b64;
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
        var __b64, __len, __pad, __tab, __str, __i, __bin;
        __b64 = argument0;
        __len = string_length(__b64);
        __pad = "=";
        __tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        __str = "";
        while (string_length(__b64) mod 4) __b64 += __pad;
        for(__i=0; __i<__len; __i+=4) {
            __bin[0] = string_pos(string_char_at(__b64,__i+1),__tab)-1;
            __bin[1] = string_pos(string_char_at(__b64,__i+2),__tab)-1;
            __bin[2] = string_pos(string_char_at(__b64,__i+3),__tab)-1;
            __bin[3] = string_pos(string_char_at(__b64,__i+4),__tab)-1;
            __str += ansi_char(255&(__bin[0]<<2)|(__bin[1]>>4));
            if (__bin[2] >= 0) __str += ansi_char(255&(__bin[1]<<4)|(__bin[2]>>2));
            if (__bin[3] >= 0) __str += ansi_char(255&(__bin[2]<<6)|(__bin[3]));
        }
        return __str;
    }


#define move_towards_gravity
    ///move_towards_gravity(xto,yto,gravity)
    var __dX, __dY, __ang;
    
    if (argument2==0) {
        direction=point_direction(x,y,argument0,argument1)
        speed=1
        exit
    }

    gravity=argument2
    __dX=argument0-x
    __dY=argument1-y
    __ang=(arctan2(-__dY,__dX)+degtorad(90))/2
    if (__ang!=pi/2) {
        speed=__dX/(cos(__ang)*sqrt(2*(__dY+tan(__ang)*__dX)/gravity))
        direction=radtodeg(__ang)
    }


#define event_step
    ///event_step()
    event_perform(ev_step,ev_step_normal)


#define event_endstep
    ///event_step()
    event_perform(ev_step,ev_step_end)


#define event_beginstep
    ///event_step()
    event_perform(ev_step,ev_step_begin)


#define event_draw
    ///event_draw()
    event_perform(ev_draw,0)


#define draw_self_floored
    ///draw_self_floored
    draw_sprite_ext(sprite_index,floor(image_index),floor(x),floor(y),image_xscale,image_yscale,image_angle,image_blend,image_alpha)


#define string_hex
    ///string_hex(real)
    var __n,__r;
    __n=argument0
    __r=""
    
    while (__n) {
        __r=string_char_at("0123456789ABCDEF",__n mod 16+1)+__r
        __n=__n div 16
    }
    return __r


#define real_hex
    ///real_hex(string)
    var __d,__r,__l,__i;
    __r=0
    __d=string_upper(argument0)
    __l=string_length(__d)
    
    for (__i=1;__i<=__l;__i+=1) __r=__r*16+(string_pos(string_char_at(__d,__i),"0123456789ABCDEF")-1)
    return __r


#define gauss
    ///gauss(range)
    var __i;
    __i=0
    repeat (12) __i+=random(1)
    return ((__i-6)/6+0.5)*argument0


#define file_text_read_all
    ///file_text_read_all(filename,[line separator])
    var __f,__str,__lf;
    
    if (argument_count==2) __lf=argument1
    else __lf=chr(13)+chr(10)
    
    if (file_exists(argument0)) {
        __str=""
        __f=file_text_open_read(argument0)
        while (!file_text_eof(__f)) {
            __str+=file_text_read_string(__f)+__lf
            file_text_readln(__f)
        }
        file_text_close(__f)
        return __str
    }
    return noone


#define registry_read_dword
    ///registry_read_dword(addr)
    var __ret;
    __ret=__registry_read_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0))
    if (argument_count==2) {
        if (__ret==noone) return argument[1]        
    }
    return __ret


#define registry_write_dword
    ///registry_write_dword(addr,val)
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


#define color_blend
    ///color_blend(col1,col2)
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
    
    //kodak human luminance perception factors
    return (color_get_red(argument0)*0.2126+color_get_green(argument0)*0.7152+color_get_blue(argument0)*0.0722)


#define instance_destroy_id
    ///instance_destroy_id(obj)
    with (argument0) instance_destroy()


#define strong
    ///strong(val1,val2,...)
    var __i,__str;
    
    __str=""
    for (__i=0;__i<argument_count;__i+=1) __str+=string(argument[__i])
    return __str


#define instance_some
    ///instance_some(obj)
    return instance_find(argument0,irandom(instance_number(argument0)-1))


#define ds_map_read_ini
    ///ds_map_read_ini(map,filename)
    var __map,__f,__section,__str,__p;

    if (file_exists(argument1)) {
        __map=argument0
        
        __f=file_text_open_read(argument1)
        __section=""
        while (!file_text_eof(__f)) {            
            __str=file_text_read_string(__f)
            file_text_readln(__f)
            if (__str!="") {
                __p=string_pos("=",__str)
                if (string_pos("[",__str) && string_pos("]",__str) && !__p)
                    __section=string_replace(string_replace(__str,"[",""),"]","")+" "
                else if (__p) {
                    ds_map_add(__map,__section+string_copy(__str,1,__p-1),string_delete(__str,1,__p))
                }            
            }
        }   
        file_text_close(__f)
        
        return 1
    }

    return 0


#define dsmap
    ///dsmap(map,key,[write value]) -> value
    if (argument_count==3) {
        if (ds_map_exists(argument0,argument1))
            ds_map_replace(argument0,argument1,argument2)
        else
            ds_map_add(argument0,argument1,argument2)        
        return argument2
    }

    //floogle found out this is faster if the key exists
    var v;v=ds_map_find_value(argument0,argument1)
    if (is_real(v)) if (v==0) if (!ds_map_exists(argument0,argument1)) return undefined
    return v
    

#define make_color_hsv_standard
    ///make_color_hsv_standard(hue 0-360,sat 0-100,val 0-100):color
    return make_color_hsv(argument0/360*255,argument1*2.55,argument2*2.55)


#define pick
    ///pick(which,opt1,opt2,...)
    return argument[(argument[0] mod (argument_count-1))+1]


#define alarm_get
    ///alarm_get(numb)
    return alarm[argument0]


#define alarm_set
    ///alarm_set(numb)
    alarm[argument0]=argument1


#define angle_difference_3d
    ///angle_difference_3d(x1,y1,z1,x2,y2,z2)
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


#define dot_product_3d_normalised
    ///dot_product_3d_normalised(x1,y1,z1,x2,y2,z2)
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
    var __x1,__y1,__x2,__y2,__a,__b;
                
    __x1=argument0
    __y1=argument1
    __x2=argument2
    __y2=argument3

    __a=point_distance(0,0,__x1,__y1)
    __b=point_distance(0,0,__x2,__y2)

    return dot_product(__x1/__a,__y1/__a,__x2/__b,__y2/__b)


#define ds_map_set
    ///ds_map_set(map,key,value)
    if (ds_map_exists(argument0,argument1)) ds_map_replace(argument0,argument1,argument2)
    else ds_map_add(argument0,argument1,argument2)


#define ds_map_get
    ///ds_map_get(map,key)
    if (ds_map_exists(argument0,argument1)) return ds_map_find_value(argument0,argument1)
    return undefined


#define string_pad
    ///string_pad(number,digits)
    return string_repeat("-",argument0<0)+string_replace_all(string_format(abs(argument0),argument1,0)," ","0")


#define string_ord_at
    ///string_ord_at(str,pos)
    return ord(string_char_at(argument0,argument1))


#define url_open
    ///url_open(url)
    if (!string_pos("http://",argument0) && !string_pos("https://",argument0)) execute_shell("http://"+argument0,"")
    else execute_shell(argument0,"")


#define variable_instance_exists
    ///variable_instance_exists(inst,var)
    with (argument0) return variable_local_exists(argument1)


#define variable_instance_get
    ///variable_instance_get(inst,var)
    with (argument0) return variable_local_get(argument1)


#define variable_instance_set
    ///variable_instance_set(inst,var,val)
    with (argument0) variable_local_set(argument1,argument2)


#define window_has_focus
    ///window_has_focus()
    return __gm82core_object.__gm82core_hasfocus


#define window_minimize
    ///window_minimize()
    var __owo;
    __owo=string(game_id)+string(irandom(1000000))
    set_application_title(__owo)
    __gm82core_min(__owo)
    set_application_title(room_caption)


#define mouse_check_direct
    ///mouse_check_direct()
    switch (argument0) {
        case mb_left  : {keyboard_check_direct(1) return keyboard_check_direct(1)}
        case mb_right : {keyboard_check_direct(2) return keyboard_check_direct(2)}
        case mb_middle: {keyboard_check_direct(4) return keyboard_check_direct(4)}
        default: return 0
    }


#define mouse_back_button
    ///mouse_back_button()
    if (__gm82core_object.__gm82core_hasfocus) {
        keyboard_check_direct(5)
        return keyboard_check_direct(5)
    }
    return 0

    
#define mouse_forward_button
    ///mouse_forward_button()
    if (__gm82core_object.__gm82core_hasfocus) {
        keyboard_check_direct(6)
        return keyboard_check_direct(6)
    }
    return 0


#define mouse_in_window
    ///mouse_in_window()
    var __dx,__dy,__wx,__wy,__ww,__wh;

    __dx=display_mouse_get_x()
    __dy=display_mouse_get_y()
    __wx=window_get_x()
    __wy=window_get_y()
    __ww=window_get_width()
    __wh=window_get_height()

    return (__dx>=__wx && __dy>=__wy && __dx<__wx+__ww && __dy<__wy+__wh)


#define directory_previous
    ///directory_previous(dir)
    var __fn,__l;

    __fn=string_replace_all(argument0,"/","\")
    __l=string_length(__fn)
    if (string_char_at(__fn,__l)=="\") __fn=string_copy(__fn,1,__l-2)
    return filename_dir(__fn)+"\"


#define is_undefined
    ///is_undefined(val)
    return string(argument0)==undefined


#define filename_remove_ext
    ///filename_remove_ext(fn)
    return string_copy(argument0,1,string_pos(".",argument0)-1)


#define date_get_timestamp
    ///date_get_timestamp([date])
    var __t;
    if (argument_count) __t=argument0 else __t=date_current_datetime()
    return
        string_pad(date_get_day(__t),2)+
        "/"+
        string_pad(date_get_month(__t),2)+
        "/"+
        string_pad(date_get_year(__t) mod 100,2)+
        " "+
        string_pad(date_get_hour(__t),2)+
        ":"+
        string_pad(date_get_minute(__t),2)


#define outside_room
    ///outside_room()
    //workaround for instances without a sprite
    if (bbox_right-bbox_left+bbox_bottom-bbox_top == 0)
    return x >= room_width
        || x < 0
        || y >= room_height
        || y < 0

    return bbox_left >= room_width
        || bbox_right < 0
        || bbox_top >= room_height
        || bbox_bottom < 0


#define instance_create_moving
    ///instance_create_moving(x,y,object,speed,direction)
    var lastinst;lastinst=instance_count
    action_create_object_motion(argument2,argument0,argument1,argument3,argument4)
    return instance_id[lastinst]


#define ds_list_equal
    ///ds_list_equal(list1,list2)
    var __i,__s;

    __s=ds_list_size(argument0)
    if (__s!=ds_list_size(argument1)) return false

    __i=0
    repeat (__s) {
        if (ds_list_find_value(argument0,__i)!=ds_list_find_value(argument1,__i)) return false
        __i+=1
    }

    return true


#define irandom_fresh
    ///irandom_fresh(oldval,min,max):val
    //randomizes an integer within supplied range without repeating current value

    return modwrap(argument0+1+irandom(argument2-argument1-1),argument1,argument2+1)


#define draw_sprite_ext_fixed
    ///draw_sprite_ext_fixed(sprite,image,x,y,xscale,yscale,angle,color,alpha)
    draw_sprite_ext(
        argument0,floor(argument1),
        argument2+lengthdir_x(0.5,argument6)+lengthdir_x(0.5,argument6-90),
        argument3+lengthdir_y(0.5,argument6)+lengthdir_y(0.5,argument6-90),
        argument4,argument5,argument6,argument7,argument8
    )


#define tile_find_anywhere
    var t;
    t=tile_find(argument0,argument1,0)
    if (t) return t
    return tile_find(argument0,argument1,1)
//
//
