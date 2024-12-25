import std::io;
import lexer;


fn void main()
{
	Lexer p;
	p.data = (String)file::load_new("main.c3")!!;
	
	Lexeme! l;

	while( true )
	{
		l = p.lex();
		if (catch excuse = l)
		{
			io::print( "Error :");
			io::printn( excuse );
			break;
		}

		if (l.token == Tkn.EOF) break;
		io::printfn("char [%c] token [%s] ", l.c, l.token);
	}

	p.caret = 200;
	l = p.peek();
	if ( @ok(l)) (void)io::printfn("peek [%c], [%s]", l.c, l.token);
	l = p.lex();
	if ( @ok(l)) (void)io::printfn("lex same [%c], [%s]", l.c, l.token);
}