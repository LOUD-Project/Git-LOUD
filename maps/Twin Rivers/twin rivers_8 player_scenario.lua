version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Twin Rivers - 8 Player",
    description = "<LOC Twin Rivers_Description>  The basic map, configured for up to 8 players.",
    preview = '',
    map_version = 8,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Twin Rivers/Twin Rivers.scmap',
    save = '/maps/Twin Rivers/Twin Rivers_8 Player_save.lua',
    script = '/maps/Twin Rivers/Twin Rivers_script.lua',
    norushradius = 45,
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
