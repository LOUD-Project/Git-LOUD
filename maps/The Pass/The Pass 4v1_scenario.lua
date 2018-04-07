version = 3
ScenarioInfo = {
    name = "The Pass 4v1",
    description = "<LOC The Pass_Description>The standard 4 v 1 - The South starting positions are NOT suitable for LOUD AI",
    preview = '',
    map_version = '2',
    type = 'skirmish',
    starts = true,
    size = {512, 512},
    map = '/maps/The Pass/The Pass.scmap',
    save = '/maps/The Pass/The Pass 4v1_save.lua',
    script = '/maps/The Pass/The Pass_script.lua',
    norushradius = 36,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_2', 'ARMY_4', 'ARMY_1', 'ARMY_3', 'ARMY_5'}
                },
            },
            customprops = {
            },
        },
    },
}
