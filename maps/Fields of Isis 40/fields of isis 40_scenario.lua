version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Fields of Isis 40",
    description = "<LOC Fields of Isis 40_Description>With almost no water and little vegetation, there is very little reason to come to the Fields. However, it does possess abundant Mass , which makes it a natural place for Commanders to fight.",
    preview = '',
    map_version = 10.1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Fields of Isis 40/Fields of Isis 40.scmap',
    save = '/maps/Fields of Isis 40/Fields of Isis 40_save.lua',
    script = '/maps/Fields of Isis 40/Fields of Isis 40_script.lua',
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
