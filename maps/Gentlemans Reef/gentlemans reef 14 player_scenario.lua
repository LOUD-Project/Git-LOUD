version = 3
ScenarioInfo = {
  name = 'Gentlemans Reef-14 Plyr',
  description = '<LOC Gentlemans Reef_Description>Adapted from the original, this 14 Player version is for large PvP games.',
  type = 'skirmish',
  map_version = '1.1',
  starts = true,
  preview = '',
  size = {2048, 2048},
  map = '/maps/Gentlemans Reef/Gentlemans Reef.scmap',
  save = '/maps/Gentlemans Reef/Gentlemans Reef 14 Player_save.lua',
  script = '/maps/Gentlemans Reef/Gentlemans Reef_script.lua',
  norushradius = 35,
  Configurations = {
    ['standard'] = {
      teams = {
        {
          name = 'FFA',
          armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12', 'ARMY_13', 'ARMY_14'},
          --armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7'},
        },
      },
      customprops = {
        ['ExtraArmies'] = STRING( 'ARMY_15 NEUTRAL_CIVILIAN' ),
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
