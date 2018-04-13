version = 3
ScenarioInfo = {
    name = "Asterion_Abyss",
    description = "<LOC Asterion_Abyss_Description>Map  Author : ~FCA~ Valerius.",
    preview = '',
    map_version = '3.1',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Asterion_Abyss/Asterion_Abyss.scmap',
    save = '/maps/Asterion_Abyss/Asterion_Abyss_save.lua',
    script = '/maps/Asterion_Abyss/Asterion_Abyss_script.lua',
    norushradius = 55,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'NEUTRAL_CIVILIAN', 'ARMY_9'}
                },
            },
            customprops = {
            },
        },
    },
}
