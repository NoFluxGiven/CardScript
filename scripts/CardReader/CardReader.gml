#macro CARD_FRIENDLY_NAMES global.card_friendly_names
#macro TEXT_TOKENS global.text_tokens

global.card_friendly_names = undefined;
global.text_tokens = undefined;

CARD_FRIENDLY_NAMES = {
	COMBAT_ROLL: "COMBAT ROLL",	
}

TEXT_TOKENS = {
	"T": __passthrough,
	"R": __convertRounds,
	"F": __getFriendlyName
}

function __replaceTokens( tokenInput, key, value ) {
	var token_names = variable_struct_get_names( TEXT_TOKENS );
	
	for (var i=0;i<array_length(token_names);i++) {
		var tokenType = token_names[i];
		var token = TEXT_TOKENS[$ tokenType];
		
		tokenInput = __token( tokenType, tokenInput, key, value );
	}
	
	return tokenInput;
}

function __token( tokenType, tokenInput, key, value ) {
	
	// SPECIAL TOKENS
	var str = "<"+tokenType+"/"+key+">";
	var tokenFunc = TEXT_TOKENS[$ tokenType];
	
	if tokenFunc == undefined return tokenInput;
	
	if ( string_count( str, tokenInput ) ) {
		return string_replace_all( tokenInput, str, TEXT_TOKENS[$ tokenType]( value ) );
	}
	
	return tokenInput;
	
}

function __addDefaultTokenDefinitions( tokenInput, key ) {
	return string_replace_all(tokenInput, "<"+key+">", "<T/"+key+">");
}

function __getFriendlyName( input ) {
	var cfn = CARD_FRIENDLY_NAMES[$ input];
	return cfn == undefined ? input : cfn;
}

function __passthrough( input ) {
	return input;
}

function __convertRounds( input ) {
	input = real(input);
	var plural = abs(input) > 1 || input == 0;
	
	return string(input) + " " + (plural ? "rounds" : "round");
}

function getParsedText( cardData, text ) {
	var vars = cardData.vars;
	var vars_names = variable_struct_get_names(vars);
	
	for (var i=0;i<array_length(vars_names);i++)
	{
		var k = vars_names[i];
		var v = string(vars[$ k]);
		
		text = __addDefaultTokenDefinitions( text, k );
		
		text = __replaceTokens( text, k, v );
	}
	
	return text;
}

function getParsedEffectText( cardData ){
	return getParsedText( cardData, cardData.text );
}