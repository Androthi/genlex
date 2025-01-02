module my_lex;

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
struct Foo_s
{
	String	name;
	Foo	token;
}

enum Foo
{
	NO_KEYWORD,
	ASM,
	ANY,
	ANYFAULT,
	ASSERT,
	ATTRIBUTE,
	BREAK,
	NEXTCASE,
	CAST,
	CATCH,
	CONST,
	CONTINUE,
	DEFAULT,
	DEFER,
	DEF,
	DO,
	ELSE,
	ENUM,
	EXTERN,
	ERRTYPE,
	FALSE,
	FN,
	GENERIC,
	IF,
	IMPORT,
	INLINE,
	MACRO,
	MODULE,
	NULL,
	PUBLIC,
	RETURN,
	STRUCT,
	SWITCH,
	TRUE,
	TRY,
	TYPEID,
	VAR,
	VOID,
	WHILE,
	BOOL,
	QUAD,
	DOUBLE,
	FLOAT,
	LONG,
	ULONG,
	INT,
	UINT,
	BYTE,
	SHORT,
	USHORT,
	CHAR,
	ISZ,
	USZ,
	FLOAT16,
	FLOAT128,
	FOREACH,
}

struct Baz_s
{
	String	name;
	Baz	token;
}

enum Baz
{
	NO_KEYWORD,
	ECHO,
	ELSE,
	ERROR,
	ENDFOR,
	ENDFOREACH,
	ENDIF,
	ENDSWITCH,
	FOR,
	FOREACH,
	IF,
	SWITCH,
	TYPEF,
	VAARG,
	VACONST,
	VACOUNT,
	VAREF,
	VATYPE,
	AND,
	ASSERT,
	CASE,
	DEFAULT,
}


//#DATA
Foo_s[] foo_lens = 
{
	{"",	Foo.NO_KEYWORD},
	{"asm",		Foo.ASM},
	{"any",		Foo.ANY},
	{"anyfault",		Foo.ANYFAULT},
	{"assert",		Foo.ASSERT},
	{"attribute",		Foo.ATTRIBUTE},
	{"break",		Foo.BREAK},
	{"nextcase",		Foo.NEXTCASE},
	{"cast",		Foo.CAST},
	{"catch",		Foo.CATCH},
	{"const",		Foo.CONST},
	{"continue",		Foo.CONTINUE},
	{"default",		Foo.DEFAULT},
	{"defer",		Foo.DEFER},
	{"def",		Foo.DEF},
	{"do",		Foo.DO},
	{"else",		Foo.ELSE},
	{"enum",		Foo.ENUM},
	{"extern",		Foo.EXTERN},
	{"errtype",		Foo.ERRTYPE},
	{"false",		Foo.FALSE},
	{"fn",		Foo.FN},
	{"generic",		Foo.GENERIC},
	{"if",		Foo.IF},
	{"import",		Foo.IMPORT},
	{"inline",		Foo.INLINE},
	{"macro",		Foo.MACRO},
	{"module",		Foo.MODULE},
	{"null",		Foo.NULL},
	{"public",		Foo.PUBLIC},
	{"return",		Foo.RETURN},
	{"struct",		Foo.STRUCT},
	{"switch",		Foo.SWITCH},
	{"true",		Foo.TRUE},
	{"try",		Foo.TRY},
	{"typeid",		Foo.TYPEID},
	{"var",		Foo.VAR},
	{"void",		Foo.VOID},
	{"while",		Foo.WHILE},
	{"bool",		Foo.BOOL},
	{"quad",		Foo.QUAD},
	{"double",		Foo.DOUBLE},
	{"float",		Foo.FLOAT},
	{"long",		Foo.LONG},
	{"ulong",		Foo.ULONG},
	{"int",		Foo.INT},
	{"uint",		Foo.UINT},
	{"byte",		Foo.BYTE},
	{"short",		Foo.SHORT},
	{"ushort",		Foo.USHORT},
	{"char",		Foo.CHAR},
	{"isz",		Foo.ISZ},
	{"usz",		Foo.USZ},
	{"float16",		Foo.FLOAT16},
	{"float128",		Foo.FLOAT128},
	{"foreach",		Foo.FOREACH},
};

Baz_s[] baz_lens = 
{
	{"",	Baz.NO_KEYWORD},
	{"echo",		Baz.ECHO},
	{"else",		Baz.ELSE},
	{"error",		Baz.ERROR},
	{"endfor",		Baz.ENDFOR},
	{"endforeach",		Baz.ENDFOREACH},
	{"endif",		Baz.ENDIF},
	{"endswitch",		Baz.ENDSWITCH},
	{"for",		Baz.FOR},
	{"foreach",		Baz.FOREACH},
	{"if",		Baz.IF},
	{"switch",		Baz.SWITCH},
	{"typef",		Baz.TYPEF},
	{"vaarg",		Baz.VAARG},
	{"vaconst",		Baz.VACONST},
	{"vacount",		Baz.VACOUNT},
	{"varef",		Baz.VAREF},
	{"vatype",		Baz.VATYPE},
	{"and",		Baz.AND},
	{"assert",		Baz.ASSERT},
	{"case",		Baz.CASE},
	{"default",		Baz.DEFAULT},
};



macro check_keyword( $arr, String s )
{
	foreach (item : $arr )
	{
		//io::printn( item.kw);
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
					.token = Tkn.EOF
				};
	}

	char cur_char = self.data[self.caret];
	Tkn token = lex_token_table[cur_char];
	if (token == Tkn.ERROR) return LexError.ILLEGAL_CHARACTER?;
	if (cur_char == '\n') self.line++;
	if (token == Tkn.ALPHA) return self.get_id();

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
		if (self.data[self.caret] == '\n') self.line++;
		if (l.token == Tkn.WHITE_SPACE || l.token == Tkn.LINE_BREAK ) { self.caret++; continue; }
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
	if (token != Tkn.ALPHA && !string::char_in_set(cur_char, self.id_separators) ) return LexError.NOT_ALPHA?;
	while ( true )
	{
		self.caret++;
		if (self.caret == self.data.len) break;
		cur_char = self.data[self.caret];
		token = lex_token_table[cur_char];
		if (token == Tkn.ALPHA) continue;
		if (string::char_in_set(cur_char, self.id_separators)) continue;
		if (token == Tkn.ERROR) return LexError.ILLEGAL_CHARACTER?;
		break;
	}
	return 	Lexeme
			{
				.token = Tkn.ID,
				.slice = self.data[start : self.caret-start],
			};
}
