# C3 Lexer Generator

This program generates a lexer based on a command source file that defines which keywords
go in the lexer.

## Generate The Lexer

Create a source file called "gen_source.txt" located in the current folder
The sourcefile consists of commands that are prefexed by a period '.' followed
by an equal followed by the arguments.

Commands:

.module = \<module name\>

The created file will have this module name.

.filepath = \<path\>

The destination of the created file.

.prefix = \<prefix\>

This should be a short prefix which will be used to generate the structures, enums
and keywords. a .prefix section should be followed by a .keywords section.

.keywords =
\<white space separated list of keywords\>

These keywords will go in search trees along with accompanying tokens.

There can be multiple .prefix and .keywords sections. Every .keywords section must be
preceded by a .prefix section.

The resulting c3 file can be imported into your programs to be used as a lexer and
keyword tokenizer.



to use it, create a Lexer object,

```
struct Lexer
{
	String data;
	String id_separators;
	usz caret;
	usz line;
}

Lexer p = Lexer.init((String)file::load_new("main.c3")!!);

```


The return value is a Lexeme object.

```
struct Lexeme
{
	Tkn token;
	char c;
	String slice;
}
```

The return value is an optional containing either an error or a valid Lexeme.

token contains one of the Tkn values.
c is the last character parsed by the lexer.
slice is beginning and length of the token as a string. this will be the same as c as a string for character tokens.
The slice can also be used to find a pointer of the current token in the data being lexed.

## a simple example that lexes a source

```
module example;
import std::io;
import lex; // or whatever you called the generated lexer file.

fn void main()
{
	Lexer p = Lexer.init((String)file::load_new("examples/example.c3")!!);
	defer free(p.data);
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
		io::printfn("char [%c] token [%s] String of :[%s]", l.c, l.token, l.slice);
	}
}
```

Note, if you just want a simple lexer like this, without any keywords, just copy
and rename the lexer_tpl.c3 file. The generator is only necessary if you want
a keyword search added automatically.

## Building the example

The examples folder contains an example program that lexes through C3 keywords

Files:
* example.c3 the executable.
* gen_source.txt the command file to build the lexer

This is what the command file looks like.

```.module = lex
.filepath = lex.c3
.prefix = Ck
.keywords =
	asm			any			anyfault	assert
	attribute	break		nextcase	cast
	catch		const		continue	default
	defer		def 		do 			else
	enum		extern		errtype		false
	fn			generic		if			import
	inline 		macro		module 		
	null		public		return		struct
	switch		true		try 		typeid
	var 		void 		while		bool
	quad 		double 		float 		long
	ulong 		int			uint 		byte
	short 		ushort 		char 		isz
	usz			float16 	float128 	foreach

.prefix = Cc
.keywords = 
	echo 		else 		error 		endfor
	endforeach 	endif		endswitch	for
	foreach 	if 			switch 		typef
	vaarg 		vaconst 	vacount 	varef
	vatype		and 		assert 		case
	default```

To build the example, 1st, build genlexer by running c3c build in the project folder.
```c3c build```

change directory to examples.
run the genlex command in this directory.
```../build/genlexer```

this will create the file "lex.c3" in the examples folder

change directory back to the project folder
run the command:
```c3c run example```

The example program scans it's own source and outputs any C3 keywords that it finds.

