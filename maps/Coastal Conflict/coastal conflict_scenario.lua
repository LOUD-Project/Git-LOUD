version = 3
ScenarioInfo = {
    name = "Coastal Conflict",
    description = "<LOC Coastal Conflict_Description>",
    preview = '',
    map_version = '4.4',
    type = 'skirmish',
    starts = true,
    size = {2048, 1024},
    map = '/maps/Coastal conflict/Coastal conflict.scmap',
    save = '/maps/Coastal conflict/Coastal conflict_save.lua',
    script = '/maps/Coastal conflict/Coastal conflict_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIANS' ),
            },
        },
    },
}
