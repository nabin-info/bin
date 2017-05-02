/* http://stackoverflow.com/questions/6240055/manually-converting-unicode-codepoints-into-utf-8-and-utf-16
 *
 * UTF-8 Encoding
 * ==============
 * 0x00000000 - 0x0000007F: 0xxxxxxx  -->--->--->--->--->--->--->--->--->---v (from)
 * 0x00000080 - 0x000007FF: 110xxxxx 10xxxxxx            0xFF & (a - 0x20)  |  ====
 * 0x00000800 - 0x0000FFFF: 1110xxxx 10xxxxxx 10xxxxxx  <---<---<---<---<---< ( to )
 * 0x00010000 - 0x001FFFFF: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 * 0x00200000 - 0x03FFFFFF: 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 * 0x04000000 - 0x7FFFFFFF: 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 * 
 * Invalid UCS code values in conforming UTF-8 streams:
 * 0xd800 – 0xDFFF (UTF-16 surrogates), 0xFFFE, and 0xFFFF (UCS noncharacters) 
 * 
 * The xxx bit positions are filled with the bits of the character code number in 
 * binary representation.  Only the shortest possible multibyte sequence which can 
 * represent the code number of the character can be used.
 * 
 * In our case, the above reduces to:
 * 
 *      1110 hhhh  10hh hhxx      10xxxxxx
 *     (     .-0xFF00___,   ) | (ascii - 0x20))
 *          /F-\      /-F-\       10xxxxxx
 *     |....static.bits....|          orD
 *     1110 1111  , 1011 110a , 10aaaaaa
 *     0xE0|0x0F    0xB0|0xC    0x80
*/

#include <stdlib.h>
#include <stdio.h>

typedef unsigned char byte;

int main(int argc, char *argv[]) {
	byte s[3] = {0xE3,0x80,0x80};
	byte u[3] = {0xEF,0xBC,0x80};
	byte a = 0;

	while (!feof(stdin) && !feof(stdout)) {

		/* byte-wise read ascii */
		if (fread(&a, 1, 1, stdin) != 1) {
			return(1);
		}

		/* translatable ascii range */
		if (!(0x1F < a && a < 0x7F)) {
			fwrite(&a,1, 1,stdout);
			continue;
		}

		/* full-width table begins with an invalid char so I reuse 
                 * U+3000 for the space. */
		if (!(a -= 0x20)) {
			fwrite(&s,1, 3,stdout);
			continue;
		}
			
		/* translate ascii to utf8 full-width */
		u[1] = 0xBC | ((a >> 6) & 0x03);
		u[2] = 0x80 | ((a >> 0) & 0xBF);
		fwrite(&u,1, 3,stdout);
		fflush(stdout);
	}
	return(0);
}
