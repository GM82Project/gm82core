#include "gm82core.h"

static HWND window_handle;

GMREAL __gm82core_setcomposite(double enable) {  
    /*if (enable>=0.5) {    
        SetWindowLong(window_handle,GWL_EXSTYLE,GetWindowLong(window_handle,GWL_EXSTYLE) | WS_EX_COMPOSITED); 
        MARGINS margins = {-1,-1,-1,-1};
        DwmExtendFrameIntoClientArea(window_handle,&margins);
    } else {
        SetWindowLong(window_handle,GWL_EXSTYLE,GetWindowLong(window_handle,GWL_EXSTYLE) & ~WS_EX_COMPOSITED);    
        MARGINS margins = {0,0,0,0};
        DwmExtendFrameIntoClientArea(window_handle,&margins);
    }*/
    return 0;
}

GMREAL __gm82core_setchromakey(double enable, double color) {  
    if (enable>=0.5) {    
        SetParent(window_handle,NULL);
        SetWindowLong(window_handle,GWL_EXSTYLE,GetWindowLong(window_handle,GWL_EXSTYLE) | WS_EX_LAYERED); 
        SetLayeredWindowAttributes(window_handle,((DWORD)color)&0x00ffffff,0xff,LWA_COLORKEY);          
    } else {
        SetWindowLong(window_handle,GWL_EXSTYLE,GetWindowLong(window_handle,GWL_EXSTYLE) & ~WS_EX_LAYERED);
    }
    return 0;
}