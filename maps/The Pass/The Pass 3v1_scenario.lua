version = 3
ScenarioInfo = {
  name = 'The Pass 3v1',
  description = '<LOC The Pass_Description>A version for a 3 v 1 setup.  The South positions may NOT be suitable for LOUD AI',
  preview = '',
  map_version = '2',
  type = 'skirmish',
  starts = true,
  size = {512, 512},
  map = '/maps/The Pass/The Pass.scmap',
  save = '/maps/The Pass/The Pass 3v1_save.lua',
  script = '/maps/The Pass/The Pass_script.lua',
  norushradius = 50,
  Configurations = {
    ['standard'] = {
      teams = {
        {
          name = 'FFA',
          armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4'},
        },
      },
      customprops = {},
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
}
