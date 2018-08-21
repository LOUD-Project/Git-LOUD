version = 3
ScenarioInfo = {
  name = 'Gentlemans Reef 40',
  description = '<LOC Gentlemans Reef_Description>Once a haven for smugglers, the islands were named after the \'gentlemen\' that did business there. Now the islands host a different kind of gentleman, Commanders from the three factions who vie with each other for control of the planet.',
  type = 'skirmish',
  map_version = '2.1',
  starts = true,
  preview = '',
  size = {2048, 2048},
  map = '/maps/Gentlemans Reef/Gentlemans Reef.scmap',
  save = '/maps/Gentlemans Reef/Gentlemans Reef_Standard_save.lua',
  script = '/maps/Gentlemans Reef/Gentlemans Reef_script.lua',
  norushradius = 65,
  Configurations = {
    ['standard'] = {
      teams = {
        {
          name = 'FFA',
          armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7'},
        },
      },
      customprops = {
        ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
      },
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
}
