version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "The Wilderness 40",
    description = "<LOC The Wilderness 40_Description>In a different age, the Wilderness might have been a nature preserve. With its waterways and thick forests, life of all kinds flourished. The Wilderness, though, had the misfortune to be chosen as a Gate hub. Its forests now echo with the crash of weapons fire and the waterways are clogged with the hulls of broken warships.",
    preview = '',
    map_version = 8.1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/The Wilderness 40/The Wilderness 40.scmap',
    save = '/maps/The Wilderness 40/The Wilderness 40_save.lua',
    script = '/maps/The Wilderness 40/The Wilderness 40_script.lua',
    norushradius = 65,
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
