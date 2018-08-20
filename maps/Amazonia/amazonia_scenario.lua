version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Amazonia - Easy",
    description = "<LOC amazonia_Description>The beginners version.  An overabundance of mass on this map makes it an easier choice over the standard version.",
    preview = '',
    map_version = 7,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Amazonia/amazonia.scmap',
    save = '/maps/Amazonia/Amazonia_save.lua',
    script = '/maps/Amazonia/Amazonia_script.lua',
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
            },
        },
    },
}
