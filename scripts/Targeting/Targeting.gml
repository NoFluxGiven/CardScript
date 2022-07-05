
function FLT_ALL( target_array=[] ) {
	// Override the array with every entity instance
	// This runs to begin with anyway: you will need to filter down to select individual targets
	var array = [];
	
	var num = irandom_range(5, 16);
	
	for (var i=0;i<num;i++) {
		array_push( array, irandom_range(60, 120) );
	}
	
	
	return array;
}

function FLT_MONSTERS( target_array ) {
	// Grab all instances of a monster and return an array of them
	return array_filter( target_array, function( element ) {
		return element >= 100;
	});
}

function FLT_HEROES( target_array ) {
	// Grab all instances of a Hero and return the array
	return array_filter( target_array, function( element ) {
		return element < 100;
	});
}

function FLT_FIRST( target_array ) {
	return target_array[0];
}

function FLT_LAST( target_array ) {
	return target_array[array_length(target_array)-1];
}

function FLT_PICK( target_array, flt_args ) {
	var num = real(flt_args[0]);
	
	return array_slice( target_array, 0, num );
}

function FLT_SHUFFLE( target_array ) {
	return array_shuffle( target_array );
}
