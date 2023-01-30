#define dslist
    ///dslist(list,pos,val) -> value
    ///dslist(list,pos) -> value
    ///dslist(list) -> string
    ///dslist() -> list
    var __i,__s,__str;
    
    if (argument_count==0) {
        return ds_list_create()
    }
    
    __s=ds_list_size(argument0)
        
    if (argument_count==3) {
        if (argument1>=0) {             
            if (argument1-__s>=0) {
                repeat (argument1-__s) ds_list_add(argument0,undefined)
                ds_list_add(argument0,argument2)             
            } else ds_list_replace(argument0,argument1,argument2)             
        } else ds_list_add(argument0,argument2)        
        return argument2
    }
    
    if (argument_count==2) {
        if (argument1>=__s) return undefined
        return ds_list_find_value(argument0,argument1)
    }
    
    if (argument_count==1) {
        __i=0 __str=""
        repeat (__s) {
            __str+=string(ds_list_find_value(argument0,__i))+chr(13)+chr(10)
            __i+=1
        }
        return __str
    }
    

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


#define ds_map_add_copy
    ///ds_map_add_copy(src,dest)
    //copies all keys from src to dest without clearing dest
    var __key;__key=ds_map_find_first(argument0)
    repeat (ds_map_size(argument0)) {
        if (ds_map_exists(argument1,__key)) ds_map_replace(argument1,__key,ds_map_find_value(argument0,__key))
        else ds_map_add(argument1,__key,ds_map_find_value(argument0,__key))
        __key=ds_map_find_next(argument0,__key)
    }


#define ds_map_get
    ///ds_map_get(map,key)
    if (ds_map_exists(argument0,argument1)) return ds_map_find_value(argument0,argument1)
    return undefined


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


#define ds_map_read_ini_string
    ///ds_map_read_ini_string(map,string)
    var __map,__lf,__section,__str,__p;
    
    __map=argument0
    __str=argument1
    if (string_pos(chr($0d)+chr($0a),__str)) __lf=chr($0d)+chr($0a)
    else __lf=chr($0a)
    
    __section=""
    repeat (string_token_start(__str,__lf)) {            
        __str=string_token_next()
        if (__str!="") {
            __p=string_pos("=",__str)
            if (string_pos("[",__str) && string_pos("]",__str) && !__p)
                __section=string_replace(string_replace(__str,"[",""),"]","")+" "
            else if (__p) {
                ds_map_add(__map,__section+string_copy(__str,1,__p-1),string_delete(__str,1,__p))
            }            
        }
    }   

    return 0


#define ds_map_set
    ///ds_map_set(map,key,value)
    if (ds_map_exists(argument0,argument1)) ds_map_replace(argument0,argument1,argument2)
    else ds_map_add(argument0,argument1,argument2)


#define is_undefined
    ///is_undefined(val)
    return string(argument0)==undefined
//
//