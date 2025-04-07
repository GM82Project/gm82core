#include "gm82core.h"


//room end clear hack

void* io_clear_addr = (void*)0x606865;
const char io_clear_code[] = {0xfb, 0x00};
const char io_not_clear_code[] = {0x0b, 0x01};

GMREAL io_set_roomend_clear(double enabled) {
    ///io_set_roomend_clear(enabled)
    //enabled: bool - enable clearing
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


//included files hacking

typedef struct TMemoryStream {
    uint32_t vfp;
    void* memory;
    uint32_t size;
    uint32_t position;
    uint32_t capacity;
} TMemoryStream;

typedef struct IncludeFile {
    uint32_t unknown0;
    LPWSTR filename;
    LPWSTR origname;
    char has_data;
    uint32_t size;
    uint32_t store;
    TMemoryStream* tmemstream;
    uint32_t exportaction;
    uint32_t export_to;
    LPWSTR export_folder;
    char overwrite_if_exists;
    char free_after_export;
    char delete_on_game_end;
} IncludeFile;

int* if_count_addr = (int*)0x6886fc;
IncludeFile*** include_files = (IncludeFile***)0x6886f8;

char if_filename_converted[1024];
char* returned_string=NULL;

int __gm82core_get_if_by_name(const char* filename) {
    for (int i=0;i<*if_count_addr;i++) {
        IncludeFile* file=(*include_files)[(int)i];

        wcstombs(if_filename_converted, file->filename, 1024);
        
        if (strcmp(if_filename_converted,filename)==0) {
            return i;
        }
    }
    return -1;
}


GMREAL include_file_count() {
    ///include_file_count()
    //returns the number of included files.
    
    return (double)*if_count_addr;
}

GMREAL include_file_exists(const char* filename) {
    ///include_file_exists(filename)
    //filename: name of the included file to check
    //returns: whether the file exists
    
    return (__gm82core_get_if_by_name(filename)!=-1);
}

GMSTR include_file_name(double index) {
    ///include_file_name(index)
    //index: index of the included file to query
    //returns: name of the included file, or an empty string if the file does not exist
    
    if ((int)index<*if_count_addr && (int)index>=0) {
        IncludeFile* file=(*include_files)[(int)index];

        wcstombs(if_filename_converted, file->filename, 1024);        
        
        return if_filename_converted;
    }
    return "";
}

GMREAL include_file_size(const char* filename) {
    ///include_file_size(filename)
    //filename: name of the included file to check
    //returns: size of the included file, or 0 if the file does not exist
    
    int index=__gm82core_get_if_by_name(filename);
    
    if (index!=-1) {
        IncludeFile* file=(*include_files)[(int)index];

        return file->size;
    }
    return 0;
}

GMSTR include_file_get_string(const char* filename) {
    ///include_file_get_string(filename)
    //filename: name of the included file to check
    //returns: complete contents of the included file as a string, or an empty string if the file does not exist
    
    int index=__gm82core_get_if_by_name(filename);
    
    if (index!=-1) {
        IncludeFile* file=(*include_files)[(int)index];
        
        if (file->has_data==0) return "";
        
        if (returned_string) free(returned_string);
        returned_string = (char*)malloc(file->size+1);
        memcpy(returned_string,file->tmemstream->memory,file->size);
        returned_string[file->size]=0;
        
        return returned_string;
    }
    return "";
}

GMREAL __gm82core_include_file_get_buffer(const char* filename,double buffer) {
    int index=__gm82core_get_if_by_name(filename);
    
    if (index!=-1) {
        IncludeFile* file=(*include_files)[(int)index];
        
        if (file->has_data==0) return 0;
        char* dest=(char*)(int)buffer;

        memcpy(dest,file->tmemstream->memory,file->size);
        
        return 1;

    }
    return 0;
}


//Nasty Ass Runner Shenanigans

const int** room_state = (int**)0x00688C4C;

GMREAL game_get_state() {
    ///game_get_state()
    //returns the current state of the game, as gs_ constants.
    return (double)**room_state;
}

/*const void* delphi_clear = (void*)0x4072d8;
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
