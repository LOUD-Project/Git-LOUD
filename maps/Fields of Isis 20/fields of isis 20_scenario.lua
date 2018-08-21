version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Fields of Isis 20",
    description = "<LOC Fields of Isis 20_Description>With almost no water and little vegetation, there is very little reason to come to the Fields. However, it does possess abundant Mass , which makes it a natural place for Commanders to fight.",
    preview = '',
    map_version = 5,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Fields of Isis 20/Fields of Isis 20.scmap',
    save = '/maps/Fields of Isis 20/Fields of Isis 20_save.lua',
    script = '/maps/Fields of Isis 20/Fields of Isis 20_script.lua',
    norushradius = 46,
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
