version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Painted Desert",
    description = "<LOC Painted Desert_Description>Painted desert, a droughty uninhabitable place that would be completely abandoned wasnt it for its significant strategic value in the Quantum gate network",
    preview = '',
    map_version = 14,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Painted Desert/Painted Desert.scmap',
    save = '/maps/Painted Desert/Painted Desert_save.lua',
    script = '/maps/Painted Desert/Painted Desert_script.lua',
    norushradius = 45,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10'}
                },
            },
            customprops = {
            },
        },
    },
}
