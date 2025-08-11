#define include_file_get_buffer
    ///include_file_get_buffer(filename,buffer)
    //filename: name of the included file to get
    //buffer: id of a Net/Buf buffer
    //requires the Network/Buffer extension!
    
    globalvar __gm82net_version,__gm82buf_version;
    if (__gm82buf_version>=100) {
        var __buf,__name;
    
        __name=argument0
        __buf=argument1
        
        if (!include_file_exists(__name)) {
            show_error("Trying to get nonexisting included file("+string(__name)+") data into a buffer("+string(__buf)+").",false)
            return 0
        }
        
        return execute_string('
            var __buf,__name;
    
            __name=argument0
            __buf=argument1
            
            if (!buffer_exists(__buf)) {
                show_error("Trying to get included file("+string(__name)+") data into a nonexisting buffer("+string(__buf)+").",false)
                return 0
            }
            
            buffer_set_size(__buf,include_file_size(__name))
            buffer_set_pos(__buf,0)         
            
            __gm82core_include_file_get_buffer(__name,buffer_get_address(__buf))
            return 1
        ',__name,__buf)
    } else if (__gm82net_version>=131) {
        var __buf,__name;
    
        __name=argument0
        __buf=argument1
        
        if (!include_file_exists(__name)) {
            show_error("Trying to get nonexisting included file("+string(__name)+") data into a buffer("+string(__buf)+").",false)
            return 0
        }
        
        return execute_string('
            var __buf,__name;
    
            __name=argument0
            __buf=argument1
            
            if (!buffer_exists(__buf)) {
                show_error("Trying to get included file("+string(__name)+") data into a nonexisting buffer("+string(__buf)+").",false)
                return 0
            }
            
            buffer_set_size(__buf,include_file_size(__name))
            buffer_set_pos(__buf,0)         
            
            __gm82core_include_file_get_buffer(__name,buffer_get_address(__buf,0))
            return 1
        ',__name,__buf)
    }    
    
    show_error("Cannot use include_file_get_buffer without 8.2 Network 1.3.1, or Buffer 1.0 or newer.",false)
    return 0
//
//