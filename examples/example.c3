module example;
import std::io;
import lex;

$echo "compiling...";

fn void main()
{

	Lexer p = Lexer.init((String)file::load_new("examples/example.c3")!!);
	defer free(p.data);
	Lexeme! l;
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
			case EOF: break ROOT;
			
			case WHITE_SPACE:
			case LINE_BREAK:
				p.skip_ws()!!;
				continue;

			case ID:
				p.caret += l.slice.len!!;  // we do this since peek() doesn't advance the lexing cursor
				Ck token = lex::check_id (Ck, l.slice)!!;
				if (token != NOT_FOUND)
				{
					(void)io::printfn ("Found C3 keyword [%s] %s", token, l.slice);
				}
				break;

			case DOLLAR:
				p.caret++;
				l = p.lex()!!;
				t = l.token!!;
				if (t == ID)
				{
					Cc token = lex::check_id (Cc, l.slice)!!;
					if (token != NOT_FOUND)
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
