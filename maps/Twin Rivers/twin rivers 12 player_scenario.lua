version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Twin Rivers - 12 Player",
    description = "<LOC Twin Rivers_Description>Twin Rivers configured for 12 players",
    preview = '',
    map_version = 3,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Twin Rivers/Twin Rivers.scmap',
    save = '/maps/Twin Rivers/Twin Rivers 12 Player_save.lua',
    script = '/maps/Twin Rivers/Twin Rivers_script.lua',
    norushradius = 100,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' )
            },
        },
    },
}
