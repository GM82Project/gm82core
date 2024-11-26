#define match_some
    ///match_some(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: trimmed string if pattern matches, or empty if failure
    //Finds any of pattern characters in str. Fails on empty or no matches.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    __gm82core_match_result=false
    if (str=="") return ""

    __gm82core_match_result=true

    var len; len=string_length(str)

    p=len
    while (string_pos(string_char_at(str,p),substr) && p) p-=1
    if (p<len) return string_copy(str,1,p)

    __gm82core_match_result=false return ""


#define match_any
    ///match_any(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: trimmed string if pattern matches, or input if failure
    //Finds any of pattern characters in str. Does not fail.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    if (str=="") return ""

    __gm82core_match_result=true

    var p;p=string_length(str)
    while (string_pos(string_char_at(str,p),substr) && p) p-=1
    return string_copy(str,1,p)


#define match_not_any
    ///match_not_any(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: trimmed string if pattern matches, or input if failure
    //Trims any characters in str that aren't in pattern. Does not fail.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    if (str=="") return ""

    __gm82core_match_result=true

    var p;p=string_length(str)
    while (!string_pos(string_char_at(str,p),substr) && p) p-=1
    return string_copy(str,1,p)


#define match_not_some
    ///match_not_some(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: input if success, or empty if failure
    //Finds any of pattern characters in str. Fails on any matches.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    if (str=="") return ""

    __gm82core_match_result=true

    var len; len=string_length(str)

    p=len
    while (!string_pos(string_char_at(str,p),substr) && p) p-=1
    if (p<len) return str

    __gm82core_match_result=false return ""


#define match_exact
    ///match_exact(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: trimmed string if pattern matches, or empty if failure
    //Matches the exact pattern at the end of str. Fails on empty or no match.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    __gm82core_match_result=false
    if (str=="") return ""

    __gm82core_match_result=true

    var len,sublen;

    len=string_length(str)
    sublen=string_length(substr)

    if (string_copy(str,len-sublen+1,sublen)==substr)
        return string_delete(str,len-sublen+1,sublen)

    __gm82core_match_result=false return ""


#define match_not_exact
    ///match_not_exact(pattern,str)
    //pattern: string to match
    //str: string to search in
    //returns: input if pattern matches, or empty if failure
    //Fails if the pattern matches the end of str. Otherwise returns str.

    globalvar __gm82core_match_result;

    var substr; substr=argument0;
    var str;       str=argument1;

    //win condition
    if (str=="") return ""

    __gm82core_match_result=true

    var len,sublen;

    len=string_length(str)
    sublen=string_length(substr)

    if (string_copy(str,len-sublen+1,sublen)!=substr) {
        return str
    }

    __gm82core_match_result=false return ""


#define match_found
    ///match_found([...])
    //returns whether the match functions succeeded.
    globalvar __gm82core_match_result;
    return __gm82core_match_result
//
//