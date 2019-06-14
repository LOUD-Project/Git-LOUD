version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Blasted Rock 20 (4 Player)",
    description = "The former mining colony at Blasted Rock having been wiped out, the conflict widens....",
    preview = '',
    map_version = '4.2',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Blasted_20/Blasted_20.scmap',
    save = '/maps/Blasted_20/Blasted_20_Standard_save.lua',
    script = '/maps/Blasted_20/Blasted_20_Standard_script.lua',
    norushradius = 45,
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
