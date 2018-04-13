version = 3
ScenarioInfo = {
    name = "The Pass 1v1",
    description = "<LOC The Pass_Description>Built for a simple 1 v 1 conflict",
    preview = '',
    map_version = '2',
    type = 'skirmish',
    starts = true,
    size = {512, 512},
    map = '/maps/The Pass/The Pass.scmap',
    save = '/maps/The Pass/The Pass 1v1_save.lua',
    script = '/maps/The Pass/The Pass_script.lua',
    norushradius = 50,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2'}
                },
            },
            customprops = {
            },
        },
    },
}
