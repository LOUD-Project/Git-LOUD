version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Shards",
    description = "<LOC Shards_Description>The Aeon believed that this planet was blessed with The Way, and for generations they protected it from the presence of sentient life. Now that the Coalition is running low on resources, desperation has caused that restriction to be lifted.",
    preview = '',
    map_version = 8,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Shards/Shards.scmap',
    save = '/maps/Shards/Shards_save.lua',
    script = '/maps/Shards/Shards_script.lua',
    norushradius = 65,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'NEUTRAL_CIVILIAN' )
            },
        },
    },
}
