#define dslist
    ///dslist(list,[pos,[val]])
    //list: ds list index
    //pos: list position to operate
    //val: value to store
    //call with 3 arguments: sets value, returns value
    //call with 2 arguments: returns found value at pos, or size if pos<=-1
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
        if (argument1<=-1) return __s
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


#define ds_list_add_many
    ///ds_list_add_many(list,val...])
    //list: ds list index
    //val: value(s) to add
    //returns: ds list index
    //Adds any number of values to the provided list.
    var __i;

    __i=1;
    repeat (argument_count-1) {
        ds_list_add(argument[0],argument[__i]);
        __i+=1;
    }

    return argument[0];


#define ds_map_add_copy
    ///ds_map_add_copy(src,dest)
    //src, dest: ds map indexes
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
                    if (__section==" ") __section=""
                else if (__p) {
                    ds_map_add(__map,__section+string_copy(__str,1,__p-1),string_delete(__str,1,__p))
                }            
            }
        }   
        file_text_close(__f)
        
        return ds_map_size(__map)
    }

    return 0


#define ds_map_write_ini
    ///ds_map_write_ini(map,filename)
    //map: ds map index
    //filename: string, file to save
    //Returns: whether the function was successful
    //Writes a dsmap into an ini file. Spaces are used to split key sections.
    var __map,__f,__section,__key,__val,__p;
    
    __map=argument0
    
    ini_open("temp.ini")    
    __key=ds_map_find_first(__map) repeat (ds_map_size(__map)) {
        __val=ds_map_find_value(__map,__key)
        __p=string_pos(" ",__key)
        if (__p) {
            __section=string_copy(__key,1,__p-1)
            __key=string_delete(__key,1,__p)            
        } else __section=""
        ini_write_string(__section,__key,string_better(__val))
    __key=ds_map_find_next(__map,__key)}
    ini_close()
    
    sleep(1) //always sleep after file i/o!
    file_delete(argument1)
    sleep(1)
    file_text_write_all(argument1,string_replace(file_text_read_all("temp.ini"),"[]"+chr_crlf,""))
    sleep(1)
    file_delete("temp.ini")
    
    return file_exists(argument1)


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
                if (__section==" ") __section=""
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


#define ds_map_set_many
    ///ds_map_set_many(map,key1,value1,key2,value2...)
    //map: ds map index
    //key1,value1: first key-value pair
    //key2,value2: second key-value pair
    //etc
    //returns: ds map index
    //Sets any number of map keys at once.
    var __i;

    __i=1;
    repeat (floor((argument_count-1)/2)) {
        if (ds_map_exists(argument[0],argument[__i]))
            ds_map_replace(argument[0],argument[__i],argument[__i+1]);
        else
            ds_map_add(argument[0],argument[__i],argument[__i+1]);
        __i+=2;
    }

    return argument[0];


#define ds_stack_push_many
    ///ds_stack_push_many(stack,val...)
    //stack: ds stack index
    //val: value(s) to push
    //returns: ds stack index
    //Pushes any number of values onto the stack.
    var __i;

    __i=1;
    repeat (argument_count-1) {
        ds_stack_push(argument[0], argument[__i]);
        __i+=1;
    }

    return argument[0];


#define ds_queue_enqueue_many
    ///ds_queue_enqueue_many(queue,val...)
    //queue: ds queue index
    //val: value(s) to enqueue
    //returns: ds queue index
    //Enqueues any number of values to the queue.
    var __i;

    __i=1;
    repeat (argument_count-1) {
        ds_queue_enqueue(argument[0],argument[__i]);
        __i+=1;
    }

    return argument[0];


#define ds_priority_add_many
    ///ds_priority_add_many(queue,val1,prio1,val2,prio2...)
    //queue: ds priority queue index
    //val1,prio1: first value and its priority
    //val2,prio2: second value and its priority
    //etc
    //returns: ds priority queue index
    //Adds any number of values to the priority queue.
    var __i;

    __i=1;
    repeat (floor((argument_count-1)/2)) {
        ds_priority_add(argument[0],argument[__i],argument[__i+1]);
        __i+=2;
    }

    return argument[0];


#define ds_grid_set_many
    ///ds_grid_set_many(grid,x1,y1,value1,x2,y2,value2...)
    //grid: ds grid index
    //x1,y1,value1: first position and value to set
    //x2,y2,value2: second position and value to set
    //etc
    //returns: ds grid index
    //Sets any number of values in the grid.
    var __i;

    __i=1;
    repeat (floor((argument_count-1)/3)) {
        ds_grid_set(argument[0],argument[__i],argument[__i+1],argument[__i+2]);
        __i+=3;
    }

    return argument[0];


#define ds_map_search
    ///ds_map_search(map,value)
    //map: map to search through
    //value: key value to find
    //returns: first occurrence of key containing the value, or "undefined"
    var __map,__find,__key,__str;

    __map=argument0
    __find=argument1
    __str=is_string(__find)

    __key=ds_map_find_first(__map)        

    repeat (ds_map_size(__map)) {
        __cur=ds_map_find_value(__map,__key)
        if (__str) {if (is_string(__cur)) if (__cur==__find) return __key}
        else {if (is_real(__cur)) if (__cur==__find) return __key}
        __key=ds_map_find_next(__map,__key)
    }

    return undefined


#define is_undefined
    ///is_undefined(val)
    //val - value to check
    //returns: bool
    //Studio shim. checks the value against the 'undefined' constant.
    return string(argument0)==undefined


#define __gm82core_bag_check
    if (argument0>=0) if (ds_list_find_value(argument0,0)=="__gm82core_bag_marker__") return 0
    show_error("in function "+argument1+": structure "+string(argument0)+" is not a bag)",0)
    return 1
    

#define ds_bag_create
    ///ds_bag_create()
    //returns: new bag
    //creates and returns a bag for use.
    
    var __bag;__bag=ds_list_create()
    ds_list_add(__bag,"__gm82core_bag_marker__")
    return __bag


#define ds_bag_clear
    ///ds_bag_clear(bag)
    //clears a bag out.
    
    if (__gm82core_bag_check(argument0,"ds_bag_clear")) exit
    ds_list_clear(argument0)
    ds_list_add(argument0,"__gm82core_bag_marker__")


#define ds_bag_remove
    ///ds_bag_remove(bag,item)
    //returns: whether the item was in the bag.
    
    if (__gm82core_bag_check(argument0,"ds_bag_remove")) exit
    if (string(argument1)=="__gm82core_bag_marker__") {
        show_error("in function ds_bag_remove: forbidden value",0)
        exit
    }
    var __pos;__pos=ds_list_find_index(argument0,argument1)
    if (__pos) {
        ds_list_delete(argument0,__pos)
        return 1
    }
    return 0
    
    
#define ds_bag_destroy
    ///ds_bag_destroy(bag)
    //destroys a bag and frees the associated memory.
    
    if (__gm82core_bag_check(argument0,"ds_bag_destroy")) exit
    ds_list_destroy(argument0)


#define ds_bag_add
    ///ds_bag_add(bag,item,[item...])
    //bag: bag to add the item to
    //items: items to add to the bag
    //adds items to the bag.
    
    if (__gm82core_bag_check(argument[0],"ds_bag_add")) exit
    ds_list_delete(argument[0],0)
    var __i;__i=1 repeat (argument_count-1) {
        if (string(argument[1])=="__gm82core_bag_marker__") {
            show_error("in function ds_bag_add: forbidden value in argument "+string(__i),0)
        } else {
            ds_list_add(argument[0],argument[__i])
        }
    __i+=1}
    ds_list_shuffle(argument[0])
    ds_list_insert(argument[0],0,"__gm82core_bag_marker__")


#define ds_bag_grab
    ///ds_bag_grab(bag)
    //returns: item
    //grabs an item out of the bag. if the bag is empty, an error is thrown.
    
    if (__gm82core_bag_check(argument0,"ds_bag_grab")) exit
    
    var __size;__size=ds_list_size(argument0)-1
    if (__size<1) {
        show_error("in function ds_bag_grab: trying to grab from empty bag",0)
        return undefined
    }
    var __pos;__pos=irandom_range(1,__size)
    var __val;__val=ds_list_find_value(argument0,__pos)
    ds_list_delete(argument0,__pos)
    return __val


#define ds_bag_size
    ///ds_bag_size(bag)
    //returns: size of a bag
    
    if (__gm82core_bag_check(argument0,"ds_bag_size")) exit
    return ds_list_size(argument0)-1


#define ds_bag_empty
    ///ds_bag_empty(bag)
    //returns: whether the bag is empty.
    
    if (__gm82core_bag_check(argument0,"ds_bag_empty")) exit
    return (ds_list_size(argument0)==1)


#define ds_map_read_safe
    ///ds_map_read_safe(map,str)
    //map: empty ds_map
    //str: string to read
    //returns: success
    //Cehcks if a string is supposedly a valid written dsmap before attempting to read it.
    var str,i,l;

    str=string(argument1)
    l=string_length(str)
    if (l mod 2) return 0

    //check first and last 16 characters only for speed
    for (i=1;i<=16;i+=1) if (!string_pos(string_char_at(str,i),"0123456789ABCDEF")) return 0
    for (i=l;i>=l-16;i-=1) if (!string_pos(string_char_at(str,i),"0123456789ABCDEF")) return 0

    ds_map_read(argument0,str)
    return 1
//
//
