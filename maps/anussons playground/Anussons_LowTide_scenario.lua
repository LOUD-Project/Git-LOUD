version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Anussons - LowTide",
    description = "<LOC Anussons_LowTide_Description> When the tide rolls out, the Anusson Islands become a mobile playground.  This is a moderate difficulty AI scenario played either North/South or East/West.",
    preview = '',
    map_version = '2.3',
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/anussons playground/Anussons_LowTide.scmap',
    save = '/maps/anussons playground/Anussons_LowTide_save.lua',
    script = '/maps/anussons playground/Anussons_LowTide_script.lua',
    norushradius = 70,

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
