module buffer;
import std::io;

<*
	@return `index of cursor`
*>
macro usz Buffer.get_cursor(self)
{
	return self.data().cursor;
}

<*
	move cursor to end of buffer
	@return `index of cursor`
*>
macro usz Buffer.cursor_to_eof(&self)
{
	self.cursor_to(self.len());
}

<*
	move cursor to beginning of buffer
	@return `index of cursor`
*>
macro usz Buffer.cursor_to_bof(&self)
{
	return self.cursor_to(0);
}

<*
	@param index `position to try moving cursor`
	@return `index of cursor`
*>
fn usz Buffer.cursor_to(&self, usz index)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if (index > data.len) index = data.len;
	data.cursor = index;
	return data.cursor;
}

<*
	try to move cursor right (towards end of buffer)
	@param n `number of characters to move`
	@return `index of cursor`
*>
fn usz Buffer.cursor_right(&self, usz n)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if ((data.cursor += n) > data.len) data.cursor = data.len;
	return data.cursor;
}

<*
	try to move cursor left (towards beginning of buffer)
	@param n `number of characters to move`
	@return `index of cursor`
*>
fn usz Buffer.cursor_left(&self, usz n)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if ((isz)(data.cursor -= n) < 0) data.cursor = 0;
	return data.cursor;
}

<*
	tries to move cursor right (towards end of buffer) num_lines number of lines.
	@param num_lines `number of lines to move`
	@return `index of cursor`
*>
fn usz Buffer.cursor_right_lines(&self, usz num_lines)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (num_lines)
	{
		self.cursor_to_eol();
		if (data.cursor == data.len) return data.cursor;
		data.cursor++;
		num_lines--;
	}
	return data.cursor;
}

 fn usz Buffer.cursor_next_line(&self) => self.cursor_right_lines(1) @inline;

//+ TODO
//fn usz Buffer.cursor_left_lines(&self, usz num_lines)
//{}

//+ TODO
 //fn usz Buffer.cursor_prev_line(&self) => self.cursor_left_lines(1) @inline;

<*
	move cursor to beginning of current line
	@return `index of cursor`
*>
fn usz Buffer.cursor_to_bol(&self)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	if (data.cursor == 0) return 0;

	// if currently at EOL, don't count it.
	if (data.chars[data.cursor] == '\n') data.cursor--;
	if (data.cursor == 0) return 0;
	if (data.chars[data.cursor] == '\r') data.cursor--; //hate dealing with DOS crap.

	while (data.cursor > 0)
	{
		if (char_in_cset(data.chars[data.cursor], "\n\r")) break;
		data.cursor--;
	}

	// we are at the EOL of the previous line, if any. advance the cursor to the beginning of the actual text.
	if( data.cursor == 0) return 0;
	if (data.chars[data.cursor] == '\r') data.cursor++;
	return ++data.cursor;
}

<*
	moves the internal cursor to the the end of the current line
	@return `index of cursor`
*>
fn usz Buffer.cursor_to_eol(&self)
{
	if (!*self) return 0;
	BufferData* data = self.data();

	while (data.cursor < data.len)
	{
		if (char_in_cset(data.chars[data.cursor], "\n\r")) break;
		data.cursor++;
	}
	return data.cursor;
}

<*
	moves the internal cursor to the next character that is not a member of set.
	@return `index of cursor`
*>
fn usz Buffer.span(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor < data.len)
	{
		if (!char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor++;
	}
	return data.cursor;
}

<*
	moves the internal cursor to the previous character that is not a member of set.
	@return `index of cursor`
*>
fn usz Buffer.r_span(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor > 0)
	{
		if (!char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor--;
	}
	return data.cursor;
}

<*
	moves the internal cursor to the next character that is a member of set.
	@return `index of cursor`
*>
fn usz Buffer.brk(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor < data.len)
	{
		if (char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor++;
	}
	return data.cursor;	
}

<*
	moves the internal cursor to the previous character that is a member of set.
	@return `index of cursor`
*>
fn usz Buffer.r_brk(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return 0;
	BufferData* data = self.data();
	while (data.cursor > 0)
	{
		if (char_in_cset(data.chars[data.cursor], set)) break;
		data.cursor--;
	}
	return data.cursor;	
}

//= NOTE: these will likely get their own files later
<*
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `character at cursor index in buffer. cursor is advanced by 1`
*>
fn char! Buffer.get_char(&self)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.cursor == data.len) return BufferError.EOF?;
	return data.chars[data.cursor++];
}

<*
	@return! BufferError.NULL_BUFFER, BufferError.INDEX_OUT_OF_RANGE
	@return `character at cursor index in buffer.`
*>
fn char! Buffer.peek_char_at(&self, usz index)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if ( index > data.len) return BufferError.INDEX_OUT_OF_RANGE?;
	return data.chars[index];
}

<*
	gets the word under the cursor
	@param set `the character set to use to determine word separators, default WHITE_SPACES`
	@return! BufferError.NULL_BUFFER, BufferError.EOF, BufferError.NO_WORD
	@return `string slice containing the word`
*>
fn String! Buffer.get_word(&self, Cset set = WHITE_SPACES)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.cursor == data.len) return BufferError.EOF?;
	char under = self.peek_char_at(data.cursor)!;
	if (char_in_cset(under, set)) return BufferError.NO_WORD?;
	usz start = self.r_brk(set);
	if (start != 0) start = ++data.cursor; // make sure start points to the start of characters in the word.
	usz end = self.brk(set);
	return (String) data.chars[start:end-start];
}

<*
	@param entire_line `if true, finds the beginning and end of line at cursor, if false, beginning of line is starting cursor index`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `string slice of entire line at cursor index, cursor is advanced to end of current line`
*>
fn String! Buffer.get_line(&self, bool entire_line = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.cursor == data.len) return BufferError.EOF?;
	usz start = data.cursor;
	if (entire_line) start = self.cursor_to_bol();
	usz end = self.cursor_to_eol();
	if (data.cursor < data.len) data.cursor++; // advance 1 char beyond EOL.
	return (String)data.chars[start:end-start];
}

<*
	wrapper for get_line with parameter for entire_line set to false.
*>
macro String! Buffer.get_cursor_line(&self)
{
	return self.get_line(false)!;
}

<*
	cursor independent method to get the string slice of a line
	@param start `index that determines beginning of line to retreive`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `string slice of line starting at start`
*>
fn String! Buffer.get_line_from(&self, usz start)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (start >= data.len) return BufferError.EOF?;
	usz end = start;
	while (end < data.len)
	{
		if (char_in_cset(data.chars[end], "\n\r")) break;
		end++;
	}
	return (String)data.chars[start:end-start];
}

<*
	@param needle `string to search`
	@param case_sensitive `search is case_sensitive if true`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `index in buffer where needle is found, cursor is advanced to end of found data`
*>
fn usz! Buffer.find_next(&self, String needle, bool case_sensitive = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	usz! index = self.find(needle, data.cursor, case_sensitive);
	if( try index ){
		data.cursor = ++index; //need to be 1 past find index for next find pass
		return data.cursor-1;
	} else {
		return BufferError.EOF?;
	}
}

<*
	wrapper around find_next with case_sensitive set to false
*>
macro usz! Buffer.ifind_next(&self, String needle)
{
	self.find_next(needle, true);
}

<*
	@param needle `the string to search for in the buffer`
	@param start_from `the index in buffer from which to begin searching`
	@param case_sensitive `if true, search is case sensitive, default true`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `index if needle is found in buffer`
*>
fn usz! Buffer.find(&self, String needle, usz start_from = 0, bool case_sensitive = true)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	usz needle_len = needle.len;
	if (start_from > data.len || data.len == 0) return BufferError.EOF?;

	if (needle_len > 0 && data.len - start_from >= needle_len)
	{
		String source = (String)data.chars[start_from..data.len];
			
		if (case_sensitive)
		{
			char first = needle[0];
			foreach (i, c: source[..^needle_len])
			{
				if (c == first && source[i:needle_len] == needle) return i + start_from;
			}
		} else
		{
			@pool(data.allocator)
			{
				String tneedle = needle.temp_ascii_to_lower();
				String tsource = source.temp_ascii_to_lower();
				char first = tneedle[0];
				foreach (i, c: tsource[..^needle_len])
				{
					if (c == first && tsource[i:needle_len] == tneedle) return i + start_from;
				}
			};
		}
	}
	return BufferError.EOF?;
}

<*
	wrapper around find method with case sensitive set to false
*>
macro usz! Buffer.ifind(&self, String needle, usz start_from = 0)
{
	self.find(needle, start_from, false);
}