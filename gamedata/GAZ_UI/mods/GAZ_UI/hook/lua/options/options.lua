do
    table.insert(options.ui.items,
    {
        title = "GUI: Template Rotation",
        key = 'gui_template_rotator',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: SCU Manager",
        key = 'gui_scu_manager',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Draggable Build Queue",
        key = 'gui_draggable_queue',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Middle Click Avatars",
        key = 'gui_idle_engineer_avatars',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: All Race Templates",
        key = 'gui_all_race_templates',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Single Unit Selected Info",
        key = 'gui_enhanced_unitview',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Single Unit Selected Rings",
        key = 'gui_enhanced_unitrings',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Zoom Pop Distance",
        key = 'gui_zoom_pop_distance',
        type = 'slider',
        default = 80,
        custom = {
            min = 1,
            max = 160,
            inc = 1,
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Factory Build Queue Templates",
        key = 'gui_templates_factory',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Seperate Idle Builders",
        key = 'gui_seperate_idle_builders',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    
    --added by ghaleon
    table.insert(options.ui.items,
    {
        title = "GUI: Visible Template Names",
        key = 'gui_visible_template_names',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Template Name Cutoff",
        key = 'gui_template_name_cutoff',
        type = 'slider',
        default = 0,
        custom = {
            min = 0,
            max = 10,
            inc = 1,
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Display more Unit Stats",
        key = 'gui_detailed_unitview',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Display Reclaim Window",
        key = 'gui_display_reclaim_totals',
        type = 'toggle',
        default = 0,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Always Render Custom Names",
        key = 'gui_render_custom_names',
        type = 'toggle',
        default = 1,
        set = function(key,value,startup)
            ConExecute("ui_RenderCustomNames " .. tostring(value))
        end,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Force Render Enemy Lifebars",
        key = 'gui_render_enemy_lifebars',
        type = 'toggle',
        default = 0,
        set = function(key,value,startup)
            ConExecute("UI_ForceLifbarsOnEnemy " .. tostring(value))
        end,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Auto Rename Replays",
        key = 'gui_auto_rename_replays',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    table.insert(options.ui.items,
    {
        title = "GUI: Improved Unit deselection",
        key = 'gui_improved_unit_deselection',
        type = 'toggle',
        default = 1,
        custom = {
            states = {
                {text = "<LOC _Off>", key = 0 },
                {text = "<LOC _On>", key = 1 },
            },
        },
    })
    --added by ghaleon end
    
    --Added by THYGRRR to enable smarter economy rate calculations
    table.insert(options.ui.items, 
				{
					title = "GUI: Smart Economy Indicators",
					key = 'gui_smart_economy_indicators',
					type = 'toggle',
					default = 0,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
end
