version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Emerald Island",
    description = "20x20 island map",
    preview = '',
    map_version = 3,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/emerald island/emerald_island.scmap',
    save = '/maps/emerald island/emerald_island_save.lua',
    script = '/maps/emerald island/emerald_island_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4'}
                },
            },
            customprops = {
            },
        },
    },
}
