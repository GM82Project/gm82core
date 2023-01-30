//(c) Lovey01

#include "gm82core.h"

GMREAL power_next(double x) {
  // Type pune the double to manipulate its floating-point bits
  unsigned __int64 *v = (unsigned __int64*)&x;

  // Bring the number up to the next power of 2, unless the number is already
  // a power of 2
  // If the number is negative, return 0
  *v = (((*v + 0x000fffffffffffffui64) & 0x7ff0000000000000ui64) &
        ~(unsigned __int64)((__int64)*v >> 63));

  return x;
}

GMREAL file_size(const char *filename) {
    // Get size of file
    // Returns -1 if file doesn't exist
    WIN32_FILE_ATTRIBUTE_DATA attr;

    if (!GetFileAttributesExA(filename, GetFileExInfoStandard, &attr))
        return -1.0;

    return (double)((unsigned __int64)attr.nFileSizeLow | ((unsigned __int64)attr.nFileSizeHigh << 32));
}

GMREAL real_hex(const char *str) {
  // Avoids subtraction at the cost of more memory
  static const unsigned long long lookup[256] = {
    // First 32 chars
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,

    // ASCII map
    0,  // Space
    0,  // !
    0,  // "
    0,  // #
    0,  // $
    0,  // %
    0,  // &
    0,  // '
    0,  // (
    0,  // )
    0,  // *
    0,  // +
    0,  // ,
    0,  // -
    0,  // .
    0,  // /
    0,  // 0
    1,  // 1
    2,  // 2
    3,  // 3
    4,  // 4
    5,  // 5
    6,  // 6
    7,  // 7
    8,  // 8
    9,  // 9
    0,  // :
    0,  // ;
    0,  // <
    0,  // =
    0,  // >
    0,  // ?
    0,  // @
    10, // A
    11, // B
    12, // C
    13, // D
    14, // E
    15, // F
    0,  // G
    0,  // H
    0,  // I
    0,  // J
    0,  // K
    0,  // L
    0,  // M
    0,  // N
    0,  // O
    0,  // P
    0,  // Q
    0,  // R
    0,  // S
    0,  // T
    0,  // U
    0,  // V
    0,  // W
    0,  // X
    0,  // Y
    0,  // Z
    0,  // [
    0,  // |
    0,  // ]
    0,  // ^
    0,  // _
    0,  // `
    10, // a
    11, // b
    12, // c
    13, // d
    14, // e
    15, // f

    // The rest are zeros
  };

  unsigned char c;
  unsigned long long ret = 0;

  // Process 16 chars at a time
#define LOOP                                                                   \
  if (!(c = *(unsigned char*)str++)) return (double)ret;  \
  ret = ret<<4 | lookup[c]

  for (;;) {
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
    LOOP;LOOP;LOOP;LOOP;
  }

#undef LOOP
}
    
GMSTR string_hex(double num) {
  // Return buffer  
  static char retbuf[17] = {0}; // Initialize to all 0's

  static const char lookup[] = {
    '0', '1', '2', '3',
    '4', '5', '6', '7',
    '8', '9', 'A', 'B',
    'C', 'D', 'E', 'F'
  };

  unsigned long long i = (unsigned long long)num;
  char *ret = retbuf+15; // Last character minus one, NULL terminator required

  *ret = lookup[i&0xf];
  while ((i >>= 4) != 0) {
    *--ret = lookup[i&0xf];
  }

  return (char*)ret;
}
