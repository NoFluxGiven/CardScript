
enum VLD_RULE {
	REQUIRE, // error
	RECOMMEND //  warning
}

enum VLD_COND {
	EXISTS = 1,
	IS_FIRST_NODE = 2,
	IS_LAST_NODE = 3,
	FOLLOWED_BY_BLOCK = 4,
	CASTS_TO_VARIABLE = 5
}

enum VLD_MOD {
	AND,
	OR
}

enum VLD_RES {
	FAILURE = 0,
	WARNING = 1,
	SUCCESS = 2
}

#macro VALIDATOR global.validator

global.validator = new Validator();

function buildValidation( str ) {
	// "RULE AND/OR: [CONDITION1 CONDITION2...]"
	
	//"REQUIRED AND: IS_FIRST_NODE FOLLOWED_BY_BLOCK"
	
	var arr = string_explode( str, " " );
	
	var rule = arr[0];
	
	var modifier = arr[1];
	
	var conditions = array_slice( arr, 2 );
}

function formatValidationMessage( msg, req, inv, _x, __x ) {
	
	var reqstr = req == VLD_RULE.RECOMMEND ? "<~> Recommended " : "<!> Required ";
	
	var invstr = inv ? " NOT " : " ";
	
	msg = string_replace_all( msg, "??", reqstr );
	msg = string_replace_all( msg, "~~", invstr );
	
	msg = string_indent("AT node "+string(__x)+":\n\""+string(_x)+"\"\n" + msg, 4);
	
	return msg;
}

function ValidatorResult(array, index, type=VLD_RES.SUCCESS) constructor {
	self.array = array;
	self.index = index;
	self.type = type;
	
	self.messages = [];
	
	self.warnings = 0;
	self.failures = 0;
	self.successes = 0;
	
	static msg = function( msg, req, inv, array, index ) {
		if (req == undefined && inv == undefined && array == undefined && index == undefined) {
			array_push(messages, msg);
			return self;
		}
		
		msg = abs(msg);
		
		msg = formatValidationMessage( global.validation_messages[? msg], req, inv, array, index );
		array_push( messages, msg );
		return self;
	}
	
	static merge = function( validatorResultArray ) {
		var vra = validatorResultArray;
		
		for (var i=0;i<array_length(vra);i++) {
			var vr = vra[i];
			
			array_extend( vr.messages, messages );
			
			self.successes += vr.successes;
			self.failures += vr.failures;
			self.warnings += vr.warnings;
			
			if (type == VLD_RES.FAILURE) continue;
			
			if (vr.type != VLD_RES.SUCCESS) type = vr.type;
		}
		
		return self;
	}
	
}

function Validator() constructor {
	
	eventArray = [];
	ind = 0;
	
	debug_indent = 0;
	
	validations = {
		"TARGET": [
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
		],
		
		"EACH": [
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
	}
	
	static validate = function( e ) {
		print("--------");
		
		var r = __validate( e );
		
		switch (r.type) {
			
			case VLD_RES.SUCCESS:
				print("VALIDATOR - Completed successfully with no issues.");
			break;
			
			case VLD_RES.WARNING:
				print("VALIDATOR - Completed with %%.\n", string_plural(r.warnings, " warning"));
			break;
			
			case VLD_RES.FAILURE:
				print("VALIDATOR - Failed to complete with %% and %%n",
					string_plural( r.failures, " failure" ),
					string_plural( r.warnings, " warning" )
				);
			break;
			
		}
		
		for (var m=0;m<array_length(r.messages);m++) {
			var msg = r.messages[m];
			
			print("    * " + msg);
			print("");
		}
		
		print("--------");
	}
	
	static __validate = function( e ) {
		
		var val_results = [];
		
		array_copy(eventArray, 0, e, 0, array_length(e));
		
		for (ind=0;ind<array_length(eventArray);ind++) {
			var ev = eventArray[ind];
			
			
			if (is_array( ev )) {
				debug_indent += 2;
			
				var block_results = __validate( ev );
				
				debug_indent -= 2;
				
				array_push(val_results, block_results);
				continue;
			}
			
			var evs = string_explode( ev, " " );
			
			var name = evs[0];
			
			var funcStruct = getCF( name );
			
			if (funcStruct == undefined) {
				var vr = new ValidatorResult( eventArray, ind );
				vr.type = VLD_RES.WARNING;
				vr.warnings ++;
				vr.msg("Function \""+name+"\" doesn't exist - has it been registered on start-up?");
				array_push( val_results, vr );
				continue;
			}
			
			var argCount = array_length(evs) - 1;
			
			if ( argCount < funcStruct.arg_min || ( funcStruct.arg_max > 0 && argCount > funcStruct.arg_max ) ) {
				var vr = new ValidatorResult( eventArray, ind );
				vr.type = VLD_RES.WARNING;
				vr.warnings ++;
				
				var amin, amax;
				
				amin = string( funcStruct.arg_min );
				amax = funcStruct.arg_max < 0 ? "infinite" : string(funcStruct.arg_max);
				
				vr.msg("Expected at least "+amin+" and at most "+amax+" argument(s), but got "+string(argCount)+" instead.");
				array_push( val_results, vr );
				continue;
			}
			
			var rulesets = funcStruct[$ "validators"];
			
			if (rulesets == undefined) {
				var vr = new ValidatorResult( eventArray, ind );
				vr.type = VLD_RES.WARNING;
				vr.warnings ++;
				vr.msg("Couldn't find validator for function \""+name+"\".");
				array_push( val_results, vr );
				continue;
			}
			
			var results = [];
			
			for (var r=0;r<array_length(rulesets);r++) {
				
				array_extend( validateRulesetConditions( rulesets[r] ), results );
				
				// All results of all condition sets,
				// including messages
				
				// If ANY are failures, we exit validation
				// Otherwise, we only have warnings
				
				var result = new ValidatorResult( eventArray, ind )
					.merge( results );
				
				array_push(val_results, result);
				
				if ( result.type == VLD_RES.FAILURE ) {
					// Immediately exit validation
					break;
				}
				
			}
			
		}
		
		var final_result = new ValidatorResult( eventArray, ind )
			.merge( val_results );
			
		return final_result;
		
	}
	
	static validateRulesetConditions = function( rs ) {
		
		var results = [];
		
		for (var ii=0;ii<array_length(rs.conditions);ii+=2) {
			var modifier = rs.conditions[ii];
			var set = rs.conditions[ii+1];
			
			var setRule = rs.rule;
			
			var res = new ValidatorResult( eventArray, ind );
			
			var setORFailures = 0;
			
			for (var c=0;c<array_length(set);c++) {
				var condition = set[c];
				
				var valFunc = global.validation_functions[? abs(condition)];
				
				if (valFunc == undefined) {
					res.type = VLD_RES.WARNING;
					res.msg( "Function not found for condition "+abs(condition));
					continue;
				}
				
				var inv = condition < 0;
				
				var funcResult = ( valFunc( eventArray, ind, eventArray[ind] ) ) == !inv;
				
				if (!funcResult) {
					if (modifier == VLD_MOD.AND) {
						if (setRule == VLD_RULE.REQUIRE) {
							res.msg( condition, setRule, inv, eventArray[ind], ind );
							res.type = VLD_RES.FAILURE;
							
							res.failures ++;
							break;
						}
						
						if (setRule == VLD_RULE.RECOMMEND) {
							res.msg( condition, setRule, inv, eventArray[ind], ind );
							res.type = VLD_RES.WARNING;
							res.warnings ++;
						}
						///@TODO Add section for VLD_RULE.RECOMMEND!
					}
				
					if ( modifier == VLD_MOD.OR ) {
						if (setRule == VLD_RULE.REQUIRE) {
							res.msg( condition, setRule, inv, eventArray[ind], ind );
							setORFailures ++;
						}
						
						if (setRule == VLD_RULE.RECOMMEND) {
							res.msg( condition, setRule, inv, eventArray[ind], ind );
							res.type = VLD_RES.WARNING;
							
							res.warnings ++;
						}
					}
				}
			}
			
			if (setORFailures >= array_length(set)) {
				res.type = VLD_RES.FAILURE;
				res.failures ++;
			}
			
			if (res.type == VLD_RES.SUCCESS) res.successes ++;
			
			array_push( results, res );
		}
		
		return results;
	}
}


#macro vld_funcs global.validation_functions

global.validation_functions = ds_map_create();

vld_funcs[? VLD_COND.IS_FIRST_NODE] = function( eft, ind, _x ) {
	return ind == 0;
}

vld_funcs[? VLD_COND.IS_LAST_NODE] = function( eft, ind, _x ) {
	return ind == array_length(eft)-1;
}

vld_funcs[? VLD_COND.EXISTS] = function( eft, ind, _x ) {
	return array_at( eft, _x ) > -1;
}

vld_funcs[? VLD_COND.CASTS_TO_VARIABLE] = function( eft, ind, _x ) {
	return string_count("-> $", _x) > 0;
}

vld_funcs[? VLD_COND.FOLLOWED_BY_BLOCK] = function( eft, ind, _x ) {
	return is_array(eft[ind + 1]);
}

#macro vld_msg global.validation_messages

global.validation_messages = ds_map_create();

vld_msg[? VLD_COND.IS_FIRST_NODE] = "??to~~be first Node in effects tree.";
vld_msg[? VLD_COND.EXISTS] = "??to~~be included in effects tree.";
vld_msg[? VLD_COND.CASTS_TO_VARIABLE] = "??to~~cast to a variable:\n - FUNCTION arguments... -> $variable_to_cast_to";
vld_msg[? VLD_COND.FOLLOWED_BY_BLOCK] = "??to~~be followed by an indented block:\n - FUNCTION\n - - FUNCTION_IN_BLOCK\n   - SECOND_FUNCTION_IN_BLOCK\n   - ...";


global.validations = {
	
}