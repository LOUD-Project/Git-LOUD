version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Lost Temple",
    description = "<LOC LostTemple_Description>The Lost Temple of Procyon",
    preview = '',
    map_version = 6,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/LostTemple/losttemple.scmap',
    save = '/maps/LostTemple/losttemple_save.lua',
    script = '/maps/LostTemple/losttemple_script.lua',
    norushradius = 45,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12', 'ARMY_13', 'ARMY_14'}
                },
            },
            customprops = {
            },
        },
    },
}
