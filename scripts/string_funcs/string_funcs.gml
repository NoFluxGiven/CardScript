// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function string_between(input, open, close){
	var results = [];
	
	var spos = 1;
	var epos = 1;
	
	while (spos > 0 && epos > 0) {
		spos = string_pos_ext( open, input, epos );
		epos = string_pos_ext( close, input, spos+1 );
		
		if (spos > 0 && epos > 0)
			array_push( results, string_copy( input, spos + 1, (epos - spos) - 1 ) );
	}
	
	
	
	return results;

}

function string_explode( input, delim="," ) {
	var pos = 0;
	var pos_next = 0;
	var array = [];
	for (var i=0;i<string_count(delim, input)+1;i++) {
		pos_next = string_pos_ext( delim, input, pos+1 );
		
		if (pos_next == 0)
			pos_next = string_length( input )+1;
		
		array_push( array, string_copy( input, pos+1, (pos_next-pos)-1) );
		
		pos = string_pos_ext( delim, input, pos+1 );
	}
	
	return array;
}

function string_plural( input, singular, plural ) {
	plural = plural == undefined ? singular + "s" : plural;
	return string(input) + ( (abs(input) > 1 || input == 0) ? plural : singular);
}

function string_startswith( input, substr ) {
	return string_pos( substr, input ) == 1;
}

function string_endswith( input, substr ) {
	return string_pos( substr, input ) == string_length(input) - string_length(substr);
}

function string_implode( input, delim=",") {
	var str = "";
	
	for (var i=0;i<array_length(input);i++) {
		str += string(input[i]) + (i < array_length(input) - 1 ? delim : "");
	}
	
	return str;
}

function string_indent( input, spaces ) {
	var istr = string_repeat(" ", spaces);
	return istr + string_replace_all(input, "\n", "\n"+istr);
}
