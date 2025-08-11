#define execute_program_async
    ///execute_program_async(cmdline)
    //cmdline: command string with arguments
    //returns: success
    
    __ret=__gm82core_execute_program_silent(argument0)
    
    if (__ret==0 || __ret==75) {
        return 0
    }
    
    return 1

#define execute_program_async_result
    ///execute_program_async_result()
    //returns: 259 if still running, otherwise program exit code
    
    return __gm82core_execute_program_silent_exitcode()


#define execute_program_silent
    ///execute_program_silent(cmdline)
    //cmdline: command string with arguments
    //returns: program exit code
    var __ret;
    
    __gm82core_execute_program_silent(argument0)
    
    do {
        io_handle()
        sleep(10)
        __ret=__gm82core_execute_program_silent_exitcode()
    } until (__ret!=259)
    
    return __ret


#define file_text_read_all
    ///file_text_read_all(filename,[line separator])
    //filename: string - file to read
    //line separator: character to use for line breaks (if any)
    //returns: file contents if successful, noone on failure
    
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


#define file_text_write_all
    ///file_text_write_all(filename,string)
    //filename: string - file to write
    //string: text to write
    //returns: success
    
    var __f;

    __f=file_text_open_write(argument0)
    if (__f) {
        file_text_write_string(__f,argument1)
        file_text_close(__f)
        return true
    }
    return false


#define font_add_file
    ///font_add_file(filename,fontname,size,bold,italic,first,last)
    //filename: string, path to font file
    //fontname: font family to add (must match contents of file)
    //size: in points
    //bold,italics: style to add
    //first,last: character range to render (1-255)
    //Adds a font from a file on disk rather than system fonts.
    
    var __font;
    __gm82core_addfonttemp(argument0)
    __font=font_add(argument1,argument2,argument3,argument4,argument5,argument6)
    __gm82core_remfonttemp(argument0)
    return __font


#define mouse_back_button
    ///mouse_back_button()
    //returns: whether the mouse's back nav button is currently pressed.
    if (__gm82core_hasfocus) {
        keyboard_check_direct(5)
        return keyboard_check_direct(5)
    }
    return 0


#define mouse_check_direct
    ///mouse_check_direct(button)
    //button: mouse button mb_ constant
    //returns: whether the button is currently pressed
    
    switch (argument0) {
        case mb_left  : {keyboard_check_direct(1) return keyboard_check_direct(1)}
        case mb_right : {keyboard_check_direct(2) return keyboard_check_direct(2)}
        case mb_middle: {keyboard_check_direct(4) return keyboard_check_direct(4)}
        default: return 0
    }


#define mouse_forward_button
    ///mouse_forward_button()
    //returns: whether the mouse's forward nav button is currently pressed.
    
    if (__gm82core_hasfocus) {
        keyboard_check_direct(6)
        return keyboard_check_direct(6)
    }
    return 0


#define mouse_in_window
    ///mouse_in_window()
    //returns: whether the mouse cursor is currently within the game window region on the screen.
    //Note: this does not check if there are any windows in front of the game. Check that separately using window_is_focused().
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
    //addr: registry key to read
    //default: value to return when the key doesn't exist
    //returns: value of existing key, or default value
    
    var __ret;
    __ret=__registry_read_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0))
    if (argument_count==2) {
        if (__ret==noone) return argument1        
    }
    return __ret


#define registry_read_sz
    ///registry_read_sz(addr,default)
    //addr: registry key to read
    //default: value to return when the key doesn't exist
    //returns: value of existing key, or default value
    
    var __ret;
    __ret=__registry_read_sz(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0))
    if (argument_count==2) {
        if (__ret=="<undefined>") return argument1        
    }
    return __ret


#define registry_write_dword
    ///registry_write_dword(addr,val)
    //addr: registry key to read
    //val: value to write
    //returns: success
    
    return __registry_write_dword(string_replace_all(filename_dir(argument0),"/","\"),filename_name(argument0),real(argument1)&$ffffffff)


#define url_open
    ///url_open(url)
    //url: website url
    //Opens an URL in the system's default browser.
    
    if (!string_pos("http://",argument0) && !string_pos("https://",argument0)) execute_shell("http://"+argument0,"")
    else execute_shell(argument0,"")


#define window_has_focus
    ///window_has_focus()
    //returns: whether the game window is currently in front and accepting input.
    
    return __gm82core_hasfocus


#define file_find_list
    ///file_find_list(directory,query,attr,recursive,excludedirs)
    //directory: path to search inside
    //query: file mask to find
    //attr: 0, or any additional file attributes you might have interest in
    //recursive: if the search should go into directories
    //excludedirs: exclude directories from adding to ds_list
    //returns: ds_list containing paths to all files found
    
    var __root,__mask,__attr,__recursive,__excludedirs,__list,__folder,__folders,__fn,__i;
    
    __root=string_replace_all(argument0,"/","\")
    __mask=argument1
    __attr=argument2
    __recursive=argument3
    __excludedirs=argument4
    
    if (!string_pos(":",__root)) __root=working_directory+"\"+__root

    __list=ds_list_create()

    if (__recursive) __attr=__attr|fa_directory

    if (string_char_at(__root,string_length(__root))=="\") __root=string_copy(__root,1,string_length(__root)-1)

    __folder[0]=__root
    __folders=1
    __i=0

    do {
        __root=__folder[__i]+"\"
        for (__file=file_find_first(__root+__mask,__attr);__file!="";__file=file_find_next()) {
            if (__file!="." && __file!="..") {
                __fn=__root+__file
                if (!__excludedirs || !file_attributes(__fn,fa_directory)) ds_list_add(__list,__fn)
                if (__recursive) if (file_attributes(__fn,fa_directory)) {
                    __folder[__folders]=__fn
                    __folders+=1
                }                 
            }
        } file_find_close()
        __i+=1
    } until (__i>=__folders)

    return __list


#define font_add_winui
    ///font_add_winui(filename)
    //filename: path to ttf or fon file
    //Temporarily loads a font for use in Windows api stuff like in message boxes.
    var __fon;__fon=string(argument0)
    
    if (!string_pos(":",__fon)) __fon=working_directory+"\"+__fon
    
    if (file_exists(__fon)) __gm82core_addfonttemp(__fon)
    else show_error("In function font_add_winui: font file '"+__fon+"' does not exist.",0)


#define get_open_filename_ext
    ///get_open_filename_ext(filter,filename,startdir)
    var __old_wdir;__old_wdir=working_directory
    set_working_directory(argument2)
    get_open_filename(argument0,argument1)
    set_working_directory(__old_wdir)


#define get_save_filename_ext
    ///get_save_filename_ext(filter,filename,startdir)
    var __old_wdir;__old_wdir=working_directory
    set_working_directory(argument2)
    get_save_filename(argument0,argument1)
    set_working_directory(__old_wdir)


#define date_is_easter
    ///date_is_easter([date])
    //returns whether the supplied date (or today) is easter
    var __C,__G,__H,__I,__J,__L,__month,__day;

    var __in_year,__in_month,__in_day;

    if (argument_count) {
        __in_year=date_get_year(argument[0])
        __in_month=date_get_month(argument[0])
        __in_day=date_get_day(argument[0])
    } else {
        __in_year=current_year
        __in_month=current_month
        __in_day=current_day
    }

    //note: I have no idea what this is doing, but it was
    //not written by AI so I trust it to be correct.
    __C=floor(__in_year/100)
    __G=__in_year mod 19
    __H=(__C-floor(__C/4)-floor((8*__C+13)/25)+19*__G+15) mod 30
    __I=__H-floor(__H/28)*(1-floor(29/(__H+1))*floor((21-__G)/11))
    __J=(__in_year+floor(__in_year/4)+__I+2-__C+floor(__C/4)) mod 7
    __L=__I-__J
    __month=3+floor((__L+40)/44)
    __day=__L+28-31*floor(__month/4)

    return (__day=__in_day && __month=__in_month) 


#define date_get_moon_phase
    ///date_get_moon_phase([date])
    //returns the current moon phase as a unit where 0.0 = new and 0.5 = full.
    var __date,__y,__m,__d,__phase;
    
    if (argument_count) __date=argument[0]
    else __date=date_current_datetime()
    
    __y=date_get_year(__date)
    __m=date_get_month(__date)
    __d=date_get_day(__date)
    
    if (__m < 3) {
        __y-=1;
        __m += 12;
    }
    __m+=1;
    
    __d += 365.25*__y; //year length in days
    __d += 30.6*__m; //month length in days
    
    __phase = __d-694039.09; //days since reference full moon
    __phase /= 29.5305882; //length of moon cycle in days
    
    return frac(__phase)


#define get_cpu_usage
    ///get_cpu_usage()
    //Returns an approximation of the amount of cpu time the game is occupying between frames.
    //The precise calculation is how much of the allotted frame time is being spent not waiting for the next frame.
    if (fps_real>0) return ceil(min(1,room_speed/fps_real)*100)
    return 100


#define extension_detect
    ///extension_detect(name)
    //Detects the presence of a gm82 extension by its name.
    //Returns noone if the extension doesn't exist, or the version if it does.
    
    var __name,__prefix;
    
    __name=string_lower(argument0)
    __prefix=""
    
    switch (__name) {
        case "alpha":
        case "angle":
        case "audio":
        case "core":
        case "drag":
        case "gltf":
        case "ui":
        case "video": break
        
        case "buffer":
        case "buf": __name="buf" break
        
        case "directx9":
        case "dx9": __name="dx9" break
        
        case "joystick":
        case "joy": __name="joy" break
        
        case "networking":
        case "network":
        case "net": __name="net" __prefix="__" break
        
        case "sound":
        case "snd": __name="snd" __prefix="__" break
        default: return noone
    }
    
    if (!variable_global_exists(__prefix+"gm82"+__name+"_version")) return noone    
    return variable_global_get(__prefix+"gm82"+__name+"_version")
//
//
