#define code_compile
    ///code_compile(string)
    //string: code to compile
    //returns: code index, or noone if compilation failed
    //This function will compile a string of code and return its id for use with code_execute().
    //Compilation takes a while, but execution is as fast as native game code.
    //If compilation fails, check error_last for the error string.
    var __code,__header,__i,__argc,__starter,__ender,__substr,__newstr,__j;

    __code=argument0

    __argc=0
    repeat (16) {
        if (!string_pos("argument"+string(__argc),__code)) break
    __argc+=1}

    if (__argc==0) {
        if (string_pos("argument[",__code)) __argc=-1
    }

    __gm82core_compiler_argc[__gm82core_compiler_index]=__argc

    __header=""
    if (__argc==-1) {
        //variable args
        __i=0 repeat (16) {
            __header+="argument["+string(__i)+"]=__gm82core_compiler_args["+string(__i)+"];"
        __i+=1}
    } else {
        //fixed args
        __i=0 repeat (__argc) {
            __header+="argument"+string(__i)+"=__gm82core_compiler_args["+string(__i)+"];"
        __i+=1}
    }

    //replace return calls with custom global
    //but protect names that end in "return"
    __substr = "return"
    __newstr = "for ({};true;exit) __gm82core_compiler_return="
    if (string_pos(__substr,__code)==1) {
        __code=string_replace(__code,__substr,__newstr)
    } else if (string_pos(__substr,__code)!=0) {
        __j=1 repeat (4) {
            __ender=string_char_at(" (+-",__j)//length 4
            __i=1 repeat (9) {
                __starter=string_char_at(match_whitespace+"{}();",__i)//length 9
                __code=string_replace_all(__code,__starter+__substr+__ender,__starter+__newstr+__ender)
            __i+=1}
        __j+=1}
    }

    //replace argument_count with custom global
    //unrelated names which include "argument_count" are not supported
    __code=string_replace_all(__code,"argument_count","__gm82core_compiler_argc_cur")

    //try...
    var __err,__ret;

    __err=error_is_enabled()
    if (__err) error_set_enabled(false)
    error_last=""
    object_event_add(__gm82core_compiler,ev_other,__gm82core_compiler_index,__header+__code)
    __ret=error_occurred
    error_occurred=false
    if (__err) error_set_enabled(true)

    //catch
    if (__ret) return noone

    __gm82core_compiler_exists[__gm82core_compiler_index]=true

    __gm82core_compiler_index+=1
    return __gm82core_compiler_index-1


#define code_return
    //deprecated
    __gm82core_compiler_return=argument0


#define code_destroy
    ///code_destroy(code)
    //code: code index to destroy
    //Destroys a piece of compiled code and frees memory.
    var __code;

    __code=argument0

    if (__code<0 || __code>=__gm82core_compiler_index) {
        show_error("In function code_destroy: Cannot destroy code point "+string(__code)+", only "+string(__gm82core_compiler_index)+" total code points initialized.",0)
        exit
    }

    if (__gm82core_compiler_exists[__code]) {
        object_event_clear(__gm82core_compiler,ev_other,__code)
        __gm82core_compiler_exists[__code]=false
    } else {
        show_error("In function code_destroy: Cannot destroy already deleted code point "+string(__code)+".",0)
    }


#define code_execute
    ///code_execute(code,[arg0,arg1...])
    //code: code index to execute
    //args: script arguments to pass to the code
    //returns: return value from the code, or 0
    //Executes a precompiled code index and returns its returned value, or 0 if the code does not return anything.
    var __i,__code,__argc,__change;

    __code=argument0

    if (__code<0 || __code>=__gm82core_compiler_index) {
        show_error("In function code_execute: Cannot execute code point "+string(__code)+", only "+string(__gm82core_compiler_index)+" total code points initialized.",0)
        exit
    }

    if (!__gm82core_compiler_exists[__code]) {
        show_error("In function code_execute: Cannot execute code point "+string(__code)+", it has been deleted.",0)
        exit
    }

    __argc=__gm82core_compiler_argc[__code]
    if (__argc==-1) {
        __i=0 repeat (argument_count-1) {
            __gm82core_compiler_args[__i]=argument[__i+1]
        __i+=1}
        repeat (16-__i) {
            __gm82core_compiler_args[__i]=0
        __i+=1}
    } else {
        if (argument_count-1!=__argc) {
            show_error("In function code_execute: Wrong number of arguments for code point "+string(__code)+", it requires "+string(__argc)+" but "+string(argument_count-1)+" have been passed.",0)
            exit
        }
    }

    __i=0 repeat (__argc) {
        __gm82core_compiler_args[__i]=argument[__i+1]
    __i+=1}

    __gm82core_compiler_return=0
    __gm82core_compiler_argc_cur=argument_count-1

    __change=game_get_state()
    if (__change>0) room_goto_cancel()
    event_perform_object(__gm82core_compiler,ev_other,__code)
    if (__change>0) room_goto(__change)

    return __gm82core_compiler_return


#define code_get_argcount
    ///code_get_argcount(code)
    //code: code index
    //returns: number of arguments, or -1
    //If the code index uses variable arguments, -1 is returned instead.
    var __code;

    __code=argument0

    if (__code<0 || __code>=__gm82core_compiler_index) {
        show_error("In function code_get_argcount: Using nonexisting code point "+string(__code)+", only "+string(__gm82core_compiler_index)+" total code points exist.",0)
        exit
    }

    if (!__gm82core_compiler_exists[__code]) {
        show_error("In function code_get_argcount: Using deleted code point "+string(__code)+".",0)
        exit
    }

    return __gm82core_compiler_argc[__code]


#define code_exists
    ///code_exists(code)
    //code: code index
    //returns: whether the code with index exists and is available for use

    if (__code<0 || __code>=__gm82core_compiler_index) return false

    return __gm82core_compiler_exists[__code]
//
//
