#define __gm82core_init
    if (__gm82core_dllcheck()!=820) {
        show_error('GM8.2 Core Extension failed to link DLL.',1)
        exit
    }
    
    object_event_add(gm82core_object,ev_create,0,"__gm82core_create()")
    object_event_add(gm82core_object,ev_step,ev_step_begin,"__gm82core_update()")
    object_event_add(gm82core_object,ev_destroy,0,"if (!__dead) instance_copy(0)")
    object_event_add(gm82core_object,ev_other,ev_room_end,"persistent=true")
    object_event_add(gm82core_object,ev_other,ev_animation_end,"__gm82core_frame_end()")
    
    //notes about alarm events:
    //any of my extensions might decide to install alarms onto the core object.
    //for this end, here's a list of currently used alarm indices:
        //alarm 0: gm82alpha window border toggle
    
    
    object_set_persistent(gm82core_object,1)
    room_instance_add(room_first,0,0,gm82core_object)
    
    //make data structures start at 1
    ds_grid_create(1,1)
    ds_list_create()
    ds_map_create()
    ds_priority_create()
    ds_queue_create()
    ds_stack_create()    
    
    globalvar gm82core_version;gm82core_version=160
    
    globalvar delta_time,fps_real,fps_fast,current_frame;
    globalvar __gm82core_timer,__gm82core_fpsmem,__gm82core_fps_queue,__gm82core_framecount;
    globalvar __gm82core_pixel,__gm82core_pixel_tex;
    globalvar __gm82core_hasfocus;
    
    globalvar __gm82core_index_sprites; __gm82core_index_sprites=noone
    globalvar __gm82core_index_sounds; __gm82core_index_sounds=noone
    globalvar __gm82core_index_backgrounds; __gm82core_index_backgrounds=noone
    globalvar __gm82core_index_paths; __gm82core_index_paths=noone
    globalvar __gm82core_index_fonts; __gm82core_index_fonts=noone
    globalvar __gm82core_index_timelines; __gm82core_index_timelines=noone
    globalvar __gm82core_index_objects; __gm82core_index_objects=noone
    globalvar __gm82core_index_rooms; __gm82core_index_rooms=noone
    
    globalvar __gm82core_compiler_index;
    globalvar __gm82core_compiler_exists;
    globalvar __gm82core_compiler_argc;
    globalvar __gm82core_compiler_args;
    globalvar __gm82core_compiler_return;
    
    globalvar __gm82core_bigchoose_options;
    globalvar __gm82core_bigchoose_weights;
    globalvar __gm82core_bigchoose_optioncount;
    globalvar __gm82core_bigchoose_weightsum;
    globalvar __gm82core_bigchoose_is_weighted;
    globalvar __gm82core_bigchoose_is_stale;
    
    __gm82core_hrt_init()
    
    globalvar __gm82core_keynames;
    
    var __i;__i=0 repeat (256) {__gm82core_keynames[__i]="Key "+string(__i) __i+=1}

    __gm82core_keynames[$08]="Backspace"
    __gm82core_keynames[$09]="Tab"
    __gm82core_keynames[$0c]="Clear"
    __gm82core_keynames[$0d]="Enter"
    __gm82core_keynames[$10]="Shift"
    __gm82core_keynames[$11]="Ctrl"
    __gm82core_keynames[$12]="Alt"
    __gm82core_keynames[$13]="Pause"
    __gm82core_keynames[$14]="Caps Lock"
    __gm82core_keynames[$1b]="Escape"
    __gm82core_keynames[$20]="Space"
    __gm82core_keynames[$21]="Page Up"
    __gm82core_keynames[$22]="Page Down"
    __gm82core_keynames[$23]="End"
    __gm82core_keynames[$24]="Home"

    __gm82core_keynames[$25]="Left"
    __gm82core_keynames[$26]="Up"
    __gm82core_keynames[$27]="Right"
    __gm82core_keynames[$28]="Down"

    __gm82core_keynames[$29]="Select"
    __gm82core_keynames[$2a]="Print"
    __gm82core_keynames[$2b]="Execute"
    __gm82core_keynames[$2c]="Print Screen"
    __gm82core_keynames[$2d]="Insert"
    __gm82core_keynames[$2e]="Delete"
    __gm82core_keynames[$2f]="Help"

    __gm82core_keynames[$30]="0"
    __gm82core_keynames[$31]="1"
    __gm82core_keynames[$32]="2"
    __gm82core_keynames[$33]="3"
    __gm82core_keynames[$34]="4"
    __gm82core_keynames[$35]="5"
    __gm82core_keynames[$36]="6"
    __gm82core_keynames[$37]="7"
    __gm82core_keynames[$38]="8"
    __gm82core_keynames[$39]="9"

    __gm82core_keynames[$41]="A"
    __gm82core_keynames[$42]="B"
    __gm82core_keynames[$43]="C"
    __gm82core_keynames[$44]="D"
    __gm82core_keynames[$45]="E"
    __gm82core_keynames[$46]="F"
    __gm82core_keynames[$47]="G"
    __gm82core_keynames[$48]="H"
    __gm82core_keynames[$49]="I"
    __gm82core_keynames[$4a]="J"
    __gm82core_keynames[$4b]="K"
    __gm82core_keynames[$4c]="L"
    __gm82core_keynames[$4d]="M"
    __gm82core_keynames[$4e]="N"
    __gm82core_keynames[$4f]="O"
    __gm82core_keynames[$50]="P"
    __gm82core_keynames[$51]="Q"
    __gm82core_keynames[$52]="R"
    __gm82core_keynames[$53]="S"
    __gm82core_keynames[$54]="T"
    __gm82core_keynames[$55]="U"
    __gm82core_keynames[$56]="V"
    __gm82core_keynames[$57]="W"
    __gm82core_keynames[$58]="X"
    __gm82core_keynames[$59]="Y"
    __gm82core_keynames[$5a]="Z"

    __gm82core_keynames[$5b]="Left Windows"
    __gm82core_keynames[$5c]="Right Windows"
    __gm82core_keynames[$5d]="Applications"

    __gm82core_keynames[$5f]="Sleep"

    __gm82core_keynames[$60]="Numpad 0"
    __gm82core_keynames[$61]="Numpad 1"
    __gm82core_keynames[$62]="Numpad 2"
    __gm82core_keynames[$63]="Numpad 3"
    __gm82core_keynames[$64]="Numpad 4"
    __gm82core_keynames[$65]="Numpad 5"
    __gm82core_keynames[$66]="Numpad 6"
    __gm82core_keynames[$67]="Numpad 7"
    __gm82core_keynames[$68]="Numpad 8"
    __gm82core_keynames[$69]="Numpad 9"

    __gm82core_keynames[$6a]="Numpad Multiply"
    __gm82core_keynames[$6b]="Numpad Add"
    __gm82core_keynames[$6c]="Numpad Separator"
    __gm82core_keynames[$6d]="Numpad Subtract"
    __gm82core_keynames[$6e]="Numpad Decimal"
    __gm82core_keynames[$6f]="Numpad Divide"

    __gm82core_keynames[$70]="F1"
    __gm82core_keynames[$71]="F2"
    __gm82core_keynames[$72]="F3"
    __gm82core_keynames[$73]="F4"
    __gm82core_keynames[$74]="F5"
    __gm82core_keynames[$75]="F6"
    __gm82core_keynames[$76]="F7"
    __gm82core_keynames[$77]="F8"
    __gm82core_keynames[$78]="F9"
    __gm82core_keynames[$79]="F10"
    __gm82core_keynames[$7a]="F11"
    __gm82core_keynames[$7b]="F12"
    __gm82core_keynames[$7c]="F13"
    __gm82core_keynames[$7d]="F14"
    __gm82core_keynames[$7e]="F15"
    __gm82core_keynames[$7f]="F16"
    __gm82core_keynames[$80]="F17"
    __gm82core_keynames[$81]="F18"
    __gm82core_keynames[$82]="F19"
    __gm82core_keynames[$83]="F20"
    __gm82core_keynames[$84]="F21"
    __gm82core_keynames[$85]="F22"
    __gm82core_keynames[$86]="F23"
    __gm82core_keynames[$87]="F24"

    __gm82core_keynames[$90]="Num Lock"
    __gm82core_keynames[$91]="Scroll Lock"

    __gm82core_keynames[$a0]="Left Shift"
    __gm82core_keynames[$a1]="Right Shift"
    __gm82core_keynames[$a2]="Left Ctrl"
    __gm82core_keynames[$a3]="Right Ctrl"
    __gm82core_keynames[$a4]="Left Alt"
    __gm82core_keynames[$a5]="Right Alt"

    __gm82core_keynames[$a6]="Browser Back"
    __gm82core_keynames[$a7]="Browser Forward"
    __gm82core_keynames[$a8]="Browser Refresh"
    __gm82core_keynames[$a9]="Browser Stop"
    __gm82core_keynames[$aa]="Browser Search"
    __gm82core_keynames[$ab]="Browser Favorites"
    __gm82core_keynames[$ac]="Browser Home"

    __gm82core_keynames[$ad]="Volume Mute"
    __gm82core_keynames[$ae]="Volume Down"
    __gm82core_keynames[$af]="Volume Up"

    __gm82core_keynames[$b0]="Media Next"
    __gm82core_keynames[$b1]="Media Previous"
    __gm82core_keynames[$b2]="Media Stop"
    __gm82core_keynames[$b3]="Media Pause"

    __gm82core_keynames[$b4]="Mail"
    __gm82core_keynames[$b5]="Media"
    __gm82core_keynames[$b6]="Application 1"
    __gm82core_keynames[$b7]="Application 2"

    __gm82core_keynames[$ba]="OEM 1"
    __gm82core_keynames[$bb]="Equals"
    __gm82core_keynames[$bc]="Comma"
    __gm82core_keynames[$bd]="Dash"
    __gm82core_keynames[$be]="Period"
    __gm82core_keynames[$bf]="OEM 2"
    __gm82core_keynames[$c0]="OEM 3"
    __gm82core_keynames[$c1]="Slash"
    __gm82core_keynames[$c2]="Numpad Separator"
    __gm82core_keynames[$db]="OEM 4"
    __gm82core_keynames[$dc]="OEM 5"
    __gm82core_keynames[$dd]="OEM 6"
    __gm82core_keynames[$de]="OEM 7"
    __gm82core_keynames[$df]="OEM 8"
    __gm82core_keynames[$e2]="OEM 102"

    __gm82core_keynames[$f6]="Attn"
    __gm82core_keynames[$f7]="CrSel"
    __gm82core_keynames[$f8]="ExSel"
    __gm82core_keynames[$f9]="Erase EOF"
    __gm82core_keynames[$fa]="Play"
    __gm82core_keynames[$fb]="Zoom"

    __gm82core_keynames[$fd]="PA1"
    __gm82core_keynames[$fe]="Clear"
    __gm82core_keynames[$ff]="Break"
    
    __s=surface_create(1,1)
    surface_set_target(__s)
    draw_clear($ffffff)
    surface_reset_target()
    __gm82core_pixel=sprite_create_from_surface(__s,0,0,1,1,0,0,0,0)
    __gm82core_pixel_tex=sprite_get_texture(__gm82core_pixel,0)
    surface_free(__s)

    message_button(sprite_add_sprite(temp_directory+"\gm82\msgbut_core.gmspr"))
    message_background(background_create_color(1,1,$404040))
    message_text_font("Courier New",12,$ffffff,1)
    message_button_font("Courier New",12,$ffffff,1)
    message_input_font("Courier New",12,$ffffff,1)
    message_mouse_color($ffffff)
    message_caption(1,"Message")
    message_size(500,-1)
    
    delta_time=1000/60
    fps_real=60
    __gm82core_fps_queue=ds_queue_create()
    __gm82core_fpsmem=1
    __gm82core_timer=get_timer()
        
    draw_set_color($ffffff)


#define __gm82core_create
    __dead=0
    if (instance_number(gm82core_object)>1) {
        __dead=1
        instance_destroy()
    } else if (!__gm82core_checkstart(window_handle())) {
        __gm82core_restart()
    }


#define __gm82core_update
    var __tmp,__stamp;
    
    //this is to avoid getting deactivated by game logic
    x=view_xview[0]+view_wview[0]/2
    y=view_yview[0]+view_hview[0]/2
    
    __gm82core_hasfocus=__gm82core_getfore()
    __tmp=get_timer()
    delta_time=(__tmp-__gm82core_timer)
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


#define __gm82core_frame_end
    fps_real=1/max(0.00000001,(get_timer()-__gm82core_timer)/1000000)
    __gm82core_framecount+=1
    current_frame=__gm82core_framecount
    

#define __gm82core_restart
    show_error("game_restart() is currently not supported by the GM 8.2 extensions due to potential memory leaks.",1)
//
//
