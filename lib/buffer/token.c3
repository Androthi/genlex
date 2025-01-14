module buffer;

<*
	uses internal cursor to tokenize the contents of the buffer
	returns a string slice for each token found.
	returns EOF error when there are no more tokens.
	@param set `a Cset of delimiters to use for isolating tokens.`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `a string of found token`
*>
fn String! Buffer.next_token(&self, Cset set = DELIMITERS)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.len == 0) return BufferError.EOF?;
	if (data.cursor == data.len) return BufferError.EOF?;
	usz token_start = data.cursor;
	while (token_start < data.len && char_in_cset(data.chars[token_start], set)) token_start++;
	usz token_end = token_start+1;
	while (token_end < data.len && !char_in_cset(data.chars[token_end], set)) token_end++;
	data.cursor = token_end;
	return (String)data.chars[token_start:token_end-token_start];
}

<*
	uses internal cursor to peek at the current token. does not advance the cursor
	returns a string slice for token found.
	returns EOF error when there are no more tokens.
	@param set `a Cset of delimiters to use for isolating tokens.`
	@return! BufferError.NULL_BUFFER, BufferError.EOF
	@return `a string of found token`
*>
fn String! Buffer.peek_token(&self, Cset set = DELIMITERS)
{
	if (!*self) return BufferError.NULL_BUFFER?;
	BufferData* data = self.data();
	if (data.len == 0) return BufferError.EOF?;
	if (data.cursor == data.len) return BufferError.EOF?;
	usz token_start = data.cursor;
	while (token_start < data.len && char_in_cset(data.chars[token_start], set)) token_start++;
	usz token_end = token_start+1;
	while (token_end < data.len && !char_in_cset(data.chars[token_end], set)) token_end++;
	return (String)data.chars[token_start:token_end-token_start];
}