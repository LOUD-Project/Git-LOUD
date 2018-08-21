version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Lost Paradise II",
    description = "Expect almost instant contact on this rough island",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Lost Paradise II/Lost Paradise II.scmap',
    save = '/maps/Lost Paradise II/Lost Paradise II_save.lua',
    script = '/maps/Lost Paradise II/Lost Paradise II_script.lua',
    norushradius = 45,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_3', 'ARMY_1', 'ARMY_4', 'ARMY_8', 'ARMY_2', 'ARMY_7', 'ARMY_5', 'ARMY_6'}
                },
            },
            customprops = {
            },
        },
    },
}
