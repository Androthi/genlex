<* 
	this is a general purpose prototyping module used for parsing and creating files.
	contains methods for adding and deleting data into the buffer, tokenizing, cursor movements,
	file i/o, varisous search, replace methods.
	Buffer uses dynamic memory, all insertion methods will resize the buffer as needed.
*>
module buffer;
import std::io;
import std::io::file;
import std::core::string;
import cset;


distinct Buffer (OutStream) = void*;
distinct Cset = String;

const usz MIN_CAPACITY @private = 16;
const usz DEFAULT_CAPACITY @private = 4096;

const CSet DELIMITERS = cset::make_ascii_cset (" \t\n\r`~!@#$%^&*()_-=+[{}]\\|;:'\",<.>/?");

fault BufferError
{
	NULL_BUFFER,
	NO_FILENAME,
	SAVE_FAILED,
	INDEX_OUT_OF_RANGE,
	OPERATION_FAILED,
	NO_WORD,
	EOF,
}

struct BufferData @private
{
	Allocator allocator;
	usz len;
	usz capacity;
	usz cursor;
	String filepath;
	char[*] chars;
}

//+ Init/Memory methods =======================================================

<*
	Allocate memory for a new Buffer object. Panics if allocation fails
	@require !self.data() "Buffer already initialized"
	@param capacity `desired capacity for buffer, default = DEFAULT_CAPACITY`
	@param allocator `the allocator to use`
	@return `the allocated Buffer object`
*>
fn Buffer Buffer.new_init(&self, usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())
{
	if (capacity < MIN_CAPACITY) capacity = MIN_CAPACITY;
	BufferData* data = allocator::alloc_with_padding(allocator, BufferData, capacity)!!;
	data.allocator = allocator;
	data.len = 0;
	data.capacity = capacity;
	data.cursor = 0;
	data.filepath = String{};
	return *self = (Buffer)data;
}

<*
	calls new_init with temp allocator.
	@require !self.data() "Buffer already initialized"
*>
fn Buffer Buffer.temp_init(&self, usz capacity = DEFAULT_CAPACITY)
{
	self.new_init(capacity, allocator::temp()) @inline;
	return *self;
}

<*
	function call for new object
*>
fn Buffer new(usz capacity = DEFAULT_CAPACITY, Allocator allocator = allocator::heap())
{
	return Buffer{}.new_init(capacity, allocator);
}

<*
	function call for new temp object
*>
fn Buffer temp_new(usz capacity = DEFAULT_CAPACITY) => new(capacity, allocator::temp()) @inline;

<*
	will attempt to create a new buffer object and load the contents of filepath.
	if the file does not exits, an empty buffer is created with the filepath and default capacity.
*>
fn Buffer new_file(String filepath, Allocator allocator = allocator::heap())
{
	usz len = file::get_size(filepath) ?? DEFAULT_CAPACITY;
	Buffer buf = Buffer{}.new_init(len, allocator);
	buf.open_file(filepath);
	return buf;
}

<*
	same as new_file, using the temp allocator
*>
fn Buffer temp_file(String filepath) => new_file (filepath, allocator::temp() ) @inline;

<*
	sets a new internal filepath for this object.
	this is the file created with the save() method.
*>
fn void Buffer.set_filepath(&self, String filepath)
{
	if (!*self) *self = new();
	BufferData* data = self.data();
	data.filepath = filepath;
}

<*
	tries to open the file filepath and load it into the buffer.
	filepath is set as the internal filename for the buffer.
	this will replace existing content in the buffer.
	use append_file() to keep the contents of the buffer.
*>
fn void Buffer.open_file(&self, String filepath)
{
	usz len = file::get_size(filepath) ?? 0;
	BufferData* data = self.data();
	if(len)
	{
		self.reserve(len);
		data.len = file::load_buffer(filepath, data.chars[:len]).len ?? 0;
	}
	data.filepath = filepath;
}

<*
	will try to open filepath and append it at the end of the buffer.
	this macro is a wrapper around insert_file method.
*>
macro void Buffer.append_file(&self, String filepath)
{
	self.insert_file(self.len(), filepath);
}

<*
	tries to insert a file at the given index.
	if tere is no filepath specified for the buffer, sets filepath as the buffer's filepath.
*>
fn void Buffer.insert_file(&self, usz index, String filepath)
{
	if (!filepath) return;
	usz file_len = file::get_size(filepath) ?? 0;
	self.reserve(file_len);
	BufferData* data = self.data();
	if (data.filepath.len == 0) data.filepath = filepath;
	if (file_len == 0) return;
	usz len = data.len;
	index = min(index, len);
	self.adjust_for_insert (index, file_len);
	data.len += file::load_buffer(filepath, data.chars[index:file_len]).len ?? 0;
}

<*
	free memory of buffer
*>
fn void Buffer.free(&self)
{
	if (!*self) return;
	BufferData* data = self.data();
	if (!data) return;
	allocator::free(data.allocator, data);
	*self = (Buffer)null;
}

<*
	private method to reserve addition amount of bytes in the buffer memory.
*>
fn void Buffer.reserve(&self, usz addition) @private
{
	BufferData* data = self.data();
	if (!data)
	{
		*self = buffer::new(addition);
		return;
	}
	usz len = data.len + addition;
	if (data.capacity >= len) return;
	usz new_capacity = data.capacity * 2;
	if (new_capacity < MIN_CAPACITY) new_capacity = MIN_CAPACITY;
	while (new_capacity < len) new_capacity *= 2;
	data.capacity = new_capacity;
	*self = (Buffer)allocator::realloc(data.allocator, data, BufferData.sizeof + new_capacity);
}

// NOTE important: adjust data.len *after* calling adjust_for_insert
// TODO: modify data.len here, need to fix every method that calls this
// so that data.len isn't adjusted twice.
<*
	private helper metod for creating a len amount of space at index for
	inserting new data.
*>
fn void Buffer.adjust_for_insert(&self, usz index, usz len) @private
{
	BufferData* data = self.data();
	if (index == data.len) return; // we are at EOF, nothing to move
	char* start = &data.chars[index];
	mem::move (start + len, start, self.len() - index);
}

//+ File saving methods =======================================================

<*
	saves te contents of the buffer to a file using the internal buffer filepath.
	returns error if there is no internal filepath set.
	returns NULL_BUFFER, SAVE_FAILED and NO_FILENAME errors.
*>
fn void! Buffer.save(&self)
{
	BufferData* data = self.data();
	if (!data) return BufferError.NULL_BUFFER?;
	if (data.filepath.len == 0) return BufferError.NO_FILENAME?;
	if ( catch error = file::save(data.filepath, data.chars[0:data.len])) return BufferError.SAVE_FAILED?;
}

<*
	saves te contents of the buffer to a file using filepath.
	the internal buffer filepath name is set to filepath.
	returns error if there is no internal filepath set.
	returns NULL_BUFFER, SAVE_FAILED and NO_FILENAM errors.
*>
fn void! Buffer.save_as(&self, String filepath)
{
	BufferData*data = self.data();
	if (!data) return BufferError.NULL_BUFFER?;
	data.filepath = filepath;
	self.save()!;
}

//+ Info/View/Maintenence methods =============================================

<*
	private method
	@return `a pointer to the buffer data`
*>
fn BufferData* Buffer.data(self) @inline @private
{
	return (BufferData*)self;
}

<*
	@return `the capacity of buffer`
*>
fn usz Buffer.capacity(self)
{
	if (!self) return 0;
	return self.data().capacity;
}

<*
	@return `the filepath that is set for this buffer`
*>
fn String Buffer.get_filepath(self)
{
	BufferData* data = self.data();
	return self.data().filepath;
}

<*
	@return `the length of buffer`
*>
fn usz Buffer.len(&self) @dynamic
{
	if (!*self) return 0;
	return self.data().len;
}

<*
	@return `a string slice of buffer contents`
*>
fn String Buffer.str_view(self)
{
	BufferData* data = self.data();
	if (!data) return "";
	return (String)data.chars[:data.len];
}

<*
	@return `a zstring pointer of buffer contents. buffer is modified with a 0 at the end`
*>
fn ZString Buffer.zstr_view(&self)
{
	BufferData* data = self.data();
	if (!data) return "";
	if (data.capacity == data.len)
	{
		self.reserve(1);
		data = self.data();
		data.chars[data.len] = 0;
	}
	else if (data.chars[data.len] != 0)
	{
		data.chars[data.len] = 0;
	}
	return (ZString)&data.chars[0];
}

<*
	clears the contents of the buffer, does not reallocate memory.
*>
fn void Buffer.clear(self)
{
	if (!self) return;
	self.data().len = 0;
	self.data().cursor = 0;
}

<*
	@require new_size <= self.len()
*>
fn void Buffer.chop(self, usz new_size)
{
	if (!self) return;
	self.data().len = new_size;
}
