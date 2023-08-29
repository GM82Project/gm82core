#include "gm82core.h"

void* io_clear_addr = (void*)0x606865;
const char io_clear_code[] = {0xfb, 0x00};
const char io_not_clear_code[] = {0x0b, 0x01};

GMREAL io_set_roomend_clear(double enabled) {
    ///io_set_roomend_clear(enabled)
    //enabled: bool - enable clearing
    //returns: nothing
    //Changes the behavior for clearing the keyboard state on Room End.
    //Disable to prevent missing key presses between rooms.
    
    if (enabled>=0.5) {
        //re-add io clear at room end
        WriteProcessMemory(GetCurrentProcess(), io_clear_addr, io_clear_code, 2, NULL);
    } else {
        //patch out io clear at room end
        WriteProcessMemory(GetCurrentProcess(), io_clear_addr, io_not_clear_code, 2, NULL);
    }
    
    return 0;
}

/*
const void* delphi_clear = (void*)0x4072d8;
static char* retstr = NULL;

typedef struct {
    int is_string;
    int padding;    
    double real;    
    char* string;
    int padding2;    
}GMVAL;

GMREAL internal_call_real(double func,GMVAL* args,int argc) {
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

GMSTR internal_call_string(double func,GMVAL* args,int argc) {
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
