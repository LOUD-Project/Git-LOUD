version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Armed & Dangerous",
    description = "<LOC Armed and Dangerous_Description>Flat & swampy. A multiple choke point map.  A simple tactical challenge for team play.",
    preview = '',
    map_version = '14.1',
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Armed and Dangerous/Armed and Dangerous.scmap',
    save = '/maps/Armed and Dangerous/Armed and Dangerous_save.lua',
    script = '/maps/Armed and Dangerous/Armed and Dangerous_script.lua',
    norushradius = 60,
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
