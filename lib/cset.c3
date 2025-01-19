
<*
A character set module
The character sets supported are any range in unicode up to
512 characters.

Character sets are created at compile time.
This limitation can be overcome by writing a small program
to print a character set which can then be hard coded as a const.

The existinc character set constants in this library were created
with that method.
*>
module cset;
import utf_utils;
import std::io;

struct CSet
{
	uint index;
	uint128[4] data;    // 512 bits bitmap max size
}

const MAX_SIZE = 512;
const BITS = uint128.sizeof * 8;

// default ascii csets
const CSet LC_ALPHA =		{ .index = 0, .data = {10633823807823001954701781295154855936, 0, 0, 0}	};
const CSet UC_ALPHA =		{ .index = 0, .data = {2475880041677272402379145216, 0, 0, 0}			};
const CSet ALPHA =			{ .index = 0, .data = {10633823810298881996379053697534001152, 0, 0, 0}	};
const CSet NUMERIC =		{ .index = 0, .data = {287948901175001088, 0, 0, 0}						};
const CSet ALPHA_NUMERIC =	{ .index = 0, .data = {10633823810298881996667002598709002240, 0, 0, 0}	};
const CSet WHITE_SPACE =	{ .index = 0, .data = { 0x100002600, 0x0, 0x0, 0x0 }					};
const CSet LINE_BREAK =		{ .index = 0, .data = { 0x2400, 0x0, 0x0, 0x0 }							};

<*
A compile time macro for creating a character set from a utf8 encoded string data
The macro supports up to a range of 512 characters from any starting point.

@param $from `A valid Char32 that will be the starting point in unicode`
@param $data `A uft8 encoded string which will be inserted as valid characters`
@return `A constant CSet object`
*>
macro CSet make_unicode_cset (Char32 $from, String $data) @const
{
	uint128 $zero, $one, $two, $three;
	var $chars = utf_utils::conv_utf8_to_char32($data);
  
	$foreach ( $c : $chars)
		
		$if ($c < $from):
			$error ("String data must be greater than or equal to starting index");
			return;
		$endif

		var $pos = $c - $from;
		$if ($pos > MAX_SIZE):
			$error ("A maximum range of 512 characters from starting index is allowed");
			return;
		$endif

		int $offset = $pos / BITS;
		int $rem = $pos % BITS;
		$switch ($offset)
			$case 0: $zero |= 1u128 << $rem;
			$case 1: $one  |= 1u128 << $rem;
			$case 2: $two  |= 1u128 << $rem;
			$case 3: $three|= 1u128 << $rem;
			$default:
				$$unreachable;
		$endswitch
	$endforeach
	return CSet {
		.index = $from,
		.data = { $zero, $one, $two, $three },
	};
}

<*
A compile time macro that creates an ascii character set from an ascii string data
A uft8 encoded string can be passed as data, but the characters will be treated as ascii.

@param $data `A utf encoded or ascii string, which will be inserted as valid characters`
@return `A constant CSet object`
*>
macro CSet make_ascii_cset ($data) @const
{
	uint128 $low;
	$foreach ($x : $data)
		$if $x > 127:
			$error ("For ascii characters higher than 127, use the make_unicode_cset macro instead");
			$error ("You can still use the char_in_cset method for testing any value in the range of 0 - 255");
			return;
		$else
			$low |= 1u128 << $x;
		$endif
	$endforeach
	return CSet{
		.index = 0,
		.data = { $low, 0, 0, 0 }
	};
}

<*
Checks if a Char32 is in the character set.
@param c `A Char32 to test`
@return `A boolean value, true if the character is in the set`
*>
fn bool CSet.unicode_is_in_set(&self, Char32 c )
{
	isz offset = (isz)(c - self.index);
	if (offset < 0 ) return false;
	isz index = offset/BITS;
	if (index > 4) return false;
	return self.data[index] & ( 1u128 << offset ) != 0;
}

<*
Checks if an ascii char is in the character set.
@param c `A char to test`
@return `A boolean value, true if the character is in the set`
*>
fn bool CSet.char_is_in_set (&self, char c)
{
	if (c > 127) return self.data[1] & ( 1u128 << (c-128) ) != 0;
	return self.data[0] & ( 1u128 << c ) != 0;
}

<*
Printing the object will output a format that can be copied and pasted
into source code to be used as an initialized object.
*>
fn usz! CSet.to_format(&self, Formatter* formatter) @dynamic
{
  return formatter.printf("{ .index = %d, .data = { 0x%x, 0x%x, 0x%x, 0x%x } };",
  		self.index,
		self.data[0],
		self.data[1],
		self.data[2],
		self.data[3],
  );
}

<*
Compile time support module for unicode conversion
*>
module utf_utils;

<*
Support compile time macro.
@return `the length in bytes for a utf8 codepoint`
*>
macro int get_utf32_codepoint_length(char $c) @const
{
	int $len;
	$switch
		$case !($c & 0x80):           $len = 1;
		$case ($c & 0xE0) == 0xC0:    $len = 2;
		$case ($c & 0xF0) == 0xE0:    $len = 3;
		$case ($c & 0xF8) == 0xF0:    $len = 4;
		$default:                     $len = -1;
	$endswitch
	return $len;
}

<*
Support compile time macro.
@return `The length of a utf8 string in utf32`
*>
macro usz get_utf32_len_from_utf8(String $source) @const
{
	usz $len = 0;
	$for (var $i=0; $i < $source.len;)
		var $curlen = get_utf32_codepoint_length ($source[$i]);
		$i += $curlen;
		$len++;
	$endfor
	return $len;
}

<*
Compile time macro.
@param $source `A utf8 string to convert into a Char32[] array`
@return `A Char32[] array`
*>
macro conv_utf8_to_char32($source) @const
{
	Char32 $codepoint;
	var $max = $source.len;

	var $char32len = get_utf32_len_from_utf8 ($source);
	var $chars = {};

	$for (var $inx = 0; $inx < $max; )
		var $c = $source[$inx];
		var $len = get_utf32_codepoint_length($c);
		$switch ($len)
			$case 1: $codepoint = $c;
			$case 2: $codepoint = $c & 0x1F;
			$case 3: $codepoint = $c & 0x0F;
			$case 4: $codepoint = $c & 0x07;
			$default:
				$error("Error, invalid utf8 character in string");
				return;
		$endswitch

		$for (var $x = 1; $x < $len; ++$x)
			$c = $source[$inx + $x];
			$if ( ($c & 0xC0) != 0x80):
				$error("Error, invalid utf8 character in string");
				return;
			$endif
			$codepoint = ($codepoint << 6) | ($c & 0x3F);
		$endfor

		$chars = $chars +++ $codepoint;
		$inx += $len;
	$endfor
	return $chars;
}
