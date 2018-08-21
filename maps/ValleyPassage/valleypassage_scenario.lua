version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Valley Passage 20",
    description = "<LOC ValleyPassage_Description>A simple situation - 4 on 4",
    preview = '',
    map_version = 12,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/ValleyPassage/ValleyPassage.scmap',
    save = '/maps/ValleyPassage/ValleyPassage_save.lua',
    script = '/maps/ValleyPassage/ValleyPassage_script.lua',
    norushradius = 60,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' )
            },
        },
    },
}
