version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Voodoo Bridge",
    description = "<LOC Voodoo Bridge_Description>Voodoo Bridge  Made by Master Lee",
    preview = '',
    map_version = '1',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Voodoo Bridge/Voodoo Bridge.scmap',
    save = '/maps/Voodoo Bridge/Voodoo Bridge_save.lua',
    script = '/maps/Voodoo Bridge/Voodoo Bridge_script.lua',
    norushradius = 80,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_6', 'ARMY_8'}
                },
            },
            customprops = {
            },
        },
    },
}
