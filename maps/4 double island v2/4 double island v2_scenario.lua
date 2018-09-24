version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "4 double island v2",
    description = "<LOC 4 double island v2_Description>",
    preview = '',
    map_version = '2.0',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/4 double island v2/4 double island v2.scmap',
    save = '/maps/4 double island v2/4 double island v2_save.lua',
    script = '/maps/4 double island v2/4 double island v2_script.lua',
    norushradius = 75,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
