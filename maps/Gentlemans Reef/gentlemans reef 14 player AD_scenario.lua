version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Gentlemans Reef-14 Plyr Attack Defense",
    description = "<LOC Gentlemans Reef_Description>Adapted from the original, this 14 Player version is an Attack/Defense scenario.  Place AI on all the outside starts, put Humans on the inside.  Hostile civilians control the deciding resources in the middle of the map.",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Gentlemans Reef/Gentlemans Reef.scmap',
    save = '/maps/Gentlemans Reef/Gentlemans Reef 14 Player AD_save.lua',
    script = '/maps/Gentlemans Reef/Gentlemans Reef_script.lua',
    norushradius = 35,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12', 'ARMY_13', 'ARMY_14'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_15' ),
            },
        },
    },
}
