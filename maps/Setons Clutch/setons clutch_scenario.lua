version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Seton's Clutch",
    description = "<LOC setons clutch_Description>Dozens of battles have been fought over the years across Seton's Clutch. A patient searcher could find the remains of thousands of units resting beneath the earth and under the waves.",
    preview = '',
    map_version = 7,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Setons Clutch/Setons Clutch.scmap',
    save = '/maps/Setons Clutch/Setons Clutch_save.lua',
    script = '/maps/Setons Clutch/Setons Clutch_script.lua',
    norushradius = 55,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
