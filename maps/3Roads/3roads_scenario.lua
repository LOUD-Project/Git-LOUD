version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "3 Roads",
    description = "Made by LeoPhone - edited by Maxon for The LOUD Project",
    preview = '',
    map_version = '3.1',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/3Roads/3roads.scmap',
    save = '/maps/3Roads/3Roads_save.lua',
    script = '/maps/3Roads/3Roads_script.lua',
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
