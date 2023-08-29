#include "gm82core.h"

static char* tokenstore;
static char* tokenpos;
static char tokensep[256] = {0};
static size_t tokenseplen = 0;

GMREAL __gm82core_dllcheck() {
    return 820;
}

GMREAL color_reverse(double color) {
    ///color_reverse(color)
    //color: integer - color value
    //returns: color
    //Reverses the blue and red channels.
    
    int col=(int)round(color);
    return ((col & 0xff)<<16) + (col & 0xff00) + ((col & 0xff0000)>>16);
}
GMREAL color_inverse(double color) {
    ///color_inverse(color)
    //color: integer - color value
    //returns: color
    //Gets the negative of the color.
    
    return 0xffffff-(int)round(color);
}

GMREAL string_token_start(const char* str, const char* sep) {
    ///string_token_start(str,sep)
    //str: string - text to separate
    //sep: string - separator
    //returns: the total number of tokens
    //Starts splitting a string by a separator. Returns number of tokens for easy use in a repeat loop.
    
    tokenseplen=min(255,strlen(sep));
    int len=strlen(str);
    tokenstore=(char*)realloc(tokenstore, len+1);
    strcpy(tokenstore, str);
    memset(tokensep, 0, 256);
    strncpy(tokensep, sep, tokenseplen);
    tokenpos=tokenstore;
    
    int count=0;
    char* pos=tokenstore;
    while ((pos = strstr(pos, tokensep)) && pos<tokenstore+len-tokenseplen) {
        count++;
        pos+=tokenseplen;
    }    
    
    return count+1;
}

GMSTR string_token_next() {
    ///string_token_next()
    //returns: the next token, or empty string if done.
    char* startpos = tokenpos;
    if (startpos) {
        tokenpos = strstr(tokenpos, tokensep);        
        if (tokenpos) {
            tokenpos[0]=0;
            tokenpos+=tokenseplen;
        }
    }
    return startpos;
}
