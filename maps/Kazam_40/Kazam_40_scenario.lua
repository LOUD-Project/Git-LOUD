version = 3
ScenarioInfo = {
    name = "Kazam 40",
    description = "<LOC Kazam_40_Description>",
    preview = '',
    map_version = '9.2',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Kazam_40/Kazam_40.scmap',
    save = '/maps/Kazam_40/Kazam_40_save.lua',
    script = '/maps/Kazam_40/Kazam_40_script.lua',
    norushradius = 65,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_13 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
