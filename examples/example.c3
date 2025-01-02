module example;
import std::io;
import lex;

$echo "compiling...";

fn void main()
{
	Lexer p = Lexer.init((String)file::load_new("examples/example.c3")!!);
	defer free(p.data);
	Lexeme! l;
	usz len = p.data.len;
	while ROOT: ( true )
	{
		l = p.peek();

		if( anyfault e = @catch(l))
		{
			io::printfn( "Error Line[%d] :%s", p.line, e);
			break;
		}

		Tkn t = l.token!!;

		switch (t)
		{
			case Tkn.EOF: break ROOT;
			
			case Tkn.WHITE_SPACE:
			case Tkn.LINE_BREAK:
				p.skip_ws()!!;
				continue;

			case Tkn.ID:
				p.caret += l.slice.len!!;
				Ck token = lex::check_keyword (&lex::ck_lens, l.slice)!!;
				if (token != Ck.NO_KEYWORD)
				{
					(void)io::printfn ("Found C3 keyword [%s] %s", token, l.slice);
				}
				break;

			case Tkn.DOLLAR:
				p.caret++;
				l = p.lex()!!;
				t = l.token!!;
				if (t == Tkn.ID)
				{
					Cc token = lex::check_keyword (&lex::cc_lens, l.slice)!!;
					if (token != Cc.NO_KEYWORD)
					{
						(void)io::printfn ("Found C3 compile time keyword [%s] %s", token, l.slice);
					}
				}
				break;

			default:
				p.caret++;
				break;
		};	
		
		//io::printfn("Line[%d] char [%c] token [%s]	String of :[%s]", p.line, l.c, l.token, l.slice)!!;
	}
}
