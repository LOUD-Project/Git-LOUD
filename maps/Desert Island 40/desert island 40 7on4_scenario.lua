version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Desert Island 40 (7 vs 4)",
    description = "<LOC Desert Island 40_Description>Say What? An expanded version of Desert Island for upto 7 humans versus 4 AI",
    preview = '',
    map_version = '9.1',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Desert Island 40/Desert Island 40.scmap',
    save = '/maps/Desert Island 40/Desert Island 40 7on4_save.lua',
    script = '/maps/Desert Island 40/Desert Island 40_script.lua',
    norushradius = 60,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11'}
                },
            },
            customprops = {
            },
        },
    },
}
