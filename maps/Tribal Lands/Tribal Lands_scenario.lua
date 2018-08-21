version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Tribal Lands",
    description = "<LOC Tribal Lands_Description>Skirmish water/land/air map",
    preview = '',
    map_version = 5.1,
    type = 'skirmish',
    starts = true,
    size = {1024, 1024},
    map = '/maps/Tribal Lands/Tribal Lands.scmap',
    save = '/maps/Tribal Lands/Tribal Lands_save.lua',
    script = '/maps/Tribal Lands/Tribal Lands_script.lua',
    norushradius = 70,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'ARMY_1', 'ARMY_2', 'ARMY_3', 'ARMY_4', 'ARMY_5', 'ARMY_6', 'ARMY_7', 'ARMY_8'}
                },
            },
            customprops = {
            },
        },
    },
}
