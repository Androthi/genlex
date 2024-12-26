module lexer;
import std::io;

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
	NOT_NUMERIC,
}

Tkn[256] lex_token_table =
{
	// non grapheme chars
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,
	Tkn.WHITE_SPACE, Tkn.LINE_BREAK, Tkn.ERROR, Tkn.ERROR, Tkn.LINE_BREAK, Tkn.ERROR, Tkn.ERROR,
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,
	Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR, Tkn.ERROR,

	// start of ascii set.. symbols
	Tkn.WHITE_SPACE, Tkn.BANG, Tkn.QUOTE, Tkn.HASH, Tkn.DOLLAR, Tkn.PERCENT, Tkn.AMPER, Tkn.APOST,
	Tkn.LPAREN, Tkn.RPAREN, Tkn.ASTERISK, Tkn.PLUS, Tkn.COMMA, Tkn.MINUS, Tkn.PERIOD, Tkn.SLASH,

	// numbers
	Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT, Tkn.DIGIT,

	// symbols
	Tkn.COLON, Tkn.SEMICOLON, Tkn.LESS, Tkn.EQUAL, Tkn.GREATER, Tkn.QUESTION, Tkn.AT,
	
	// lower case alpha
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,

	// symbols
	Tkn.LBRACKET, Tkn.BACKSLASH, Tkn.RBRACKET, Tkn.CARET, Tkn.UNDERSCORE, Tkn.GRAVE,

	// upper case alpha
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,
	Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA, Tkn.ALPHA,

	// symbols
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
	String slice;
}

<*
 @require self.data  "NULL data"
*>
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
				.slice = self.data[caret:1],
			};
}


fn Lexeme! Lexer.peek(&self)
{
	usz save_caret = self.caret;
	Lexeme! lexresult = self.lex();
	self.caret = save_caret;
	return lexresult;
}

<*
 skip white spaces in data
 @require self.data  "NULL data"
*>
fn void! Lexer.skip_ws(&self)
{
	Lexeme! l;
	while (true)
	{
		l = self.peek()!;
		if (catch err = l ) break;
		if (l.token != Tkn.WHITE_SPACE && l.token != Tkn.LINE_BREAK ) break;
		if (l.token == Tkn.EOF) break;
		self.caret++;
	}
}

<*
 @require self.data  "NULL data"
*>
fn Lexeme! Lexer.get_numeric(&self)
{
	Lexeme! current = self.peek();
	if (catch excuse = current) return current;
	if (current.token != Tkn.DIGIT) return LexError.NOT_NUMERIC?;

	usz save_caret = self.caret++;
	while (true)
	{
		io::eprintn("not implemented");
		break;
	}

	return Lexeme{};
}
/*

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