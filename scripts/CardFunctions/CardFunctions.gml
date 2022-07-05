function CardFunctionManager() constructor {
	cardFunctions = {};
	static add = function( _funcstr,  _help, _func, _validators ) {
		var funcarr = string_explode(_funcstr, " ");
		var _name = funcarr[0];
		var _args = array_slice( funcarr, 1 );
		
		var _arg_min = array_reduce( _args, 0, function(val, _x) {
			
			if (array_length(string_between(_x, "[", "]")) > 0) return val;
			
			return val + 1;
			
		});
		
		var _arg_max = array_reduce( _args, 0, function(val, _x) {
			if (string_count("...",_x) > 0) return -1;
			
			return val + 1;
		});
		
		cardFunctions[$ _name] = {
			func: _func,
			args: _args,
			validators: _validators,
			arg_min: _arg_min,
			arg_max: _arg_max,
			help: _help
		}
		
		return self;
	}
	
	static get = function( _name ) {
		return cardFunctions[$ _name];
	}
}

#macro CF global.card_functions

global.card_functions = new CardFunctionManager();

CF
	.add(
		"TARGET [filters...]",
		{
			basic: "Defines the target or targets to act upon. MUST be cast to a variable, and should be the first node.",
			advanced:[
			"Filters function in a step-by-step sense, limiting manual input automatically. For instance, when using the following:",
			"TARGET MONSTERS CCAREA(1)",
			"The player can select ONLY Cells with monsters occupying them, as the engine would search for ",
			"any monsters, then show valid Cells.",
			"If we swap this:",
			"TARGET CCAREA(1) MONSTERS",
			"We can now target any cell occupied by an entity, but will only AFFECT monsters.",
			"By default, the CELL, CCAREA, SQAREA and DEFAREA filters allow targeting any cells within the filter context.",
			"They also override the filter context after that point.",
			"As you can see, by placing the spatial filter BEFORE any filter context is added, we make it simple to restrict the ",
			"effects, whereas AFTER restricts the selection.",
			"What if we want to affect everything in that area?",
			"TARGET MONSTERS CCAREA(1) HEROES&MONSTERS",
			"This means we can select only cells occupied by monsters, but the effects will propagate to Heroes AND monsters within the range.",
			"We can use the & operator to combine filters, adding together their results.",
			"We can also use the -/+ operators to do something similar:",
			"TARGET MONSTERS -STAT(HP_PERCENT) < 25",
			"This removes any monsters from the list that are below 25% HP.",
			"Multiple targeting steps can be taken to perform more advanced filtering.",
			"For instance:",
			"TARGET MONSTERS CCAREA(1)",
			"This will ONLY allow selection of monsters, and will only affect monsters.",
			"What if we want to affect heroes as well?",
			"TARGET LIMIT MONSTERS CCAREA(1) -> $target"
			],
			contents: {
				filters: {
					ALL: "By default, ALL targetable entities are filtered, including Monsters, Heroes, Items, Enchantments and Cells.",
					MONSTERS: "Filters for any monsters.",
					HEROES: "Filters for any Heroes.",
					PICK: "PICK(N): Picks the Nth entry of the list.",
					FIRST: "FIRST: Picks the first entry of the list.",
					LAST: "LAST: Picks the last entry of the list.",
					SHUFFLE: "SHUFFLE: Shuffles the list order.",
					SELECT: "SELECT(N,[MIN=N]): Allows the player to select up to N entities in the list, to a minimum of MIN.",
					CELL: "CELL: Allows the player to select a board cell, of which any occupying entities the list is filtered to.",
					SQAREA: "SQAREA(N,[MIN=N]): Allows the player to select an area of board cells, up to N squares, with a minimum of MIN squares, in a square shape.",
					CCAREA: "CCAREA(N,[MIN=N]): Like SQAREA, but in the shape of a circle.",
					DEFAREA: "DEFAREA(NAME): Selects an area based on an area definition found in area_definitions.yaml.",
					INVERT: "INVERT: Inverts the selection, selecting all targetable entities that are NOT in the list."
					
				}
			}
			
		},
		function( cr, args ) {
			var targets = FLT_ALL(  );
	
			var FUNC, ARG;
	
			FUNC = 0;
			ARG = 1;
	
			var parseType = FUNC;
	
			for (var i=1;i<array_length(args);i++) {
				var flt = args[i];
				var flt_args = string_between( flt,  "(", ")" );
				var has_args = false;
		
				// Has args
		
				if (array_length(flt_args) > 0) {
					flt_args = flt_args[0];
					flt = string_replace(flt, "("+flt_args+")", "");
					flt_args = string_explode( flt_args, "," );
			
					has_args = true;
				}
		
				var fltFunc = asset_get_index( "FLT_"+flt );
		
				if (fltFunc == -1)
					continue;
			
				targets = fltFunc( targets, flt_args );
			}
	
			return targets;
		},
		[
			{
				rule: VLD_RULE.REQUIRE,
				conditions: [
					VLD_MOD.AND,
					[
						VLD_COND.CASTS_TO_VARIABLE
					]
				]
			},
			{
				rule: VLD_RULE.RECOMMEND,
				conditions: [
					VLD_MOD.AND,
					[
						VLD_COND.IS_FIRST_NODE,
					]
				]
			}
		]
	)
	
	.add(
		"EACH array cast_to",
		"Iterates through each element of the array, casting that element to the \"cast_to\" variable specified."+
		"\n"+
		"Often used for targeting.",
		function( cr, args, card, block ) {
			var array = args[1];
			var cast = args[2];
	
			var n = 0;
			var nn = 0;
	
			while (n < array_length( array ) ) {
				cr.setSpecialVar( cast, array[n] );
				while (nn < array_length( block )) {
					var c = cr.parseLine( card, block[nn] );
		
					try {
						cr.runLine( cr, c, card, block );
					} catch (err) {
						//show_debug_message(err);
					}
		
					nn ++;
				}
				nn = 0;
				n ++;
			}
		},
		[
			{
				rule: VLD_RULE.REQUIRE,
				conditions: [
					VLD_MOD.AND,
					[
						VLD_COND.FOLLOWED_BY_BLOCK
					]
				]
			}
		]
	)

function getCF( name ) {
	return CF.cardFunctions[$ name];
}
