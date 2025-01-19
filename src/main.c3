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
		io::eprintfn( "Expecting [%c], got [%c]", c, ch);
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

	Buffer word_buffer = buffer::new();
	defer word_buffer.free();

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
				usz loc = dest.cursor_next_line();
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
				enums.appendf( "enum %s : (String id)\n{\n\tNOT_FOUND = \t\t\"not_found\",\n", prefix);
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

				word_buffer.clear();
				source.sub_buffer(start_index, end_index-start_index, &word_buffer)!!;
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
					enums.appendf("\t%s = \t\t\"%s\",\n", estr, item);
				}
				enums.append("}\n\n");

				keyword_lens.clear();
				has_prefix = false;

			case ".newtoken":
				if (!expect ('=')) break SCAN;
				source.span();
				word = source.get_word()!!;
				dest.cursor_to_bof();
				dest.find_next("//#TOKEN")!!;
				usz pt = dest.cursor_next_line();
				dest.insertf (pt, "\t%s,\n", word);

			case ".token":
				if (!expect ('=')) break SCAN;
				source.span();
				word = source.get_word()!!;
				dest.cursor_to_bof();
				DString findword = dstring::temp_new (word);
				defer findword.free();
				findword.append (':');
				if ( try dest.find_next(findword.str_view()))
				{
					dest.find_next (":")!!;
					usz startdel = dest.span();
					usz enddel = dest.cursor_to_eol();
					dest.delete_range( startdel, enddel);

					usz start_index = source.cursor_next_line();
					usz! end_index;
					while (true)
					{
						end_index = source.find_next(".");
						if ( catch e = end_index )
						{
							if (e != BufferError.EOF)
							{
								io::eprintfn("Error %s", e);
								break SCAN;
							}
							end_index = source.len();
							break;
						} else
						{
							if (source.peek_char_at(end_index-2)!! != '\n') continue;
							source.cursor_left(1); // get before '.' so we can find it again in the loop
							break;
						}
					}
					// we have start index and end index of replacement soruce.
					// use the word buffer
					word_buffer.clear();
					source.sub_buffer(start_index, end_index-start_index, &word_buffer)!!;
					dest.insert_char (startdel, '\n');
					dest.insert_buffer (startdel+1, word_buffer);
				}
				else
				{
					io::eprintf ("Could not find token :%s", findword.str_view());
					break SCAN;
				}
				
			default:
				io::eprintfn("unknown command %s", word);
				break SCAN;
		}
	}

	dest.cursor_to_bof();
	dest.find_next("//#ENUM")!!;
	usz loc = dest.cursor_right_lines(2);
	dest.insert_buffer (loc, enums);

	dest.save()!!;

	keyword_lens.free();
//}; // for leak test
}
