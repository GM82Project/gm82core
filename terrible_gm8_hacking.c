#include "gm82core.h"

/*
const void* delphi_clear = (void*)0x4072d8;
static char* retstr = NULL;

//GMREAL funny_test(double ptr, double value) {int a = (int)ptr;int* where = (int*)a;int what = (int)value;*where = what;return 0;

typedef struct {
    int is_string;
    int padding;    
    double real;    
    char* string;
    int padding2;    
}GMVAL;

double internal_call_real(double func,GMVAL* args,int argc) {
    int addr = (int)func;
    char* (*callptr)()=(void*)addr;
    
    GMVAL ret={0};
    GMVAL* retptr = &ret;    
    
    __asm {
        mov ecx, argc //argc
        push args //pointer to gml argument array
        push 16 //args length (unused)
        push retptr        
        call callptr
    }   

    return ret.real;
}

char* internal_call_string(double func,GMVAL* args,int argc) {
    int addr = (int)func;
    char* (*callptr)()=(void*)addr;
    
    GMVAL ret={0};    
    GMVAL* retptr = &ret;

    char** retstrptr = &retstr;

    __asm {
        mov ecx, argc //argc
        push args //pointer to gml argument array
        push 16 //args length (unused)
        push retptr        
        call callptr
    
        mov eax, retstrptr
        call delphi_clear
    }   

    retstr=ret.string;

    return retstr;
}

GMREAL internal_call_real0(double func) {
    return internal_call_real(func,NULL,0);
}

GMREAL internal_call_real1r(double func, double arg0) {
    GMVAL args[1];
    args[0].is_string=0; args[0].real=arg0;

    return internal_call_real(func,args,1);
}

GMREAL internal_call_real2rr(double func, double arg0, double arg1) {
    GMVAL args[2];
    args[0].is_string=0; args[0].real=arg0;
    args[1].is_string=0; args[1].real=arg1;

    return internal_call_real(func,args,2);
}

GMREAL internal_call_real3rrr(double func, double arg0, double arg1, double arg2) {
    GMVAL args[3];
    args[0].is_string=0; args[0].real=arg0;
    args[1].is_string=0; args[1].real=arg1;
    args[2].is_string=0; args[2].real=arg2;

    return internal_call_real(func,args,3);
}

GMSTR internal_call_string0(double func) {
    return internal_call_string(func,NULL,0);
}

GMSTR internal_call_string1s(double func, char* arg0) {
    GMVAL args[1];
    args[0].is_string=1; args[0].string=arg0;

    return internal_call_string(func,args,1);
}*/
