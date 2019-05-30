version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Iced Mountains",
    description = "<LOC Iced Mountains_Description>",
    preview = '',
    map_version = '8.0',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Iced Mountains/Iced Mountains.scmap',
    save = '/maps/Iced Mountains/Iced Mountains_save.lua',
    script = '/maps/Iced Mountains/Iced Mountains_script.lua',
    norushradius = 75,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_11 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
