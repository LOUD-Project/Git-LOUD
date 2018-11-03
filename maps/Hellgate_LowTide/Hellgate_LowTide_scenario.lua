version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Hellgate - Low Tide",
    description = "<LOC Hellgate_LowTide_Description>Forget the toy boats - roll the heavy metal !",
    preview = '',
    map_version = 1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Hellgate_LowTide/Hellgate_LowTide.scmap',
    save = '/maps/Hellgate_LowTide/Hellgate_LowTide_save.lua',
    script = '/maps/Hellgate_LowTide/Hellgate_LowTide_script.lua',
    norushradius = 75,
    norushoffsetX_ARMY_2 = 2,
    norushoffsetY_ARMY_2 = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8', 'ARMY_9', 'ARMY_10', 'ARMY_11', 'ARMY_12'}
                },
            },
            customprops = {
            },
        },
    },
}
