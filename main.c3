import std::io;
import lexer;
import std::core::mem;
import std::collections::list;
import std::sort;

def SortedList = List(<String>);

fn int sort_fn( String left, String right)
{
	if (left == right) return 0;

	for (int i = 0; i < left.len; i++)
	{
		if (left[i] < right[i]) return -1;
		if (left[i] > right[i]) return 1;
	}
  	return 0;
}

const SAM_PLE = 5532_3356;


String[] c3_keywords =
{
	"asm", "any", "anyfault", "assert", "attribute", "break",
	"case", "cast", "catch", "const", "continue", "default",
	"defer", "def", "do", "else", "enum", "extern", "errtype",
	"false", "fn", "generic", "if", "import", "inline", "macro",
	"module", "nextcase", "null", "public", "return", "struct",
	"switch", "true", "try", "typeid", "var", "void", "while",
	"bool", "quad", "double", "float", "long", "ulong", "int",
	"uint", "byte", "short", "ushort", "char", "isz", "usz",
	"float16", "float128", "$and", "$assert", "$case", "$default",
	"$echo", "$else", "$error", "$endfor", "$endforeach", "$endif",
	"$endswitch", "$for", "$foreach", "$if", "$switch", "$typef",
	"$vaarg", "$vaconst", "$vacount", "$varef", "$vatype"
};

// using index from 2 to 16 for lengths. ignore 0 and 1
SortedList[16] keyword_lens;



fn void main()
{
//mem::@report_heap_allocs_in_scope()
//{

	foreach ( item : keyword_lens )
	{
		item.new_init();
	}

	foreach ( item : c3_keywords )
	{
		switch (item.len)
		{
			case 0:
			case 1:
				io::eprintn("keywords < 2 chars not supported");

			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
				keyword_lens[item.len].push( item );

			default:
				io::eprintn("keywords > 15 chars not supported");
		}
	}

	foreach( item : keyword_lens )
	{
		if (item.len() > 2) { quicksort( item, &sort_fn); }
	}

	
	foreach( index, item : keyword_lens )
	{
		io::printfn ("[%d] %s", index, item );
	}

	Lexer p = Lexer.init((String)file::load_new("main.c3")!!);
	defer p.free();


	Lexeme! l;

	while( true )
	{
		l = p.peek();

		if( anyfault e = @catch(l))
		{
			io::printfn( "Error Line[%d] :%s", p.line, e);
			break;
		}

		Tkn t = l.token!!;
		if ( t == Tkn.EOF) break;
		if ( t == Tkn.WHITE_SPACE || t == Tkn.LINE_BREAK)
		{
			p.skip_ws()!!;
			continue;
		}

		// if ( t == Tkn.DIGIT)
		// {
		// 	l = p.get_numeric();
		// 	if( anyfault e = @catch(l))
		// 	{
		// 		io::print( "Error :");
		// 	 	io::printn( e );
		// 		break;
		// 	}

		// 	io::printfn ("Got NUMERIC :%s", l.slice)!!;
		// 	io::printn( l.slice.to_int())!!;
		// }
		if (t == Tkn.ID)
		{
			p.caret += l.slice.len!!;
		} else
		{
			p.caret++;
		}
			

		io::printfn("Line[%d] char [%c] token [%s]	String of :[%s]", p.line, l.c, l.token, l.slice)!!;
	}


	foreach ( item : keyword_lens )
	{
		item.free();
	}
//}; // for leak test
}