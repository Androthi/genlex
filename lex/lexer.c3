module lexer;

enum Tkn
{
	ERROR,
	EOF,
	WHITE_SPACE,
	LINE_BREAK,
	BANG,
	QUOTE,
	HASH,
	DOLLAR,
	PERCENT,
	AMPER,
	APOST,
	LPAREN,
	RPAREN,
	ASTERISK,
	PLUS,
	COMMA,
	MINUS,
	PERIOD,
	SLASH,
	DIGIT,
	COLON,
	SEMICOLON,
	LESS,
	EQUAL,
	GREATER,
	QUESTION,
	AT,
	ALPHA,
	LBRACKET,
	RBRACKET,
	BACKSLASH,
	CARET,
	UNDERSCORE,
	GRAVE,
	LBRACE,
	RBRACE,
	VERTBAR,
	TILDE,

}

fault LexError
{
	ILLEGAL_CHARACTER,
}

Tkn[256] lex_token_table =
{
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,
	Tkn.WHITE_SPACE, Tkn.LINE_BREAK, Tkn.ERROR, Tkn.ERROR, Tkn.LINE_BREAK, Tkn.ERROR, Tkn.ERROR,
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,
	Tkn.WHITE_SPACE, Tkn.BANG, Tkn.QUOTE, Tkn.HASH, Tkn.DOLLAR, Tkn.PERCENT, Tkn.AMPER, Tkn.APOST,
	Tkn.LPAREN, Tkn.RPAREN, Tkn.ASTERISK, Tkn.PLUS, Tkn.COMMA, Tkn.MINUS, Tkn.PERIOD, Tkn.SLASH,
	Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT,
	Tkn.COLON, Tkn.SEMICOLON, Tkn.LESS, Tkn.EQUAL, Tkn.GREATER, Tkn.QUESTION, Tkn.AT,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.LBRACKET, Tkn.BACKSLASH, Tkn.RBRACKET, Tkn.CARET, Tkn.UNDERSCORE, Tkn.GRAVE,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.LBRACE, Tkn.VERTBAR, Tkn.RBRACE, Tkn.TILDE,

	// utf8 alpha chars
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA
};

struct Lexer
{
	String data;
	usz caret;
}

struct Lexeme
{
	Tkn token;
	char c;
	usz caret;
}

fn Lexeme! Lexer.lex(&self)
{
	usz caret = self.caret;
	if (caret == self.data.len)
	{
		return	Lexeme
				{
					.token = Tkn.EOF
				};
	}

	char cur_char = self.data[self.caret++];
	Tkn token = lex_token_table[cur_char];
	if (token == Tkn.ERROR) return LexError.ILLEGAL_CHARACTER?;

	return	Lexeme
			{
				.token = token,
				.c = cur_char,
				.caret = caret,
			};
}


fn Lexeme! Lexer.peek(&self)
{
	usz save_caret = self.caret;
	Lexeme! lexresult = self.lex();
	self.caret = save_caret;
	return lexresult;
}


/*

	switch (token)
	{
		case Tkn.ALPHA:

			//> TODO: get id, compare with ID list, return token, fill lexer fields
			break;

		case Tkn.DIGIT:

			usz save_caret = self.caret++;
			bool is_float = false;
			bool done = false;
			tc = TypeClass.NUMERIC; // assume numeric by default

			while( true )
			{
				Lexeme! nextlex = self.lex();
				if (@catch(nextlex)) return nextlex;

				switch (nextlex.token)
				{
					case Tkn.PERIOD:
						
						if (is_float) // found a period after a float period.  eg 12.134. ... 
						{
							done = true;
							break;
						}
						// first period found, this is a float.
						is_float = true;
						tc = TypeClass.FLOAT;

					case Tkn.DIGIT:
						self.caret++;
						continue;

					case Tkn.EOF:
						done = true;
						break;

					default:
						self.caret++;
						done = true;
						break;
				}
				
				if (done) break;
			}

			break;
*/