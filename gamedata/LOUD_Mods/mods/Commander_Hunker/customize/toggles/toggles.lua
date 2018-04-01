
Toggles = {
	RULEETC_HunkerToggle = {
		bitmapId = "hunker-activation",
		helpText = "Hunker",

		--***Optional params*** 
		
		--you can specify the default orders slot for this toggle either 7,8 or 13 to 18
		--if you do not specify a slot then slot 13 is used by default
		preferredSlot = 13,
		
		--you can specify the intial state of the toggle either true or false (false = on, true = off)
		--if you do not specify an initialState then the default is false which is on
		initialState = true, 
		
		--you can specify here if the button is a pulse button or a normal on/off button
		--if you do not specify a pulse flag then false is used by default
		--A pulse toggle never switches off you click the toggle and the button does what you want it to do every time.
		pulse = true, 
	},
	
	RULEETC_HunkerPauseToggle = {
		bitmapId = "blue_hunker-charge",
		helpText = "Hunker_Pause",
		preferredSlot = 14,
		initialState = false, 
		pulse = false, 
	},
}






