#define date_get_timestamp
    ///date_get_timestamp([date])
    //date: datetime value
    //returns: a human-readable timestamp
    
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
    //dir: directory string
    //returns: the previous directory
    
    var __fn,__l;

    __fn=string_replace_all(argument0,"/","\")
    __l=string_length(__fn)
    if (string_char_at(__fn,__l)=="\") __fn=string_copy(__fn,1,__l-2)
    return filename_dir(__fn)+"\"


#define filename_remove_ext
    ///filename_remove_ext(fn)
    //fn: filename string
    //returns: filename without extension
    
    return string_copy(argument0,1,string_pos(".",argument0)-1)


#define string_better
    ///string_better(real)
    //real: value to convert to string
    //returns: string of value with 8 decimal digits.
    
    var __s;
    
    if (is_string(argument0)) return argument0

    __s=string_format(argument0,0,16)+";"
    repeat (16) __s=string_replace(__s,"0;",";")
    return string_replace(string_replace(__s,".;",""),";","")


#define string_number
    ///string_number(string)
    //string: text to parse
    //returns: removes any letters, and attempts to format a number.
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


#define string_magnitude
    ///string_magnitude(number,magnitude,unit1,unit2...)
    //number: number to condense
    //magnitude: divisor
    //units: units to append to the number
    
    var i,number;
    
    number=argument0
    magnitude=argument1
    
    i=2
    while (abs(number)>=magnitude and i<argument_count-1) {
        number/=magnitude
        i+=1
    }
    
    return string(number)+argument[i]


#define string_hexdigits
    ///string_hexdigits(string)
    //string: string to parse
    //returns: string with only valid hex digits
    
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
    //str: string
    //pos: position
    //returns: character value at position
    
    return ord(string_char_at(argument0,argument1))


#define string_pad
    ///string_pad(number,digits)
    //number: value to format
    //digits: number of spaces to occupy
    //returns: string of value padded with zeroes to occupy specified dimensions
    
    return string_repeat("-",argument0<0)+string_replace_all(string_format(abs(argument0),argument1,0)," ","0")


#define string_starts_with
    ///string_starts_with(string,substr)
    //string: text
    //substr: string to search
    //returns: whether string starts with substr
    
    return string_copy(argument0,1,string_length(argument1))==argument1


#define string_ends_with
    ///string_ends_with(string,substr)
    //string: text
    //substr: string to search
    //returns: whether string ends with substr
    
    var __l;
    __l=string_length(argument1)
    return string_copy(argument0,string_length(argument0)-__l+1,__l)==argument1


#define str_cat
    ///str_cat(val1,val2,...)
    //arguments: values to concatenate
    //returns: string with all arguments concatenated
    
    var __i,__str;
    
    __str=""
    for (__i=0;__i<argument_count;__i+=1) __str+=string(argument[__i])
    return __str


#define str_ins
    ///str_ins(str%ing,val1,val2...)
    //str%ing: format to parse
    //arguments: values to insert
    //returns: string, with each percentile character (%) being replaced with one of the arguments

    __str=string_replace_all(argument[0],"\%",ansi_char(26)+"percentile")
    __i=1
    repeat (string_count("%",__str)) {
        __str=string_replace(__str,"%",string(argument[__i]))
        __i+=1
    }

    return string_replace_all(__str,ansi_char(26)+"percentile","%")


#define str_sep
    ///str_sep(sep,val1,val2,...)
    //sep: separator string
    //arguments: values to concatenate
    //returns: string with all arguments concatenated, separated by the 'sep' string.
   
    var __i,__str;
    
    if (argument_count>1) __str=string(argument[1])
    for (__i=2;__i<argument_count;__i+=1) __str+=argument[0]+string(argument[__i])
    return __str


#define string_delete_end
    ///string_delete_end(string,count)
    //string: string to delete from
    //count: amount of characters to remove
    //returns: shortened copy of provided string

    return string_delete(argument0, max(string_length(argument0) - argument1 + 1, 1), argument1);


#define string_copy_end
    ///string_copy_end(string,count)
    //string: string to copy from
    //count: amount of characters to copy
    //returns: copy from provided string

    return string_copy(argument0, max(string_length(argument0) - argument1 + 1, 1), argument1);


#define string_trim
    ///string_trim(string,[trim1,trim2...])
    //string: string to process
    //arguments: strings to trim out
    //returns: trimmed string
    //This function will remove occurrences of the trims from the edges of a string.
    //If no extra arguments are specified, spaces are removed instead.
    
    var __i,__p1,__p2,__str,__trim,__trimlen;
        
    __str=argument[0]
    __i=1
        
    if (argument_count==1) {     
        __j=string_length(__str)
        
        while (string_char_at(__str,__i)==" " && __i<__j) __i+=1
        while (string_char_at(__str,__j)==" " && __j>0) __j-=1
        
        return string_copy(__str,__i,__j-__i+1)
    }

    repeat (argument_count-1) {
        __trim=argument[__i]
        
        __trimlen=string_length(__trim)
        while (string_copy(__str,1,__trimlen)==__trim) {
            __str=string_delete(__str,1,__trimlen)
        }
        
        while (string_copy(__str,string_length(__str)+1-__trimlen,__trimlen)==__trim) {
            __str=string_delete(__str,string_length(__str)+1-__trimlen,__trimlen)
        }
    __i+=1}

    return __str


#define string_justify
    ///string_justify(string,width)
    //string: text to process
    //width: size in pixels to fit text
    //returns: adjusted string
    //Inserts spaces into a string to make it fit a certain width.
    var __str,__w;

    __str=string_trim(argument0)
    __w=argument1

    var __oldstr,__sc,__space,__i,__cursp,__par;
    __oldstr=__str

    __sc=0
    __i=1 repeat (string_length(__str)) {
        if (string_char_at(__str,__i)==" ") {
            __space[__sc]=__i
            __sc+=1
            do {__i+=1} until (string_char_at(__str,__i)!=" ")
        }
    __i+=1}

    if (__sc==0 or string_width(" ")<=0) return __str

    __cursp=0 __par=0
    while (string_width(__str)<__w) {
        __oldstr=__str           
        __str=string_insert(" ",__str,__space[__cursp])     
        __i=__cursp repeat (__sc-__i) {__space[__i]+=1 __i+=1}     
        __cursp+=2 if (__cursp>=__sc) {__par=!__par*(__sc>1) __cursp=__par}
    }

    return __oldstr


#define string_wrap
    ///string_wrap(string,width,[mode])
    //string: text to process
    //width: size in pixels to fit text
    //mode 0/default: just like builtin text_ext
    //mode 1: cut words at boundary
    //mode 2: add spaces to justify
    //returns: adjusted string
    //Adjusts text to fit a specified maximum width.
    var __in,__w,__out,__i,__p,__fail,__cur,__op,__lf,__c,__pc,__width;

    __lf=""
    __valid=chr_cr+chr(9)+" -.,;:?!/\@#$%&*+<>{}[]()='"+'"'

    if (argument_count<2 or argument_count>3) {
        show_error("error in function string_wrap: wrong number of arguments ("+string(argument_count)+")",false)
        return "ERROR"
    }
     
    __in=string_replace_all(argument[0],chr_lf,"")
    __w=abs(argument[1])
    if (argument_count==3) __mode=round(argument[2]) else __mode=0
    if (__mode<0 or __mode>2) {
        show_error("error in function string_wrap: wrong mode ("+string(argument[2])+")",false)
        return "ERROR"
    }
    
    __out="" __cur="" __c="" __width=0
    __i=1 repeat (string_length(__in)) {
        __pc=__c
        __c=string_char_at(__in,__i)
        __cur+=__c
        __width+=string_width(__c)
        if (__width>__w or __c==chr_cr or (__c=="#" and __pc!="\")) {
            if (__width<=__w) {
                //line already is short enough
                if (__c==chr_cr) __cur=string_copy(__cur,1,string_length(__cur)-1)
                if (__mode==2) __out+=__lf+string_justify(__cur,__w)
                else __out+=__lf+__cur
                __lf=chr_cr
                __cur=""
                __width=0
            } else {
                //long line
                __p=string_length(__cur)
                __op=__p-2
                __fail=true
                if (__mode!=1) repeat (__p) {
                    //find break point
                    __p-=1
                    if (__p==0) break
                    if (string_pos(string_char_at(__cur,__p),__valid)) {
                        if (__mode==2) __out+=__lf+string_justify(string_copy(__cur,1,__p),__w)
                        else __out+=__lf+string_copy(__cur,1,__p)
                        __lf=chr_cr
                        __cur=string_delete(__cur,1,__p)
                        if (string_pos(string_char_at(__cur,1),__valid)) __cur=string_delete(__cur,1,1)
                        __fail=false
                        break
                    }
                }
                if (__fail) {
                    //force a break in the middle of a word
                    if (__mode==2) __out+=__lf+string_justify(string_copy(__cur,1,__op),__w)
                    else __out+=__lf+string_copy(__cur,1,__op)
                    __lf=chr_cr
                    __cur=string_delete(__cur,1,__op)
                    if (string_char_at(__cur,1)==" ") __cur=string_delete(__cur,1,1) else {
                        if (!string_pos(string_char_at(__out,string_length(__out)),__valid)) __out+="-"
                    }
                }
                __width=string_width(__cur)
            }
        }
    __i+=1}

    if (__cur!="") {
        //last line
        if (__c==chr_cr) __cur=string_copy(__cur,1,string_length(__cur)-1)
        if (__mode==2) __out+=__lf+string_justify(__cur,__w)
        else __out+=__lf+__cur
    }

    return __out
//
//