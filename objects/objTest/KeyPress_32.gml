file.read();
	
var text = file.text;
var cardData = file.fromYaml();

show_debug_message(cardData);

show_debug_message(getParsedEffectText( cardData ));

show_debug_message(cardData.effects);

global.validator.validate( cardData.effects.on_cast );

var cr = new CardRunner( );

cr.parseEvent( cardData, "on_cast" );

show_debug_message(cr);
