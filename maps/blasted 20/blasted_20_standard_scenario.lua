version = 3

ScenarioInfo = {
  map_version = 4,
  name = 'Blasted Rock 20 (4 Player)',
  type = 'skirmish',
  description = 'The former mining colony at Blasted Rock having been wiped out, the conflict widens....',
  starts = true,
  preview = '',
  size = {1024, 1024},
  norushradius = 36,
  map = '/maps/Blasted_20/Blasted_20.scmap',
  save = '/maps/Blasted_20/Blasted_20_Standard_save.lua',
  script = '/maps/Blasted_20/Blasted_20_Standard_script.lua',
  Configurations = {
    ['standard'] = {
      teams = {
        {
          name = 'FFA',
          armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4'},
        },
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
}
