version = 3
ScenarioInfo = {
    name = "CityWarsIII AD",
    description = "<LOC CityWarsIII.v0001_Description>War in the Cities Part III. This is a Attack / Defend scenario. It is not intended to have AI on the centre of the map.",
    preview = '',
    map_version = '33',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/CityWarsIII.v0001/CityWarsIII.scmap',
    save = '/maps/CityWarsIII.v0001/CityWarsIII_save.lua',
    script = '/maps/CityWarsIII.v0001/CityWarsIII_script.lua',
    norushradius = 55,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12'}
                },
            },
            customprops = {
            },
        },
    },
}
