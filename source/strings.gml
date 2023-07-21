#define date_get_timestamp
    ///date_get_timestamp([date])
    var __t;
    if (argument_count) __t=argument0 else __t=date_current_datetime()
    return
        string_pad(date_get_day(__t),2)+
        "/"+
        string_pad(date_get_month(__t),2)+
        "/"+
        string_pad(date_get_year(__t) mod 100,2)+
        " "+
        string_pad(date_get_hour(__t),2)+
        ":"+
        string_pad(date_get_minute(__t),2)


#define directory_previous
    ///directory_previous(dir)
    var __fn,__l;

    __fn=string_replace_all(argument0,"/","\")
    __l=string_length(__fn)
    if (string_char_at(__fn,__l)=="\") __fn=string_copy(__fn,1,__l-2)
    return filename_dir(__fn)+"\"


#define filename_remove_ext
    ///filename_remove_ext(fn)
    return string_copy(argument0,1,string_pos(".",argument0)-1)


#define string_better
    ///string_better(real)
    // string(1.012562536) = "1.01"
    // string_better(1.012562536) = "1.01256254"
    var __s;

    __s=string_format(argument0,0,8)+";"
    repeat (8) __s=string_replace(__s,"0;",";")
    return string_replace(string_replace(__s,".;",""),";","")


#define string_number
    ///string_number(string)
    var __p,__m,__str;
    if (string_pos("-",argument0)) __m="-"
    else __m=""
    __p=string_pos(".",argument0)
    if (__p) {
        __str=string_digits(string_copy(argument0,1,__p-1))+"."+string_digits(string_delete(argument0,1,__p))
    } else __str=string_digits(argument0)
    while (string_char_at(__str,1)=="0" && string_char_at(__str,2)!=".") __str=string_delete(__str,1,1)
    if (__str="") return __m+"0"
    return __m+__str


#define string_hexdigits
    ///string_hexdigits(string)
    var __i,__output,__str;
    
    __output=""
    __str=string_upper(argument0)
    __i=1 repeat (string_length(__str)) {
        __c=string_char_at(__str,__i)
        if (string_pos(__c,"0123456789ABCDEF")) __output+=__c
    __i+=1}
    
    return __output


#define string_ord_at
    ///string_ord_at(str,pos)
    return ord(string_char_at(argument0,argument1))


#define string_pad
    ///string_pad(number,digits)
    return string_repeat("-",argument0<0)+string_replace_all(string_format(abs(argument0),argument1,0)," ","0")


#define string_starts_with
    ///string_starts_with(string,substr)
    return string_copy(argument0,1,string_length(argument1))==argument1


#define string_ends_with
    ///string_ends_with(string,substr)
    var __l;
    __l=string_length(argument1)
    return string_copy(argument0,string_length(argument0)-__l+1,__l)==argument1


#define str_cat
    ///str_cat(val1,val2,...)
    var __i,__str;
    
    __str=""
    for (__i=0;__i<argument_count;__i+=1) __str+=string(argument[__i])
    return __str


#define str_ins
    ///str_ins(str%ing,val1,val2...)

    __str=string_replace_all(argument[0],"\%",ansi_char(26)+"percentile")
    __i=1
    repeat (string_count("%",__str)) {
        __str=string_replace(__str,"%",string(argument[__i]))
        __i+=1
    }

    return string_replace_all(__str,ansi_char(26)+"percentile","%")


#define str_sep
    ///str_sep(sep,val1,val2,...)
    var __i,__str;
    
    if (argument_count>1) __str=string(argument[1])
    for (__i=2;__i<argument_count;__i+=1) __str+=argument[0]+string(argument[__i])
    return __str
//
//