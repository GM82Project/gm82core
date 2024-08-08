#define code_compile
    ///code_compile(string)
    //string: code to compile
    //returns: code index
    //This function will compile a string of code and return its id.
    //Compilation takes a while, but execution is very fast.
    //Note: use the function code_return() to set the return value for code_execute.
    //If code_return() is never called, the code will return 0 when executed.
    var code,i,argc;
    
    argc=0
    repeat (16) {
        if (!string_pos("argument"+string(argc),argument0)) break
    argc+=1}
    
    if (argc==0) {
        if (string_pos("argument[",argument0)) argc=-1
    }
    
    __gm82core_compiler_argc[__gm82core_compiler_index]=argc
    
    code=""
    if (argc==-1) {
        //variable args
        i=0 repeat (16) {
            code+="argument["+string(i)+"]=__gm82core_compiler_args["+string(i)+"];"
        i+=1}
    } else {
        //fixed args
        i=0 repeat (argc) {
            code+="argument"+string(i)+"=__gm82core_compiler_args["+string(i)+"];"
        i+=1}
    }
    
    object_event_add(__gm82core_compiler,ev_other,__gm82core_compiler_index,code+argument0)
    __gm82core_compiler_exists[__gm82core_compiler_index]=true  
    
    __gm82core_compiler_index+=1    
    return __gm82core_compiler_index-1


#define code_return
    __gm82core_compiler_return=argument0


#define code_destroy
    ///code_destroy(code)
    //code: code index to destroy
    //Destroys a piece of compiled code and frees memory.    
    var code;
    
    code=argument0
    
    if (code<0 || code>=__gm82core_compiler_index) {
        show_error("In function code_destroy: Cannot destroy code point "+string(code)+", only "+string(__gm82core_compiler_index)+" total code points initialized.",0)
        exit
    }
    
    if (__gm82core_compiler_exists[code]) {    
        object_event_clear(__gm82core_compiler,ev_other,code)
        __gm82core_compiler_exists[code]=false
    } else {
        show_error("In function code_destroy: Cannot destroy already deleted code point "+string(code)+".",0)
    }


#define code_execute
    ///code_execute(code,[arg0,arg1...])
    //code: code index to execute
    //args: script arguments to pass to the code
    //returns: return value from the code, or 0
    //Executes a precompiled code index and returns the value last given to code_return(), or 0 if the code does not return anything.
    var i,code,argc;
    
    code=argument0
    
    if (code<0 || code>=__gm82core_compiler_index) {
        show_error("In function code_execute: Cannot execute code point "+string(code)+", only "+string(__gm82core_compiler_index)+" total code points initialized.",0)
        exit
    }
    
    if (!__gm82core_compiler_exists[code]) {
        show_error("In function code_execute: Cannot execute code point "+string(code)+", it has been deleted.",0)
        exit
    }
    
    argc=__gm82core_compiler_argc[code]
    if (argc==-1) {
        i=0 repeat (argument_count-1) {
            __gm82core_compiler_args[i]=argument[i+1]
        i+=1}
        repeat (15-i) {
            __gm82core_compiler_args[i]=0
        i+=1}
    } else {
        if (argument_count-1!=argc) {
            show_error("In function code_execute: Wrong number of arguments for code point "+string(code)+", it requires "+string(argc)+" but "+string(argument_count-1)+" have been passed.",0)
            exit
        }
    }
    
    i=0 repeat (argc) {
        __gm82core_compiler_args[i]=argument[i+1]
    i+=1}
    
    __gm82core_compiler_return=0
    
    event_perform_object(__gm82core_compiler,ev_other,code)
    
    return __gm82core_compiler_return


#define code_get_argcount
    ///code_get_argcount(code)
    //code: code index
    //returns: number of arguments, or -1
    //If the code index uses variable arguments, -1 is returned instead.    
    var code;
    
    code=argument0
    
    if (code<0 || code>=__gm82core_compiler_index) {
        show_error("In function code_get_argcount: Nonexisting code point "+string(code)+", only "+string(__gm82core_compiler_index)+" total code points initialized.",0)
        exit
    }
    
    if (!__gm82core_compiler_exists[code]) {
        show_error("In function code_get_argcount: Nonexisting code point "+string(code)+", it has been deleted.",0)
        exit
    }
    
    return __gm82core_compiler_argc[code]
//
//  