<*
	This file is auto-generated.
	Any changes will be lost next time it is regenerated.
*>
//#MOD
module lexer;
import std::io;
import std::sort;

const JUMP_TOKEN_LEN = 50;

enum Tkn
{
	ERROR,
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
	BACKSLASH,
	RBRACKET,
	CARET,
	UNDERSCORE,
	GRAVE,
	LBRACE,
	VERTBAR,
	RBRACE,
	TILDE,
	//#END OF JUMP TOKEN LEN

	// non-table tokens, and custom tokens added below
	ID,
	EOF,
	//#TOKEN

}

//#ENUM

macro check_id( $Type, String s )
{
    return ($Type)@enum_from_value( $Type, id, s) ?? $Type.NOT_FOUND;
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

fn Lexer Lexer.init (String data = {}, String id_separators = "_") @operator(construct)
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


fn Lexeme! Lexer.lex(&self)
{
	usz caret = self.caret;
	if (caret == self.data.len || self.data.len == 0)
	{
		return	Lexeme
				{
					.token = EOF
				};
	}

	char cur_char = self.data[self.caret];
	Tkn token = lex_token_table[cur_char];
	if (cur_char == '\n') self.line++;

	switch (token) @jump
	{
		case ERROR:	return LexError.ILLEGAL_CHARACTER?;

		case WHITE_SPACE: nextcase default;

		case LINE_BREAK: nextcase default;

		case BANG: nextcase default;

		case QUOTE: nextcase default;

		case HASH: nextcase default;

		case DOLLAR: nextcase default;

		case PERCENT: nextcase default;

		case AMPER: nextcase default;

		case APOST: nextcase default;

		case LPAREN: nextcase default;

		case RPAREN: nextcase default;

		case ASTERISK: nextcase default;

		case PLUS: nextcase default;

		case COMMA: nextcase default;

		case MINUS: nextcase default;

		case PERIOD: nextcase default;

		case SLASH: nextcase default;

		case DIGIT: nextcase default;

		case COLON: nextcase default;

		case SEMICOLON: nextcase default;

		case LESS: nextcase default;

		case EQUAL: nextcase default;

		case GREATER: nextcase default;

		case QUESTION: nextcase default;

		case AT: nextcase default;

		case ALPHA: return self.get_id();

		case LBRACKET: nextcase default;

		case BACKSLASH: nextcase default;

		case RBRACKET: nextcase default;

		case CARET: nextcase default;

		case UNDERSCORE: nextcase default;

		case GRAVE: nextcase default;

		case LBRACE: nextcase default;

		case VERTBAR: nextcase default;

		case RBRACE: nextcase default;

		case TILDE: nextcase default;

		default:
			self.caret++;
			return	Lexeme
			{
				.token = token,
				.c = cur_char,
				.slice = self.data[caret:1],
			};
	}
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
