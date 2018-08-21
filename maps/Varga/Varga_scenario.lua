version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Varga Pass 10 - LOUD",
    description = "<LOC Varga_Description>Often the fight for a world comes down to a single battle. All the maneuvering, strategy and preparation culminate in one final brawl. Victory at Varga Pass means victory over an entire planet.",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {512, 512},
    map = '/maps/Varga/Varga.scmap',
    save = '/maps/Varga/Varga_save.lua',
    script = '/maps/Varga/Varga_script.lua',
    norushradius = 70,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
