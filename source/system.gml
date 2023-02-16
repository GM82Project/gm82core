#define execute_program_async
    ///execute_program_async(cmdline)
    __ret=__gm82core_execute_program_silent(argument0)
    
    if (__ret==0) {
        show_error("Unable to execute command:"+chr($0d)+chr($0a)+chr($0d)+chr($0a)+argument0,0)
        return 0
    }
    if (__ret==75) {
        show_error("Unable to execute command:"+chr($0d)+chr($0a)+chr($0d)+chr($0a)+argument0+chr($0d)+chr($0a)+chr($0d)+chr($0a)+" Another command is already running.",0)
        return 0
    }

#define execute_program_async_result
    ///execute_program_async_result()
    return __gm82core_execute_program_silent_exitcode()


#define execute_program_silent
    ///execute_program_silent(cmdline)
    var __ret;
    
    execute_program_async(argument0)
    
    do {
        io_handle()
        sleep(10)
        __ret=__gm82core_execute_program_silent_exitcode()
    } until (__ret!=259)
    
    return __ret


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


#define font_add_file
    ///font_add_file(filename,fontname,size,bold,italic,first,last)
    var font;
    __gm82core_addfonttemp(argument0)
    font=font_add(argument1,argument2,argument3,argument4,argument5,argument6)
    __gm82core_remfonttemp(argument0)
    return font


#define mouse_back_button
    ///mouse_back_button()
    if (__gm82core_object.__gm82core_hasfocus) {
        keyboard_check_direct(5)
        return keyboard_check_direct(5)
    }
    return 0


#define mouse_check_direct
    ///mouse_check_direct()
    switch (argument0) {
        case mb_left  : {keyboard_check_direct(1) return keyboard_check_direct(1)}
        case mb_right : {keyboard_check_direct(2) return keyboard_check_direct(2)}
        case mb_middle: {keyboard_check_direct(4) return keyboard_check_direct(4)}
        default: return 0
    }


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


#define registry_read_dword
    ///registry_read_dword(addr,default)
    var __ret;
    __ret=__registry_read_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0))
    if (argument_count==2) {
        if (__ret==noone) return argument1        
    }
    return __ret


#define registry_write_dword
    ///registry_write_dword(addr,val)
    return __registry_write_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0),real(argument1)&$ffffffff)


#define url_open
    ///url_open(url)
    if (!string_pos("http://",argument0) && !string_pos("https://",argument0)) execute_shell("http://"+argument0,"")
    else execute_shell(argument0,"")
//
//