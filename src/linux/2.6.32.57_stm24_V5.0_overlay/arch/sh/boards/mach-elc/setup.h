/*
  arch/sh/boards/mach-elc/setup.h

  Copyright (C) Elecard-STB 2012

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
#ifndef __MACH_ELC_SETUP_H__
#define __MACH_ELC_SETUP_H__

/*
 * Basic Latin alphabetic characters, most legible irrespective
 * of upper or lower case.
 * http://en.wikipedia.org/wiki/Seven-segment_display_character_representations
 */
#define TM1668_7_SEG_LETTERS_ELECARD \
		/*       76543210 */ \
		{ 'A', 0b01110111 }, \
		{ 'a', 0b01011111 }, \
		{ 'B', 0b01111100 }, \
		{ 'b', 0b01111100 }, \
		{ 'C', 0b00111001 }, \
		{ 'c', 0b01011000 }, \
		{ 'D', 0b01011110 }, \
		{ 'd', 0b01011110 }, \
		{ 'E', 0b01111001 }, \
		{ 'e', 0b01111011 }, \
		{ 'F', 0b01110001 }, \
		{ 'f', 0b01110001 }, \
		{ 'G', 0b00111101 }, \
		{ 'g', 0b01101111 }, \
		{ 'H', 0b01110110 }, \
		{ 'h', 0b01110100 }, \
		{ 'I', 0b00110000 }, \
		{ 'i', 0b00000110 }, \
		{ 'J', 0b00011110 }, \
		{ 'j', 0b00011110 }, \
		{ 'K', 0b01110101 }, \
		{ 'k', 0b01110101 }, \
		{ 'L', 0b00111000 }, \
		{ 'l', 0b00110000 }, \
		{ 'M', 0b01010101 }, \
		{ 'm', 0b01010101 }, \
		{ 'N', 0b01010100 }, \
		{ 'n', 0b01010100 }, \
		{ 'O', 0b00111111 }, \
		{ 'o', 0b01011100 }, \
		{ 'P', 0b01110011 }, \
		{ 'p', 0b01110011 }, \
		{ 'Q', 0b01100111 }, \
		{ 'q', 0b01100111 }, \
		{ 'R', 0b01010000 }, \
		{ 'r', 0b01010000 }, \
		{ 'S', 0b01101101 }, \
		{ 's', 0b01101101 }, \
		{ 'T', 0b01111000 }, \
		{ 't', 0b01111000 }, \
		{ 'U', 0b00111110 }, \
		{ 'u', 0b00011100 }, \
		{ 'V', 0b00111110 }, \
		{ 'v', 0b00111110 }, \
		{ 'W', 0b00011101 }, \
		{ 'w', 0b00011101 }, \
		{ 'X', 0b01110110 }, \
		{ 'x', 0b01110110 }, \
		{ 'Y', 0b01101110 }, \
		{ 'y', 0b01101110 }, \
		{ 'Z', 0b01011011 }, \
		{ 'z', 0b01011011 }

extern int device_init_stb830(int ver);
extern int device_init_stb840_promSvyaz(int ver);
extern int device_init_stb840_promWad(int ver);
extern int device_init_stb840_ch7162(int ver);
extern int device_init_stb830_reference(int ver);
extern int device_init_stb_pioneer(int ver);
extern int device_init_stb850(int ver);

#endif //#ifndef __MACH_ELC_SETUP_H__
