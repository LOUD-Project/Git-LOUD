version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Ian's Cross",
    description = "<LOC Ians Cross_Description>Named for an early explorer, Ian's Cross has witnessed countless battles. The relatively open area and plentiful Mass deposits have encouraged continual battles for several years.",
    preview = '',
    map_version = 8,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Ians Cross/Ians Cross.scmap',
    save = '/maps/Ians Cross/Ians Cross_save.lua',
    script = '/maps/Ians Cross/Ians Cross_script.lua',
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
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
