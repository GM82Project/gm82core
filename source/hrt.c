//High Resolution Timer
//(c) 2007 Kyle Smith

#include "gm82core.h"

ULONGLONG resolution = 1000000, lastTime = 0, frequency = 1;

GMREAL __hrt_init() {
    if (QueryPerformanceFrequency((LARGE_INTEGER *)&frequency) && QueryPerformanceCounter((LARGE_INTEGER*)&lastTime)) {
        return 1;
    } else {
        return 0;
    }
}

GMREAL hrt_now() {
    ///get_timer()
    //returns the time since last system bootup in microseconds.
    ULONGLONG now;
    if (QueryPerformanceCounter((LARGE_INTEGER*)&now)) {
        return (double)(now*resolution/frequency);
    } else {
        return -1.0;
    }
}

GMREAL hrt_delta() {
    ///get_delta()
    //returns the time since last call of this function in microseconds.
    ULONGLONG now, lt;
    if (QueryPerformanceCounter((LARGE_INTEGER*)&now)) {
        lt = lastTime;
        lastTime = now;
        return (double)((now - lt)*resolution/frequency);
    } else {
        return -1.0;
    }
}