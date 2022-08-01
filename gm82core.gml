#define __gm82core_init
    if (__gm82core_dllcheck()!=820) {
        show_error('GM8.2 Core Extension failed to link DLL.',1)
        exit
    }
    
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
    __gm82core_version=144
    
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
    
    if (__dX==0) {
        if (__dY<0) {
            //straight up (we don't do anything for straight down)
            vspeed=-sqrt(__dY*-2/gravity)*gravity-gravity/2
        }
    } else {
        __ang=(arctan2(-__dY,__dX)+degtorad(90))/2
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


#define event_alarm
    ///event_alarm(numb)
    event_perform(ev_alarm,argument0)


#define animation_stop
    ///animation_stop()
    image_speed=0
    image_index=image_number-1


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
    ///dsmap(map,key,value) -> value
    ///dsmap(map,key) -> value
    ///dsmap(map) -> string
    ///dsmap() -> map
    var __key,__str,__val;
    
    if (argument_count==0) {
        return ds_map_create()
    }
        
    if (argument_count==3) {
        if (ds_map_exists(argument0,argument1))
            ds_map_replace(argument0,argument1,argument2)
        else
            ds_map_add(argument0,argument1,argument2)        
        return argument2
    }
    
    if (argument_count==2) {
        //floogle found out this is faster if the key exists
        __key=ds_map_find_value(argument0,argument1)
        if (is_real(__key)) if (__key==0) if (!ds_map_exists(argument0,argument1)) return undefined
        return __key
    }
    
    if (argument_count==1) {
        __str=""
        __key=ds_map_find_first(argument0)
        repeat (ds_map_size(argument0)) {
            __val=ds_map_find_value(argument0,__key)
            if (is_string(__val)) __str+=string_better(__key)+": "+chr(34)+__val+chr(34)+chr(13)+chr(10)
            else __str+=string_better(__key)+": "+string_better(__val)+chr(13)+chr(10)
            __key=ds_map_find_next(argument0,__key)
        }
        return __str
    }


#define dslist
    ///dslist(list,pos,val) -> value
    ///dslist(list,pos) -> value
    ///dslist(list) -> string
    ///dslist() -> list
    var i,s,str;
    
    if (argument_count==0) {
        return ds_list_create()
    }
    
    s=ds_list_size(argument0)
        
    if (argument_count==3) {
        if (argument1>=0) {             
            if (argument1-s) {
                repeat (argument1-s) ds_list_add(argument0,undefined)
                ds_list_add(argument0,argument2)             
            } else ds_list_replace(argument0,argument1,argument2)             
        } else ds_list_add(argument0,argument2)        
        return argument2
    }
    
    if (argument_count==2) {
        if (argument1>=s) return undefined
        return ds_list_find_value(argument0,argument1)
    }
    
    if (argument_count==1) {
        i=0 str=""
        repeat (s) {
            str+=string(ds_list_find_value(list,i))+chr(13)+chr(10)
            i+=1
        }
        return str
    }
    

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
    ///instance_create_moving(x,y,object,speed,direction,[gravity,[gravdir]])
    var lastinst;lastinst=instance_count
    action_create_object_motion(argument2,argument0,argument1,argument3,argument4)
    __i=instance_id[lastinst]
    if (instance_exists(__i)) {
        if (argument_count>5)
            __i.gravity=argument5
        if (argument_count>6)
            __i.gravity_direction=argument6
        return __i
    }
    return noone


#define instance_create_moving_ext
    ///instance_create_moving_ext(x,y,object,speed,direction,[addhspeed,addvspeed,[gravity,[gravdir]]])
    var lastinst,__i,__h,__v;
    
    if (argument_count<5 || argument_count==6 || argument_count>9) {
        show_error("Incorrect set of arguments for function instance_create_moving_ext().",0)
        return noone
    }
    
    lastinst=instance_count
    if (argument_count>6) {
        __h=lengthdir_x(argument3,argument4)+argument5
        __v=lengthdir_y(argument3,argument4)+argument6        
        action_create_object_motion(
            argument2, //obj
            argument0,argument1, //x,y
            point_distance(0,0,__h,__v),point_direction(0,0,__h,__v) //speed,direction
        )
    } else action_create_object_motion(argument2,argument0,argument1,argument3,argument4)
    
    __i=instance_id[lastinst]
    if (instance_exists(__i)) {
        if (argument_count>7)
            __i.gravity=argument7
        if (argument_count>8)
            __i.gravity_direction=argument8
        return __i
    }
    return noone


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


#define draw_self_as
    ///draw_self_as(sprite,[image])
    var __img;__img=-1
    if (argument_count>1) __img=floor(argument1)
    draw_sprite_ext(argument0,__img,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha)


#define tile_find_anywhere
    ///tile_find_anywhere(x,y)
    var t;
    t=tile_find(argument0,argument1,0)
    if (t) return t
    return tile_find(argument0,argument1,1)


#define draw_background_tiled_extra
    ///draw_background_tiled_extra(back,x,y,xscale,yscale,angle,color,alpha,hrepeats,vrepeats)

    var bg,dx,dy,xs,ys,angle,color,alpha,hrep,vrep;

    bg=argument0
    dx=argument1 dy=argument2
    xs=argument3 ys=argument4
    angle=modwrap(argument5,0,360)
    color=argument6 alpha=argument7
    hrep=argument8 vrep=argument9

    var tex,w,h,u,v,angadd,length;

    tex=background_get_texture(bg)
    w=background_get_width(bg)*xs
    h=background_get_height(bg)*ys

    texture_set_repeat(1)
    draw_primitive_begin_texture(pr_trianglestrip,tex)    
            
    if (hrep>0 && vrep>0) {
        if (xs=0 || ys=0) exit
        u=dx v=dy
        draw_vertex_texture_color(u-0.5,v-0.5,0,0,color,alpha)
        u=dx+dcos(angle)*w*hrep v=dy-dsin(angle)*w*hrep
        draw_vertex_texture_color(u-0.5,v-0.5,hrep,0,color,alpha)
        u=dx+dcos(angle-90)*h*vrep v=dy-dsin(angle-90)*h*vrep
        draw_vertex_texture_color(u-0.5,v-0.5,0,vrep,color,alpha)
        u=dx+pivot_pos_x(w*hrep,h*vrep,angle) v=dy+pivot_pos_y(w*hrep,h*vrep,angle)
        draw_vertex_texture_color(u-0.5,v-0.5,hrep,vrep,color,alpha)        
    } else if (hrep>0 || vrep>0) {
        if (xs=0 || ys=0) exit //zero scale would produce a degenerate quad anyway
        angadd=-angle
        if (hrep>0) {
            //vertical infinity; rotate uv logic 90 degrees
            length=w*hrep angle+=90
        } else {
            //horizontal infinity
            length=h*vrep
        }
        
        if (angle<45 || angle>315 || (angle>135 && angle<225)) {
            //horizontal infinite tiler
            u=0 repeat (2) {v=dy+(dx-u)*dtan(angle) repeat (2) {
                draw_vertex_texture_color(u-0.5,v-0.5,pivot_pos_x(u-dx,v-dy,angadd)/w,pivot_pos_y(u-dx,v-dy,angadd)/h,color,alpha)
            v+=length*dsecant(angle)} u=room_width}
        } else {
            //vertical infinite tiler
            v=0 repeat (2) {u=dx+(dy-v)*dtan(90-angle) repeat (2) {
                draw_vertex_texture_color(u-0.5,v-0.5,pivot_pos_x(u-dx,v-dy,angadd)/w,pivot_pos_y(u-dx,v-dy,angadd)/h,color,alpha)
            u+=length*dsecant(90-angle)} v=room_height}
        }    
    } else {
        if (xs=0 || ys=0) {
            //infinite scale mode
            u=0 repeat (2) {v=0 repeat (2) {
                draw_vertex_texture_color(u-0.5,v-0.5,0.5,0.5,color,alpha)
            v=room_height} u=room_width}
        } else {
            //cover room mode
            u=0 repeat (2) {v=0 repeat (2) {
                draw_vertex_texture_color(u-0.5,v-0.5,pivot_pos_x(u-dx,v-dy,angle)/w,pivot_pos_y(u-dx,v-dy,angle)/h,color,alpha)
            v=room_height} u=room_width}
        }
    }

    draw_primitive_end()


#define window_set_foreground()
    __gm82core_set_foreground(window_handle())


#define font_add_file
    ///font_add_file(filename,fontname,size,bold,italic,first,last)
    var font;
    __gm82core_addfonttemp(argument0)
    font=font_add(argument1,argument2,argument3,argument4,argument5,argument6)
    __gm82core_remfonttemp(argument0)
    return font


#define event_trigger
    ///event_trigger(trig)
    event_perform(ev_trigger,argument0)


#define object_is_child_of
    ///object_is_child_of(object)
    return object_index==argument0 || object_is_ancestor(object_index,argument0)


#define object_other_is_child_of
    ///object_other_is_child_of(object)
    return other.object_index==argument0 || object_is_ancestor(other.object_index,argument0)

#define instance_destroy_other
    ///instance_destroy_other()
    with (other) instance_destroy()
//
//
