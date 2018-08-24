version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Thawing Glacier 20",
    description = "<LOC Thawing Glacier 20_Description>Frozen landscape",
    preview = '',
    map_version = 11,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Thawing Glacier 20/Thawing Glacier.scmap',
    save = '/maps/Thawing Glacier 20/Thawing Glacier_20_save.lua',
    script = '/maps/Thawing Glacier 20/Thawing Glacier_script.lua',
    norushradius = 50,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_9 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
