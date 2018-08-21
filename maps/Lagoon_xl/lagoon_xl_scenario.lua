version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Lagoon XL",
    description = "<LOC Lagoon_XL_Description>",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Lagoon_XL/Lagoon_XL.scmap',
    save = '/maps/Lagoon_XL/Lagoon_XL_save.lua',
    script = '/maps/Lagoon_XL/Lagoon_XL_script.lua',
    norushradius = 65,
    norushoffsetX_ARMY_3 = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_13 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
