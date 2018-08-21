version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Fields of Isis 40 7 on 4",
    description = "This version has been optimized for 7 Human versus AI",
    preview = '',
    map_version = 2.1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Fields of Isis 40/Fields of Isis 40.scmap',
    save = '/maps/Fields of Isis 40/Fields of Isis 40 7 on 4_save.lua',
    script = '/maps/Fields of Isis 40/Fields of Isis 40 7 on 4_script.lua',
    norushradius = 50,
    norushoffsetY_ARMY_1 = 1,
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
