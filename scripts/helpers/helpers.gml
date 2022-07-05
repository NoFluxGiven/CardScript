
function print( ) {
	var input = string(argument[0]);
	var output = input;
	
	for (var i=0;i<argument_count;i++) {
		
		if (i == 0) continue;
		
		if (string_count("%%",output) > 0) {
			
			output = string_replace( output, "%%", string(argument[i]) );
			
			continue;
		}
		
		output = output + string(argument[i]) + "\n";
	}
	
	show_debug_message(output);
}
