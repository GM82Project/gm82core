#include "gm82core.h"

static char* tokenstore;
static char* tokenpos;
static char tokensep[256] = {0};
static size_t tokenseplen = 0;

GMREAL __gm82core_dllcheck() {
    return 820;
}

GMREAL color_reverse(double color) {
    int col=(int)round(color);
    return ((col & 0xff)<<16) + (col & 0xff00) + ((col & 0xff0000)>>16);
}
GMREAL color_inverse(double color) {
    return 0xffffff-(int)round(color);
}

GMREAL string_token_start(const char* str, const char* sep) {
    tokenseplen=min(255,strlen(sep));
    int len=strlen(str);
    tokenstore=realloc(tokenstore, len+1);
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