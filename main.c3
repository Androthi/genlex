import std::io;
import lexer;

fn void main()
{
//mem::@report_heap_allocs_in_scope()
//{
	Lexer p;
	p.data = (String)file::load_new("main.c3")!!;
	defer free(p.data);

	Lexeme! l;

	while( true )
	{
		l = p.peek();
		if (catch excuse = l)
		{
			io::print( "Error :");
			io::printn( excuse );
			break;
		}

		if (l.token == Tkn.EOF) break;
		if (l.token == Tkn.WHITE_SPACE || l.token == Tkn.LINE_BREAK)
		{
			p.skip_ws()!!;
			continue;
		}
		if (l.token == Tkn.DIGIT)
		{
			Lexeme! l200 = p.get_numeric();
			if( catch excuse = l200)
			{
				io::print( "Error :");
				io::printn( excuse );
				break;
			}
			io::printfn ("Got NUMERIC :%s", l200.slice);
			(void)io::printn( l200.slice.to_int());
		}
		p.caret++;
	

		io::printfn("char [%c] token [%s]\n String of :[%s]", l.c, l.token, l.slice);
	}

	
//}; // for leak test
}