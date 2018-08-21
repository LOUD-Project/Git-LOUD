version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Hrungdaks Dryland",
    description = "<LOC Hrungdaks Dryland_Description>The planet named DRYLAND, where wide valleys get flooded by the ocean and the hills become islands that stick out of the water.",
    preview = '',
    map_version = 1.1,
    type = 'skirmish',
    starts = true,
    size = {2048, 2048},
    map = '/maps/Hrungdaks Dryland/Hrungdaks Dryland.scmap',
    save = '/maps/Hrungdaks Dryland/Hrungdaks Dryland_save.lua',
    script = '/maps/Hrungdaks Dryland/Hrungdaks Dryland_script.lua',
    norushradius = 62,
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
