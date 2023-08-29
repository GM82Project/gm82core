#define dslist
    ///dslist(list,[pos,[val]])
    //list: ds list index
    //pos: list position to operate
    //val: value to store
    //call with 3 arguments: sets value, returns value
    //call with 2 arguments: returns found value at pos
    //call with 1 argument: returns string of list
    //call with 0 arguments: returns new list
    //List accelerator function. Performs different actions depending on arguments.
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
    ///dsmap(map,[key,[value]])
    //map: ds map index
    //key: map key to operate on
    //val: value to store
    //call with 3 arguments: sets key to value, returns value
    //call with 2 arguments: returns found value in key
    //call with 1 argument: returns string of map
    //call with 0 arguments: returns new map
    //Map accelerator function. Performs different actions depending on arguments.
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
    //list1, list2: ds list indexes
    //returns: bool
    //Compares both lists item by item, and returns whether they're identical.
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
    //src, dest: ds map indexes
    //returns: nothing
    //Copies all keys from source map to dest map.
    var __key;__key=ds_map_find_first(argument0)
    repeat (ds_map_size(argument0)) {
        if (ds_map_exists(argument1,__key)) ds_map_replace(argument1,__key,ds_map_find_value(argument0,__key))
        else ds_map_add(argument1,__key,ds_map_find_value(argument0,__key))
        __key=ds_map_find_next(argument0,__key)
    }


#define ds_map_get
    ///ds_map_get(map,key)
    //map: ds map index
    //key: key to get
    //returns: key value, or "<undefined>"
    //Studio shim. Returns undefined when the key does not exist.
    if (ds_map_exists(argument0,argument1)) return ds_map_find_value(argument0,argument1)
    return undefined


#define ds_map_read_ini
    ///ds_map_read_ini(map,filename)
    //map: ds map index
    //filename: string, file to load
    //returns: number of keys loaded
    //Reads an ini file into a dsmap. Section names are prepended to each key.
    var __map,__f,__section,__str,__p;

    if (file_exists(argument1)) {
        __map=argument0
        
        ds_map_clear(__map)
        
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
        
        return ds_map_size(__map)
    }

    return 0


#define ds_map_read_ini_string
    ///ds_map_read_ini_string(map,string)
    //map: ds map index
    //string: string containing ini-like data
    //returns: number of keys loaded
    //Reads an ini string into a dsmap. Section names are prepended to each key.
    var __map,__lf,__section,__str,__p;
    
    __map=argument0
    __str=argument1
    if (string_pos(chr($0d)+chr($0a),__str)) __lf=chr($0d)+chr($0a)
    else __lf=chr($0a)
    
    ds_map_clear(__map)
    
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
    
    return ds_map_size(__map)


#define ds_map_set
    ///ds_map_set(map,key,value)
    //map: ds map index
    //key: key to operate on
    //value: value to store
    //returns: value stored
    //Replaces or creates a key in a dsmap. Ensures no duplicate keys.
    if (ds_map_exists(argument0,argument1)) ds_map_replace(argument0,argument1,argument2)
    else ds_map_add(argument0,argument1,argument2)
    return argument2


#define is_undefined
    ///is_undefined(val)
    //val - value to check
    //returns: bool
    //Studio shim. checks the value against the 'undefined' constant.
    return string(argument0)==undefined
//
//