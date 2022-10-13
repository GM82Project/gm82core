#include "gm82core.h"

static int has_started;

static char* tokenstore = NULL;
static char* tokenpos = NULL;
static char tokensep[256] = {0};
static size_t tokenseplen = 0;

GMREAL __gm82core_dllcheck() {
    return 820;
}
GMREAL __gm82core_checkstart() {
    if (has_started) return 0;
    has_started = 1;
    return 1;
}

GMREAL color_reverse(double color) {
    int col=(int)round(color);
    return ((col & 0xff)<<16) + (col & 0xff00) + ((col & 0xff0000)>>16);
}
GMREAL color_inverse(double color) {
    return 0xffffff-(int)round(color);
}

GMREAL string_token_start(const char* str, const char* sep) {
    tokenseplen = min(255,strlen(sep));
    tokenstore = realloc(tokenstore, strlen(str)+1);
    strcpy(tokenstore, str);
    memset(tokensep, 0, 256);
    strncpy(tokensep, sep, tokenseplen);
    tokenpos = tokenstore;
    return 0;
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