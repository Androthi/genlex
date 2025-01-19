module buffer;
import std::core::string;
import std::io;

//+ Data appent/insert methods ================================================

<*
	general purpose append macro
	recognizes the types of string, char, dstring, char32, buffer
*>
macro void Buffer.append(&self, value)
{
	var $Type = $typeof(value);
	$switch ($Type)
		$case char:
		$case ichar:
			self.insert_char(self.len(), value);
		$case DString:
			self.append_string(value);
		$case String:
			self.insert_chars(self.len(), value);
		$case Char32:
			self.insert_char32(self.len(), value);
		$case Buffer:
			self.insert_buffer(self.len(), value);
		$default:
			$switch
				$case $defined((Char32)value):
					self.insert_char32(self.len(), (Char32)value);
				$case $defined((String)value):
					self.insert_chars(self.len(), (String)value);
				$default:
					$error "Unsupported type for append - use appendf instead.";
			$endswitch
	$endswitch
}


macro void Buffer.append_buffer(&self, Buffer buffer)
{
	self.insert_buffer(self.len(), buffer);
}

macro void Buffer.append_chars(&self, String str)
{
	self.insert_chars(self.len(), str);
}

macro void Buffer.append_char(&self, char c)
{
	self.insert_char(self.len(), c);
}

macro void Buffer.append_string(&self, DString str)
{
	self.insert_string(self.len(), str);
}

<*
	@require c <= 0x10ffff
*>
macro usz Buffer.append_char32(&self, Char32 c)
{
	usz n = self.insert_char32(self.len(), c);
	return n;
}

macro usz Buffer.append_utf32(&self, Char32[] chars)
{
	usz n = self.append_utf32(chars);
	return n;
}

<*
	appends a formatted string
	@param format `formatted string in the style of printf`
	@param args `varargs for formatted string`
*>
fn void Buffer.appendf(&self, String format, args...)
{
	if (!self.data()) self.new_init(format.len + 20);
	@pool(self.data().allocator)
	{
		String str = string::tformat(format, ...args);
		self.append_chars(str);
	};
}

<*
	inserts a formatted string
	@param index `location in buffer to insert`
	@param format `the formatted string in the style of printf`
	@param args `varargs for formatted string`
*>
fn void Buffer.insertf(&self, usz index, String format, args...)
{
	if (!self.data()) self.new_init(format.len + 20);
	@pool(self.data().allocator)
	{
		String str = string::tformat(format, ...args);
		self.insert_chars(index, str);
	};
}

<*
	repeatedly appends a sincgle character source.
	@param c `the character to append`
	@param times `the number of times to append c`
*>
fn void Buffer.append_repeat(&self, char c, usz times)
{
	if (times == 0) return;
	self.reserve(times);
	BufferData* data = self.data();
	for (usz i = 0; i < times; i++)
	{
		data.chars[data.len++] = c;
	}
}

<*
	For OutStream interface
	appends a character slice into the buffer
	@param buffer `the slice to write into the buffer`
	@return `the length of characters written`
*>
fn usz! Buffer.write(&self, char[] buffer) @dynamic
{
	self.append_chars((String)buffer);
	return buffer.len;
}

<*
	appends a singel byte into the buffer
	@param c `the character to append`
*>
fn void! Buffer.write_byte(&self, char c) @dynamic
{
	self.append_char(c);
}

<*
	overwrites a character at index. does not change the size of buffer
	@param index `index of character to overwrite`
	@param c `the new character to insert at index`
	@require index < self.len()
*>
fn void Buffer.set(self, usz index, char c)
{
	self.data().chars[index] = c;
}

<*
	InStream reader for buffer. Data is appended to buffer
	@param reader `the InStream reader source`
	@return `number of bytes read from reader`
*>
fn usz! Buffer.read_from_stream(&self, InStream reader)
{
	if (&reader.available)
	{
		usz total_read = 0;
		while (usz available = reader.available()!)
		{
			self.reserve(available);
			BufferData* data = self.data();
			usz len = reader.read(data.chars[data.len..(data.capacity - 1)])!;
			total_read += len;
			data.len += len;
		}
		return total_read;
	}
	usz total_read = 0;
	while (true)
	{
		// Reserve at least 16 bytes
		self.reserve(16);
		BufferData* data = self.data();
		// Read into the rest of the buffer
		usz read = reader.read(data.chars[data.len..(data.capacity - 1)])!;
		data.len += read;
		// Ok, we reached the end.
		if (read < 16) return total_read;
		// Otherwise go another round
	}
}

<*
	general purpose insert macro
	recognizes the types string, char, dstring, buffer
	@param index `location in buffer to insert data`
	@param value `the value to insert at index`
*>
macro void Buffer.insert(&self, usz index, value)
{
	var $Type = $typeof(value);
	$switch ($Type)
		$case char:
		$case ichar:
			self.insert_char(index, value);
		$case DString:
			self.insert_string(index, value);
		$case String:
			self.insert_chars(index, value);
		$case Char32:
			self.insert_char32(index, value);
		$case Buffer:
			self.insert_buffer(index, value);
		$default:
			$switch
				$case $defined((Char32)value):
					self.insert_char32(index, (Char32)value);
				$case $defined((String)value):
					self.insert_chars(index, (String)value);
				$default:
					$error "Unsupported type for insert";
			$endswitch
	$endswitch
}

<*
	inserts a buffer object into the buffer.
	@param index `location in buffer to insert dest buffer`
	@param buffer `the dest buffer to insert at index`
*>
fn void Buffer.insert_buffer(&self, usz index, Buffer buffer)
{
	if (!buffer) return;
	BufferData* data = buffer.data();
	self.insert_chars( index, (String)data.chars[:data.len]);
}

<*
	@param index `position in buffer to insert`
	@param s `the string slice to insert into buffer`
	@require index <= self.len()
*>
fn void Buffer.insert_chars(&self, usz index, String s)
{
	if (s.len == 0) return;
	if (!*self) *self = new();
	self.reserve(s.len);
	BufferData* data = self.data();
	usz len = self.len();
	if (data.chars[:len].ptr == s.ptr) return;
	index = min(index, len);
	self.adjust_for_insert(index, s.len);
	data.len += s.len;
	char* start = data.chars[index:s.len].ptr;
	mem::move(start, s, s.len);
}

<*
	@param index `position in buffer to insert`
	@param str `the dynamic string to insert into buffer`
	@require index <= self.len()
*>
fn void Buffer.insert_string(&self, usz index, DString str)
{
	if (!str) return;
	self.insert_chars(index, str.str_view());
}

<*
 	@param index `position in buffer to insert`
	@param c `the character to insert into buffer`
	@require index <= self.len()
*>
fn void Buffer.insert_char(&self, usz index, char c)
{
	self.reserve(1);
	BufferData* data = self.data();
	char* start = &data.chars[index];
	self.adjust_for_insert(index, 1);
	data.chars[index] = c;
	data.len++;
}


<*
	@param index `position in buffer to insert`
	@param c `the Char32 to insert into buffer`
	@require index <= self.len()
*>
fn usz Buffer.insert_char32(&self, usz index, Char32 c)
{
	char[4] buffer @noinit;
	char* p = &buffer;
	usz n = conv::char32_to_utf8_unsafe(c, &p);
	self.reserve(n);
	BufferData* data = self.data();
	self.adjust_for_insert (index, n);
	data.chars[index:n] = buffer[:n];
	data.len += n;
	return n;
}

<*
	@param index `position in buffer to insert`
	@param chars `the Char32[] to insert into buffer`	
	@require index <= self.len()
*>
fn usz Buffer.insert_utf32(&self, usz index, Char32[] chars)
{
	usz n = conv::utf8len_for_utf32(chars);
	self.reserve(n);
	BufferData* data = self.data();
	self.adjust_for_insert (index, n);
	char[4] buffer @noinit;
	foreach(c : chars)
	{
		char* p = &buffer;
		usz m = conv::char32_to_utf8_unsafe(c, &p);
		data.chars[index:m] = buffer[:m];
		index += m;
	}
	data.len += n;
	return n;
}

