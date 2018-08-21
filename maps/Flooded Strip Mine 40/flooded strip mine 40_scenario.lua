version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Flooded Strip Mine 40",
    description = "<LOC Flooded Strip Mine 40_Description>During the summer months, the bed of the Strip Mine floods, preventing the colonists from getting much work done. Recently, the colony has cut off all communication with the UEF, and any signals sent by the Coalition have been ignored. The state of the system and its colonies remains unknown.",
    preview = '',
    map_version = 4,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Flooded Strip Mine 40/Flooded Strip Mine 40.scmap',
    save = '/maps/Flooded Strip Mine 40/Flooded Strip Mine 40_save.lua',
    script = '/maps/Flooded Strip Mine 40/Flooded Strip Mine 40_script.lua',
    norushradius = 35,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
