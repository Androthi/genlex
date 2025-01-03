<*
	This file is auto-generated.
	Any changes will be lost next time it is regenerated.
*>
//#MOD
module lexer;
import std::io;
import std::sort;

enum Tkn
{
	ERROR,
	NONE,
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

	ID,
}

//#ENUM

//#DATA


macro check_keyword( $arr, String s )
{
	foreach (item : $arr )
	{
		if (item.name.len == s.len)
		{
			if (item.name == s)
			{
				return item.token;
			}
		}
	}
	return (*$arr)[0].token;
}

fault LexError
{
	ILLEGAL_CHARACTER,
	NOT_ALPHA,
	NOT_FOUND,
}

Tkn[256] lex_token_table =
{
	// non grapheme chars
	ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR,
	WHITE_SPACE, LINE_BREAK, ERROR, ERROR, LINE_BREAK, ERROR, ERROR,
	ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR,
	ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR, ERROR,

	// start of ascii set.. symbols
	WHITE_SPACE, BANG, QUOTE, HASH, DOLLAR, PERCENT, AMPER, APOST,
	LPAREN, RPAREN, ASTERISK, PLUS, COMMA, MINUS, PERIOD, SLASH,

	// numbers
	DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT, DIGIT,

	// symbols
	COLON, SEMICOLON, LESS, EQUAL, GREATER, QUESTION, AT,
	
	// lower case alpha
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,

	// symbols
	LBRACKET, BACKSLASH, RBRACKET, CARET, UNDERSCORE, GRAVE,

	// upper case alpha
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,

	// symbols
	LBRACE, VERTBAR, RBRACE, TILDE,

	// utf8 alpha chars
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA,
	ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA, ALPHA
};

struct Lexer
{
	String data;
	String id_separators;
	usz caret;
	usz line;
}

struct Lexeme
{
	Tkn token;
	char c;
	String slice;
}

fn Lexer Lexer.init (String data, String id_separators = "_") @operator(construct)
{	
	return {
		.data = data,
		.caret = 0,
		.line = 1,
		.id_separators = id_separators,
	};
}

fn void Lexer.free (&self)
{
	free (self.data);
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
					.token = EOF
				};
	}

	char cur_char = self.data[self.caret];
	Tkn token = lex_token_table[cur_char];
	if (token == ERROR) return LexError.ILLEGAL_CHARACTER?;
	if (cur_char == '\n') self.line++;
	if (token == ALPHA) return self.get_id();

	self.caret++;

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
	usz save_line = self.line;
	Lexeme lexresult = self.lex()!;
	self.caret = save_caret;
	self.line = save_line;
	return lexresult;
}

<*
 skip white spaces in data
 @require self.data  "NULL data"
*>
fn void! Lexer.skip_ws(&self)
{
	
	while (true)
	{
		Lexeme l = self.peek()!;
		if (l.token == EOF) break;
		if (self.data[self.caret] == '\n') self.line++;
		if (l.token == WHITE_SPACE || l.token == LINE_BREAK ) { self.caret++; continue; }
		break;
	}
}

<*
 @require self.data  "NULL data"
*>
fn Lexeme! Lexer.get_id(&self)
{
	usz start = self.caret;

	char cur_char = self.data[self.caret];
	Tkn token = lex_token_table[cur_char];
	if (token != ALPHA && !string::char_in_set(cur_char, self.id_separators) ) return LexError.NOT_ALPHA?;
	while ( true )
	{
		self.caret++;
		if (self.caret == self.data.len) break;
		cur_char = self.data[self.caret];
		token = lex_token_table[cur_char];
		if (token == ALPHA || token == DIGIT) continue;
		if (string::char_in_set(cur_char, self.id_separators)) continue;
		if (token == ERROR) return LexError.ILLEGAL_CHARACTER?;
		break;
	}
	return 	Lexeme
			{
				.token = ID,
				.slice = self.data[start : self.caret-start],
			};
}
