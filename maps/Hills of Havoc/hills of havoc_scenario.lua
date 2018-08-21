version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Hills of Havoc",
    description = "<LOC Hills of Havoc_Description>The Land Version",
    preview = '',
    map_version = 5.1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Hills of Havoc/hills of havoc.scmap',
    save = '/maps/Hills of Havoc/Hills of Havoc_save.lua',
    script = '/maps/Hills of Havoc/Hills of Havoc_script.lua',
    norushradius = 80,
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
