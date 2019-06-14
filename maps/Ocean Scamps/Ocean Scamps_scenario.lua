version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Ocean Scamps",
    description = "",
    preview = '',
    map_version = '1',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Ocean Scamps/Ocean Scamps.scmap',
    save = '/maps/Ocean Scamps/Ocean Scamps_save.lua',
    script = '/maps/Ocean Scamps/Ocean Scamps_script.lua',
    norushradius = 70,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
