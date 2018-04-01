version = 3

ScenarioInfo = {

	name = 'Burial Mounds 20',
	
	description = '<LOC Burial Mounds 20_Description>Initial scans of the planet revealed evenly spaced hills, leading some to believe that the hills were ancient alien Burial Mounds 20. Subsequent scans disproved this theory, but many believe that the old Earth Empire actually found alien remains, spirited them away and then faked the scans as part of the cover-up.',
	
	type = 'skirmish',
	starts = true,
	preview = '',
	size = {1024, 1024},
	
	map = '/maps/Burial Mounds 20/Burial Mounds 20.scmap',
	map_version = '5.1',
	
	save = '/maps/Burial Mounds 20/Burial Mounds 20_save.lua',
	script = '/maps/Burial Mounds 20/Burial Mounds 20_script.lua',
	
	norushradius = 35,
	
	Configurations = {
		['standard'] = {
			teams = {
				{
					name = 'FFA',
					armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'},
				},
			},
			customprops = {	['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ), },
		},
	},
	
	norushoffsetX_ARMY_1 = 0,
	norushoffsetY_ARMY_1 = 0,
	norushoffsetX_ARMY_2 = 0,
	norushoffsetY_ARMY_2 = 0,
	norushoffsetX_ARMY_3 = 0,
	norushoffsetY_ARMY_3 = 0,
	norushoffsetX_ARMY_4 = 0,
	norushoffsetY_ARMY_4 = 0,
	norushoffsetX_ARMY_5 = 0,
	norushoffsetY_ARMY_5 = 0,
	norushoffsetX_ARMY_6 = 0,
	norushoffsetY_ARMY_6 = 0,
	norushoffsetX_ARMY_7 = 0,
	norushoffsetY_ARMY_7 = 0,
	norushoffsetX_ARMY_8 = 0,
	norushoffsetY_ARMY_8 = 0,
}
