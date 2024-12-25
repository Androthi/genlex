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
		if (l.token == Tkn.WHITE_SPACE || l.token == Tkn.LINE_BREAK) p.skip_ws()!!;
		io::printfn("char [%c] token [%s]\n String of :[%s]", l.c, l.token, l.slice);
	}

}