module buffer;
import std::io;

//+ Buffer editing ============================================================

<*
	delete a number of bytes from the buffer
	@param start `location to start deleting`
	@param len `the number of bytes to delete, debault is 1`
	@require start < self.len()
	@require start + len <= self.len()
*>
fn void Buffer.delete(&self, usz start, usz len = 1)
{
	if (!len) return;
	BufferData* data = self.data();
	usz new_len = data.len - len;
	if (new_len == 0)
	{
		data.len = 0;
		return;
	}
	usz len_after = data.len - start - len;
	if (len_after > 0)
	{
		data.chars[start:len_after] = data.chars[start + len:len_after];
	}
	data.len = new_len;
}

<*
	string replacement in buffer
	@param needle `the string to search for`
	@param replacement `the string used to replace, if needle is found`
*>
fn void Buffer.replace_string(&self, String needle, String replacement)
{
	if (!*self)
	{
		self.append_chars(replacement);
		return;
	}
	
	usz! index = self.find(needle);
	if (try index)
	{
		self.delete(index, needle.len);
		self.insert_chars(index, replacement);
	}
}

<*
	checks to see if a character is in a character set
	@param c `the character to check for`
	@param set `the Cset in which to search for this character`
	@return `true if found, false if not found`
*>
macro bool char_in_cset(char c, Cset set)
{
	foreach (ch : set) if (ch == c) return true;
	return false;
}

<*
	remove white spaces from start and end buffer
*>
fn void Buffer.trim(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return;
	BufferData* data = self.data();
	if (data.len == 0) return;
	usz count = 0;
	while (count < data.len && char_in_cset(data.chars[count], set)) count++;
	if (count == data.len) return self.clear();
	if (count) self.delete(0, count);
	count = data.len -1;
	while (count > 0 && char_in_cset(data.chars[count], set)) count--;
	if (count < data.len -1) return self.chop(count);
}

<*
	like delete, but uses a range of start, end rather than start, len.
	@param start `location to start deleting`
	@param end `location to end deleting`
	@require start < self.len()
	@require end < self.len()
	@require end >= start "End must be same or equal to the start"
*>
fn void Buffer.delete_range(&self, usz start, usz end)
{
	self.delete(start, end - start + 1);
}

<*
	replaces every instance of char ch with char replacement
*>
fn void Buffer.replace_chars(self, char ch, char replacement)
{
	BufferData* data = self.data();
	if (!data) return;
	foreach (&c : data.chars[:data.len])
	{
		if (*c == ch) *c = replacement;
	}
}

<*
	extracts a sub buffer from the buffer, copies it to dest buffer.
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param dest `a pointer to the dest buffer to copy data`
	@return! BufferError.NULL_BUFFER, BufferError.OPERATION_FAILED, BufferError.INDEX_OUT_OF_RANGE
*>
fn void! Buffer.sub_buffer(&self, usz start_index, usz len, Buffer* dest)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (len == 0) return BufferError.OPERATION_FAILED?;
	if (start_index > data.len) return BufferError.INDEX_OUT_OF_RANGE?;
	if (len > data.len) len = data.len;
	char[] range = data.chars[start_index:len];
	(void)dest.write(range);
}

<*
	like sub_buffer, but creates a new buffer
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param allocator `allocator to use, default allocator::heap()`
	@return `a new allocated Buffer`
*>
fn Buffer Buffer.new_sub_buffer(self, usz start_index, usz len, Allocator allocator = allocator::heap())
{
	// we're always returning an allocaterd DString, so no need for error, it will panic if malloc fails
	Buffer buf = new();
	(void)self.sub_buffer(start_index, len, &buf);
	return buf;
}

<*
	extracts a sub string from the buffer, copies it to dest DString.
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param dest `a pointer to the dest dstring to copy data`
	@return! BufferError.NULL_BUFFER, BufferError.OPERATION_FAILED, BufferError.INDEX_OUT_OF_RANGE
*>
fn void! Buffer.sub_string(&self, usz start_index, usz len, DString* dest)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	if (len == 0) return BufferError.OPERATION_FAILED?;
	BufferData* data = self.data();
	if (start_index > data.len) return BufferError.INDEX_OUT_OF_RANGE?;
	if (len > data.len) len = data.len;
	char[] range = data.chars[start_index:len];
	(void)dest.write(range);
}

<*
	like sub_string, but creates a new dstring
	@param start_index `location to start extraction`
	@param len `the number of bytes to copy`
	@param allocator `allocator to use, default allocator::heap()`
	@return `a new allocated dstring`
*>
fn DString Buffer.new_sub_string(self, usz start_index, usz len, Allocator allocator = allocator::heap())
{
	// we're always returning an allocaterd DString, so no need for error, it will panic if malloc fails
	DString str = dstring::new(allocator:allocator);
	(void)self.sub_string(start_index, len, &str);
	return str;
}

//+ Copying ===================================================================

<*
	dublicates a buffer. a null is returned if the self buffer is null.
	@param allocator `allocator to use. will use allocator::heap is none is passed.`
	@return `a new buffer object.`
*>
fn Buffer Buffer.copy(self, Allocator allocator = null)
{
	if (!self)
	{
		if (allocator) return new(0, allocator);
		return (Buffer)null;
	}
	BufferData* data = self.data();
	if (!allocator) allocator = allocator::heap();
	Buffer new_buffer = new(data.capacity, allocator);
	mem::copy((char*)new_buffer.data(), (char*)data, BufferData.sizeof + data.len);
	return new_buffer;
}

<*
	dublicates a buffer. will use the temp allocator.
	@return `a new buffer object.`
*>
fn Buffer Buffer.temp_copy(&self) => self.copy(allocator::temp());

<*
	will create a ZString object from the contents of the buffer
	@param allocator `default allocator::heap()`
	@return `a ZString object`
*>
fn ZString Buffer.copy_zstr(self, Allocator allocator = allocator::heap())
{
	usz str_len = self.len();
	if (!str_len)
	{
		return (ZString)allocator::calloc(allocator, 1);
	}
	char* zstr = allocator::malloc(allocator, str_len + 1);
	BufferData* data = self.data();
	mem::copy(zstr, &data.chars, str_len);
	zstr[str_len] = 0;
	return (ZString)zstr;
}

<*
	will create a String object from the contents of the buffer
	@param allocator `default allocator::heap()`
	@return `a String object`
*>
fn String Buffer.copy_str(self, Allocator allocator = allocator::heap())
{
	return (String)self.copy_zstr(allocator)[:self.len()];
}

<*
	same as copy_str, but will use the temp allocator.
	@return `a String object`
*>
fn String Buffer.temp_copy_str(self) => self.copy_str(allocator::temp()) @inline;

<*
	will create an array of Char32[] from the contents of the buffer
	@param allocator `default is allocator::heap()`
*>
fn Char32[] Buffer.copy_utf32(&self, Allocator allocator = allocator::heap())
{
	return self.str_view().to_utf32(allocator) @inline!!;
}

// Comparing/Branching ========================================================
<*
	compares to buffers for equality, case insensitive.
	@param other_buffer `the buffer to compare`
	@return `true if equal`
*>
macro bool Buffer.iequals(self, Buffer other_buffer)
{
	self.equals(other_buffer, false);
}

<*
	compares two buffers for equality, default case sensitive
	@param other_buffer `the buffer to compare`
	@param case_sensitive `true is compare is case sensitive`
	@return `true if equal`
*>
fn bool Buffer.equals(self, Buffer other_buffer, bool case_sensitive = true)
{
	BufferData *buf1 = self.data();
	BufferData *buf2 = other_buffer.data();
	if (buf1 == buf2) return true;
	if (!buf1) return buf2.len == 0;
	if (!buf2) return buf1.len == 0;
	usz buf1_len = buf1.len;
	if (buf1_len != buf2.len) return false;
	for (int i = 0; i < buf1_len; i++)
	{
		if (case_sensitive)
		{
			if (buf1.chars[i] != buf2.chars[i]) return false;
		} else
		{
			if ( buf1.chars[i].to_lower() != buf2.chars[i].to_lower() ) return false;
		}
	}
	return true;
}

<*
	compares two buffers
	@param other_buffer `the buffer to compare`
	@return `true if buffer is less than other_buffer`
*>
fn bool Buffer.less(self, Buffer other_buffer)
{
	BufferData* buf1 = self.data();
	BufferData* buf2 = other_buffer.data();
	if (buf1 == buf2) return false;
	if (!buf1) return buf2.len != 0;
	if (!buf2) return buf1.len == 0;
	usz buf1_len = buf1.len;
	usz buf2_len = buf2.len;
	if (buf1_len != buf2_len) return buf1_len < buf2_len;
	for (int i = 0; i < buf1_len; i++)
	{
		if (buf1.chars[i] >= buf2.chars[i]) return false;
	}
	return true;
}

<*
	@return `true if cursor is at EOF`
*>
fn bool Buffer.is_eof(self)
{
	if (!self) return true; // cheap way, but i don't want this to be an optional return
	BufferData* data = self.data();
	return data.len == data.cursor;
}
