version = 3
ScenarioInfo = {
  name = 'Spine of Zeus',
  type = 'skirmish',
  description = '<LOC Spineofzeus_Description>A small valley between the cliffs and rock outcrops has become a contested area. Capture the highlands and cliff sides overlooking the valley or use brute force and walk right down the middle. Multiplayer suggest teams 1v1, 2v2, 3v3. Map size 20x20.',
  starts = true,
  preview = '',
  size = {1024, 1024},
  map = '/maps/spineofzeus/spineofzeus.scmap',
  map_version = 3,
  save = '/maps/spineofzeus/spineofzeus_save.lua',
  script = '/maps/spineofzeus/spineofzeus_script.lua',
  Configurations = {
    ['standard'] = {
      teams = {
        {
          name = 'FFA',
          armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6'},
        },
      },
      customprops = {
        ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
      },
    },
  },
  norushradius = 55,
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
}
