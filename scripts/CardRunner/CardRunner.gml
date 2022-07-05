function CardRunner() constructor {
	
	session = {
		special_vars: {}
	};
	
	eventPointer = 0;
	
	// SINGLETON
	
	function setSpecialVar( name, val ) {
		session.special_vars[$ name] = val;
		return self;
	}
	
	function parseEvent( card, _event ) {
		var eventArray = card.effects[$ _event];
		
		var calls = [];
		
		for (eventPointer=0;eventPointer<array_length(eventArray);eventPointer++) {
			
			var current = eventArray[eventPointer];
			var next = (eventPointer + 1) < array_length( eventArray ) ? eventArray[eventPointer+1] : undefined;
			
			if ( is_array( current ) ) continue; // skip block
			
			var block = [];
			
			if (is_array(next)) {
				block = next;
			}
			
			var c = parseLine( card, current );
				
			if (c == undefined) break;
			
			print( "RUNNER\n  Line: %%\n  Block: %%\n", string( eventArray[ eventPointer ]), string( block ) );
			
			runLine( self, c, card, block );
		}
		
		show_debug_message(_event+ ": Run complete.");
		
		if ( eventPointer < array_length(eventArray) ) {
			show_debug_message(_event+": Run finished before reaching the end of the block, at step "+string(eventPointer)+" ("+string(eventArray[eventPointer])+").")
		}
	}
	
	function parseLine( card, input ) {
		input = getParsedText( card, input );
		
		var le = string_explode( input, " " );
		
		var funcName = string_upper(le[0]);
		
		var funcStruct = getCF( funcName );
		
		if (funcStruct == undefined) {
			print("PARSER - Can't find function "+funcName+".");
			return undefined;
		}
		
		var func = funcStruct[$ "func"];
		
		if (func == undefined) {
			print("PARSER - Failed parsing line \""+input+"\"." );
			return undefined;
		}
			
		// Returns a value, casting it to a special $variable
		var ret = array_at( le, "->" );
		var cast = undefined;
		
		if (ret) cast = le[ret+1] else ret = array_length( le );
		
		var func_args = array_slice( le, 0, ret );
		
		// iterate array args to convert $values
		
		func_args = array_map( func_args, function( _x ) {
			if (string_char_at(_x, 1) == "$") {
				var value = session.special_vars[$ _x];
				
				if value == undefined return _x;
				
				return value;
			}
			
			return _x;
		});
		
		return { func: func, args: func_args, cast: cast }
	}
	
	function runLine( cr, s, card, block ) {
		var r = s.func( cr, s.args, card, block );
		show_debug_message("RUN: "+string(s.args));
		
		if (s.cast != undefined)
			setSpecialVar( s.cast, r );
	}

}