version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Gap of Rohan",
    description = "<LOC Gap of Rohan_Description>",
    preview = '',
    map_version = 10.1,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Gap of Rohan/Gap of Rohan.scmap',
    save = '/maps/Gap of Rohan/Gap of Rohan_save.lua',
    script = '/maps/Gap of Rohan/Gap of Rohan_script.lua',
    norushradius = 45,
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
