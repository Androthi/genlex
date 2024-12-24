import std::io;

struct Lexer
{
	usz pos;
	char c;
	String data;
}

def LexFn = fn Tkn (Lexer* self);


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

LexFn[256] lex_jump_table =
{
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.white_space, &Lexer.line_break, &Lexer.err, &Lexer.err, &Lexer.line_break, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.white_space, &Lexer.bang, &Lexer.quote, &Lexer.hash, &Lexer.dollar, &Lexer.percent, &Lexer.amper, &Lexer.apost,
	&Lexer.lparen, &Lexer.rparen, &Lexer.asterisk, &Lexer.plus, &Lexer.comma, &Lexer.minus, &Lexer.period, &Lexer.slash,
	&Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit, &Lexer.digit,
	&Lexer.colon, &Lexer.semicolon, &Lexer.less, &Lexer.equal, &Lexer.greater, &Lexer.question, &Lexer.at,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.lbracket, &Lexer.backslash, &Lexer.rbracket, &Lexer.caret, &Lexer.underscore, &Lexer.grave,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha, &Lexer.alpha,
	&Lexer.lbrace, &Lexer.vertbar, &Lexer.rbrace, &Lexer.tilde,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
	&Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err, &Lexer.err,
};

fn Tkn Lexer.rbrace(&self) { return Tkn.RBRACE; }
fn Tkn Lexer.vertbar(&self) { return Tkn.VERTBAR; }
fn Tkn Lexer.lbrace(&self) { return Tkn.LBRACE; }
fn Tkn Lexer.tilde(&self) { return Tkn.TILDE; }
fn Tkn Lexer.grave(&self) { return Tkn.GRAVE; }
fn Tkn Lexer.underscore(&self) { return Tkn.UNDERSCORE; }
fn Tkn Lexer.caret(&self) { return Tkn.CARET; }
fn Tkn Lexer.rbracket(&self) { return Tkn.RBRACKET; }
fn Tkn Lexer.backslash(&self) { return Tkn.BACKSLASH; }
fn Tkn Lexer.lbracket(&self) { return Tkn.LBRACKET; }
fn Tkn Lexer.alpha(&self) { return Tkn.ALPHA; }
fn Tkn Lexer.at(&self) { return Tkn.AT; }
fn Tkn Lexer.question(&self) { return Tkn.QUESTION; }
fn Tkn Lexer.greater(&self) { return Tkn.GREATER; }
fn Tkn Lexer.equal(&self) { return Tkn.EQUAL; }
fn Tkn Lexer.less(&self) { return Tkn.LESS; }
fn Tkn Lexer.semicolon(&self) { return Tkn.SEMICOLON; }
fn Tkn Lexer.colon(&self) { return Tkn.COLON; }
fn Tkn Lexer.digit(&self) { return Tkn.DIGIT; }
fn Tkn Lexer.slash(&self) { return Tkn.SLASH; }
fn Tkn Lexer.period(&self) { return Tkn.PERIOD; }
fn Tkn Lexer.comma(&self) { return Tkn.COMMA; }
fn Tkn Lexer.minus(&self) { return Tkn.MINUS; }
fn Tkn Lexer.plus(&self) { return Tkn.PLUS; }
fn Tkn Lexer.asterisk(&self) { return Tkn.ASTERISK; }
fn Tkn Lexer.rparen(&self) { return Tkn.RPAREN; }
fn Tkn Lexer.hash(&self) { return Tkn.HASH; }
fn Tkn Lexer.dollar(&self) { return Tkn.DOLLAR; }
fn Tkn Lexer.percent(&self) { return Tkn.PERCENT; }
fn Tkn Lexer.amper(&self) { return Tkn.AMPER; }
fn Tkn Lexer.apost(&self) { return Tkn.APOST; }
fn Tkn Lexer.lparen(&self) { return Tkn.LPAREN; }
fn Tkn Lexer.err(&self) { return Tkn.ERROR; }
fn Tkn Lexer.white_space(&self) { return Tkn.WHITE_SPACE; }
fn Tkn Lexer.line_break(&self) { return Tkn.LINE_BREAK; }
fn Tkn Lexer.bang(&self) { return Tkn.BANG; }
fn Tkn Lexer.quote(&self) { return Tkn.QUOTE; }

fn Tkn Lexer.lex(&self)
{
	if (self.pos == self.data.len) return Tkn.EOF;
	self.c = self.data[self.pos++];
	return lex_jump_table[self.c](self);
}

fn Tkn Lexer.peek(&self)
{
	if (self.pos == self.data.len) return Tkn.EOF;
	self.c = self.data[self.pos];
	return lex_jump_table[self.c](self);
}

fn void main()
{
	Lexer p;
	p.data = (String)file::load_new("main.c3")!!;
	p.c = 0;
	p.pos = 0;
	
	Tkn token;

	while( true )
	{
		token = p.lex();
		if( token == Tkn.ERROR || token == Tkn.EOF) break;
		io::printfn("char [%c] token [%s] ", p.c, token);
	}
}