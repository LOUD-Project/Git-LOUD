version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Diezle Dune 40",
    description = "",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Diezle Dune 40/Diezle Dune 40.scmap',
    save = '/maps/Diezle Dune 40/Diezle Dune 40_save.lua',
    script = '/maps/Diezle Dune 40/Diezle Dune 40_script.lua',
    norushradius = 80,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12', 'ARMY_13'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_17 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
