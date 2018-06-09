version = 3
ScenarioInfo = {
    name = "Emerald Crater 40",
    description = "<LOC emerald crater 40_Description>Underwater for millennia, tectonic shifts have drained the Crater, exposing the Mass needed to continue the Infinite War. Sparse forests have sprung up in the intervening years, though they are often destroyed in the continuous fighting that rages in the Crater.",
    preview = '',
    map_version = 5,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Emerald Crater 40/Emerald Crater 40.scmap',
    save = '/maps/Emerald Crater 40/Emerald Crater 40_save.lua',
    script = '/maps/Emerald Crater 40/Emerald Crater 40_script.lua',
    norushradius = 65,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
