# C3 Lexer

A simple lexer that tokenizes a source data in the form of a string slice.
Will return individual tokens for all symbols, will return special tokens for digit and alpha characters
Characters not falling in the standard text will return an ILLEGAL_CHARACTER error option.

to use it, create a Lexer object,

struct Lexer
{
	String data;
	usz caret;
}

add a string to the data field, and call the lex or peek methods.

The return value is a Lexeme object.

struct Lexeme
{
	Tkn token;
	char c;
	String slice;
}

The return value is an optional containing either an error or a valid Lexeme.

token contains one of the Tkn values.
c is the last character parsed by the lexer.
slice is beginning and length of the token as a string. this will be the same as c as a string for character tokens.
The slice can also be used to find a pointer of the current token in the data being lexed.