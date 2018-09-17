version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Battle Isles 40",
    description = "<LOC Battle Isles 40_Description>Land / Water warfare, up to eigth players in two to four teams use fortified bases and islands. Not yet rated for AI play.",
    preview = '',
    map_version = '2',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Battle Isles 40/Battle Isles 40.scmap',
    save = '/maps/Battle Isles 40/Battle Isles 40_save.lua',
    script = '/maps/Battle Isles 40/Battle Isles 40_script.lua',
    norushradius = 50,
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
