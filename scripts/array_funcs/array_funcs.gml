// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function array_filter(array, func){
	
	var new_array = [];
	
	for (var i=0;i<array_length(array);i++) {
		var r = func( array[i] );
		if (r) array_push( new_array, array[i] );
	}

	return new_array;
	
}

function array_map(array, func) {
	var new_array = [];
	
	for (var i=0;i<array_length(array);i++) {
		var r = func( array[i] );
		
		array_push(new_array, r);
	}
	
	return new_array;
}

function array_at(array, value) {
	for (var i=0;i<array_length(array);i++)
	{
		if (array[i] == value) return i;
	}
	return -1;
}

function array_reduce( array, initial, func ) {
	for (var i=0;i<array_length(array);i++) {
		initial = func(initial, array[i]);
	}
	
	return initial;
}

function array_slice(array, s=0, e) {
	var new_array = [];
	e = e == undefined ? array_length( array ) : e;
	array_copy( new_array, 0, array, s, clamp(e-s, 0, array_length(array)) );
	return new_array
}

function array_shuffle( array ) {
	var new_array = [];
	
	var temp_list = ds_list_create();
	
	for (var i=0;i<array_length(array);i++) {
		temp_list[|i] = array[i];
	}
	
	ds_list_shuffle( temp_list );
	
	for (var i=0;i<ds_list_size( temp_list );i++) {
		new_array[i] = temp_list[| i];
	}
	
	ds_list_destroy( temp_list );
	
	return new_array;
}

function array_extend( src, dest ) {
	array_copy( dest, array_length(dest), src, 0, array_length( src ) );
	
	return dest;
}

function array_empty( array ) {
	return array_length( array ) == 0;
}

function array_first( array ) {
	if ( array_length( array ) == 0 ) return undefined;
	return array[ 0 ];
}

function array_last( array ) {
	if ( array_length( array ) == 0 ) return undefined;
	return array[ array_length( array ) - 1 ];
}
