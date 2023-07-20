#define __gm82core_init
    if (__gm82core_dllcheck()!=820) {
        show_error('GM8.2 Core Extension failed to link DLL.',1)
        exit
    }
    
    object_event_add(__gm82core_object,ev_create,0,"__gm82core_create()")
    object_event_add(__gm82core_object,ev_step,ev_step_begin,"__gm82core_update()")
    object_event_add(__gm82core_object,ev_destroy,0,"if (!__dead) instance_copy(0)")
    object_event_add(__gm82core_object,ev_other,ev_room_end,"persistent=true")
    object_event_add(__gm82core_object,ev_other,ev_animation_end,"fps_real=1/max(0.00000001,(get_timer()-__gm82core_timer)/1000000)")
    
    //notes about alarm events:
    //any of my extensions might decide to install alarms onto the core object.
    //for this end, here's a list of currently used alarm indices:
        //alarm 0: gm82alpha window border toggle
    
    
    object_set_persistent(__gm82core_object,1)
    room_instance_add(room_first,0,0,__gm82core_object)
        
    globalvar delta_time,fps_real,fps_fast;
    globalvar __gm82core_timer,__gm82core_fpsmem,__gm82core_fps_queue;
    globalvar __gm82core_pixel;
    
    __gm82core_hrt_init()
    
    __s=surface_create(1,1)
    surface_set_target(__s)
    draw_clear($ffffff)
    surface_reset_target()
    __gm82core_pixel=sprite_create_from_surface(__s,0,0,1,1,0,0,0,0)
    surface_free(__s)
    
    delta_time=1000/60
    fps_real=60
    __gm82core_fps_queue=ds_queue_create()
    __gm82core_fpsmem=1
    __gm82core_timer=get_timer()
    
    surface_free(surface_create(8,8))
    draw_set_color($ffffff)


#define __gm82core_create
    __dead=0
    if (instance_number(__gm82core_object)>1) {
        __dead=1
        instance_destroy()
    } else if (!__gm82core_checkstart(window_handle())) {
        show_error("game_restart() is currently not supported by the GM 8.2 extensions due to potential memory leaks.",1)
    }

#define __gm82core_update
    var __tmp,__stamp;
    
    //this is to avoid getting deactivated by game logic
    x=view_xview[0]+view_wview[0]/2
    y=view_yview[0]+view_hview[0]/2
    
    __gm82core_hasfocus=__gm82core_getfore()
    __tmp=get_timer()
    delta_time=(__tmp-__gm82core_timer)/1000
    __gm82core_timer=__tmp
    
    while 1 {
        __stamp=ds_queue_head(__gm82core_fps_queue)
        if (__stamp && __tmp-__stamp>=1000000-(500000/room_speed)) {
            //why is the correction value half a frame?
            //no clue! i just don't question it at this point.
            ds_queue_dequeue(__gm82core_fps_queue)
        } else break
    }
    ds_queue_enqueue(__gm82core_fps_queue,__tmp)

    __gm82core_fpsmem=mean(__gm82core_fpsmem,ds_queue_size(__gm82core_fps_queue))
    fps_fast=round(__gm82core_fpsmem)
//
//