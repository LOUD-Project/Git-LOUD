version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Blasted Rock 20 (8 Player)",
    description = "<LOC Blasted_20_Description>The former mining colony at Blasted Rock having been wiped out, the conflict widens....",
    preview = '',
    map_version = '4',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Blasted_20/Blasted_20.scmap',
    save = '/maps/Blasted_20/Blasted_20_save.lua',
    script = '/maps/Blasted_20/Blasted_20_script.lua',
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
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' )
            },
        },
    },
}
