version = 3
ScenarioInfo = {
    name = "Hills of Havoc Wet 7v4",
    description = "<LOC Hills of Havoc_Description>The Wet Version but built for 7 versus 4",
    preview = '',
    map_version = '1.1',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/hills of havoc wet/hills of havoc wet.scmap',
    save = '/maps/hills of havoc wet/hills of havoc wet 7v4_save.lua',
    script = '/maps/hills of havoc wet/hills of havoc wet_script.lua',
    norushradius = 65,
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
