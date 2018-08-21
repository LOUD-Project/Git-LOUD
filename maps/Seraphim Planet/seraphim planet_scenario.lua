version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Seraphim Planet",
    description = "<LOC Seraphim Planet_Description>",
    preview = '',
    map_version = 4,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Seraphim Planet/Seraphim Planet.scmap',
    save = '/maps/Seraphim Planet/Seraphim Planet_save.lua',
    script = '/maps/Seraphim Planet/Seraphim Planet_script.lua',
    norushradius = 65,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
            },
        },
    },
}
