function pth( ) {
	var str = "";
	
	for (var i=0;i<argument_count;i++)
	{
		var delim = (argument_count - 1) == i ? "" : "\\";
		str += argument[i] + delim;
	}
	
	return str;
}

function File( path ) {
	return new __File( path );
}

function __File( path, readContents = true ) constructor {
	self.path = path;
	
	self.text = "";
	self.data = undefined;
	
	static read = function() {
		try {
			var f = file_text_open_read( path );
			var str = "";
			
			while (!file_text_eof( f )) {
				str += file_text_read_string( f ) + "\n";
				file_text_readln( f );
			}
			file_text_close( f );
			
			text = str;
		} catch (err) {
			show_debug_message( "WARNING -> " + (!file_exists( path ) ? "Nonexistent file." : "File exists, but couldn't be read.") );
			show_debug_message( "ERROR LOG -> " + err.message );
		}
		
		return self;
	}
	
	static write = function( _text=text ) {
		try {
			var f = file_text_open_write( path );
			file_text_write_string( f, _text );
			text = _text;
			file_text_close( f );
		} catch (err) {
			var ro = file_attributes( path, fa_readonly );
			show_debug_message( "WARNING -> File could not be written to, " + ro ? "read only." : "not read only." );
			show_debug_message( "ERROR LOG -> " + err.message );
		}
		
		return self;
	}
	
	static updateText = function( _text ) {
		self.text = _text;
		return self;
	}
	
	// Auto-read contents
	if (readContents) read();
	
	////////////////////////////////////////////////////////////////////////////////////
	// DATA TRANSFORM METHODS
	////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////
	// Add new ones here for various platforms that work with files.
	////////////////////////////////////////////////////////////////////////////////////
	
	static fromJson = function( ) {
		var j = snap_from_json( text );
		data = j;
		return j;
	}
	
	static fromYaml = function( ) {
		var d = snap_from_yaml( text );
		data = d;
		return d;
	}
}
