version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "The Pass 3v1",
    description = "<LOC The Pass_Description>A version for a 3 v 1 setup.  The South positions may NOT be suitable for LOUD AI",
    preview = '',
    map_version = 2,
    type = 'skirmish',
    starts = true,
    size = {512, 512},
    map = '/maps/The Pass/The Pass.scmap',
    save = '/maps/The Pass/The Pass 3v1_save.lua',
    script = '/maps/The Pass/The Pass_script.lua',
    norushradius = 50,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' )
            },
        },
    },
}
