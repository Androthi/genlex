module genlexer;
import std::io;
import buffer;
import std::collections::list;

String main_file = $embed("lexer_tpl.c3");

def WordList = List(<String>);

fn bool expect (char c)
{
	source.span();
	char ch = source.get_char()!!;
	if (ch != c) 
	{
		io::eprintfn( "Expecting :%c", c);
		return false;
	}
	return true;
}

Buffer source;

fn void main()
{

//mem::@report_heap_allocs_in_scope()
//{

	String prefix;
	String prefix_lc;

	WordList keyword_lens;
	defer keyword_lens.free();
	keyword_lens.new_init();

	Buffer dest = buffer::new();
	defer dest.free();
	dest.append (main_file);
	dest.set_filepath("lexer.c3"); // default file path

	source = buffer::new_file("gen_source.txt");
	defer source.free();

	if (source.len() == 0)
	{
		io::eprintfn ("Expecting a file called 'gen_source.txt' in current directory");
		return;
	}

	Buffer work = buffer::new();
	defer work.free();

	Buffer enums = buffer::new();
	defer enums.free();

	bool has_prefix = false;
	while SCAN: (!source.is_eof())
	{
		usz! index = source.find_next(".");
		if (catch e = index) break; //no more commands

		String word = source.get_word()!!;
		switch (word)
		{
			case ".module":
				if (!expect ('=')) break SCAN;
				source.span();
				word = source.get_word()!!;
				dest.cursor_to_bof();
				dest.find_next("//#MOD")!!;
				usz loc = dest.cursor_right_lines(2);
				dest.delete_range (loc, dest.cursor_to_eol());
				dest.insertf (loc, "module %s;\n", word);

			case ".filepath":
				if (!expect ('=')) break SCAN;
				source.span();
				word = source.get_word()!!;
				dest.set_filepath(word);

			case ".prefix":
				if (has_prefix){
					io::eprintf("already have prefix declared. need to follow with .keywords\nbefore another .prefix can be declared\n");
					break SCAN;
				}
				if (!expect ('=')) break SCAN;
				source.span();
				word = source.get_word()!!;
				prefix = word;
				prefix_lc = prefix.temp_ascii_to_lower();
				enums.appendf( "struct %s_s\n{\n\tString\tname;\n\t%s\ttoken;\n}\n\n", prefix, prefix);
				enums.appendf( "enum %s\n{\n\tNO_KEYWORD,\n", prefix);
				work.appendf ("%s_s[] %s_lens = \n{\n", prefix, prefix_lc);
				work.appendf ("\t{\"\",\t%s.NO_KEYWORD},\n", prefix);
				has_prefix = true;

			case ".keywords":
				if (!has_prefix){
					io::eprintfn("a .prefix needs to be declared before .keywords");
					break SCAN;
				}
				if (!expect ('=')) break SCAN;
				usz start_index = source.span();
				usz! end_index = source.find_next(".");
				if ( catch e = end_index )
				{
					if (e != BufferError.EOF)
					{
						io::eprintfn("Error %s", e);
						break SCAN;
					}
					end_index = source.len();
				} else
				{
					source.cursor_left(1); // get before '.' so we can find it again in the loop
				}

				Buffer word_buffer = source.new_sub_buffer(start_index, end_index-start_index, allocator::temp())!!;
				while (!word_buffer.is_eof())
				{
					word_buffer.span();
					if (word_buffer.is_eof()) break;
					word = word_buffer.get_word()!!;
					if (word.len < 2)
					{
						io::eprintfn ("word lengths must be at least 2 characters");
						break SCAN;
					}
					keyword_lens.push (word);
				}

				foreach(item : keyword_lens )
				{
					String estr = string::tformat("%s", item);
					estr.convert_ascii_to_upper();
					work.appendf("\t{\"%s\",\t\t%s.%s},\n", item, prefix, estr);
					enums.appendf("\t%s,\n", estr);
				}
				work.append("};\n\n");
				enums.append("}\n\n");

				keyword_lens.clear();
				has_prefix = false;

			default:
				io::eprintfn("unknown command %s", word);
				break SCAN;
		}
	}

	dest.cursor_to_bof();
	dest.find_next("//#DATA")!!;
	usz loc = dest.cursor_right_lines(2);
	dest.insert_buffer (loc, work);

	dest.cursor_to_bof();
	dest.find_next("//#ENUM")!!;
	loc = dest.cursor_right_lines(2);
	dest.insert_buffer (loc, enums);

	dest.save()!!;

	keyword_lens.free();
//}; // for leak test
}
