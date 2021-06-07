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


#define draw_enable_alphablend
YoYo_EnableAlphaBlend(argument0)


#define window_resize_buffer
//window_resize_buffer(w,h)
//this function uses an offset specific to 8.1.141 so we need to check first
//thanks chernov <3
if (execute_string("return get_function_address('display_get_orientation')") <= 0) {
    __gm82core_resizebuffer(argument0,argument1)
    return 1
}

show_error("window_resize_buffer() needs GM 8.1.141.",0)
return 0


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


#define surface_reset_target
    internal_call_real0(6298932)
    d3d_reset_projection()


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
            str+=file_text_read_string(f)
            file_text_readln(f)
        } until (file_text_eof(f))        
        file_text_close(f)
        return str
    }
    return noone


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
    return __gm82core_getfore()==window_handle()


#define window_minimize
    var owo;
    owo=string(game_id)+string(irandom(1000000))
    set_application_title(owo)
    __gm82core_min(owo)
    set_application_title(room_caption)