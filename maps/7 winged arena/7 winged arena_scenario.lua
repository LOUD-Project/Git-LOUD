version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "7 winged arena",
    description = "<LOC 7 winged arena_Description>A map for teams or FFA, fighting to control the resource-rich middle",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/7 winged arena/7 winged arena.scmap',
    save = '/maps/7 winged arena/7 winged arena_save.lua',
    script = '/maps/7 winged arena/7 winged arena_script.lua',
    norushradius = 75,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12', 'ARMY_13', 'ARMY_14'}
                },
            },
            customprops = {
            },
        },
    },
}
