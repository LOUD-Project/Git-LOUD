version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Desert Island 40 (5 vs 3)",
    description = "<LOC Desert Island 40_Description>Only the most talented commanders can solve the problematic Desert Island.  You must master the Air and Sea to prevail and break the stalemate.  Designed for human vs. AI with AI in the North.",
    preview = '',
    map_version = '6',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Desert Island 40/Desert Island 40.scmap',
    save = '/maps/Desert Island 40/Desert Island 40_save.lua',
    script = '/maps/Desert Island 40/Desert Island 40_script.lua',
    norushradius = 90,
    norushoffsetX_ARMY_1 = 2,
    norushoffsetY_ARMY_1 = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN ARMY_9' )
            },
        },
    },
}
