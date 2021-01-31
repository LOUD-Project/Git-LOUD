--[[
This file contains a table which defines options available to the user in the options dialog

tab data is what populates each tab and defines each option in a tab
Each tab has:
    .title - the text that will appear on the tab
    .key - the key that will group the options (ie in the prefs file gameplay.help_prompts or video.resolution)
    .items - an array of the items for this key (this is an array rather than a genericly keyed table so display order can be imposed)
        .title - the text that will label the option line item
        .tip - the text that will appear in the tooltip for the item
        .key - the prefs key to identify this property
        .default - the default value of the property
        .restart - if true, setting the option will require a restart and the user will be notified
        .verify - if true, prompts the user to veryfiy the change for 15 seconds, otherwise defaults back to prior setting
        .populate - an optional function which when called, will repopulate the options custom data. The value passed in is the current value of the control (function(value))
        .set - an optional function that takes a value parameter and is responsible for determining what happens when the option is applied (function(key, value))
        .ignore - an optional function called when the option is set, checks the value, and wont change it from its former setting, and if former setting is invalid, uses return value for new value (function(value))
        .cancel - called when the option is cancelled
        .beginChange - an option function for sliders when user begins modification
        .endChange - an option function for sliders when user ends modification
        .update - a optional function that is called when the control has a new value, also receives the control (function(control, value)), not always used,
                  but if you need additonal control (say of other controls) when this value changes (for example one control may change other controls) you can
                  set up that behavior here
        .type - the type of control used to display this property
            valid types are:
            toggle - multi state toggle button (TODO - add list to replace more than 2 states?)
            button - momentary button (usually open another dialog)
            slider - a value slider
        .custom - a table of data required by the control type, different for each control type.
            slider
                .min - the minimum value for the slider
                .max - the maximum value for the slider
                .inc - the increment between slider detents, if 0 its "analog"
            toggle
                .states - table of states the toggle switch can have
                    .text = text for each state
                    .key = the key or value for each state to be stored in the pref
            button
                .text - the text label of the button

the optionsOrder table is just an array of keys in to the option table, and their order will determine what
order the tabs show in the dialog
--]]

optionsOrder = {
    "gameplay",
    "ui",
    "video",
    "sound",
}

local savedMasterVol = false
local savedFXVol = false
local savedMusicVol = false
local savedVOVol = false

function PlayTestSound()
    local sound = Sound{ Bank = 'Interface', Cue = 'UI_Action_MouseDown' }
    PlaySound(sound)
end

local voiceHandle = false
function PlayTestVoice()
    if not voiceHandle then
        local sound = Sound{ Bank = 'XGG', Cue = 'Computer_Computer_MissileLaunch_01351' }
        ForkThread( 
            function()
                WaitSeconds(0.5)
                voiceHandle = false
            end
        )
        if voiceHandle then
            StopSound(voiceHandle)
        end
        voiceHandle = PlayVoice(sound)
    end
end

options = {
    gameplay = {
        title = "Gameplay",
        key = 'gameplay',
        items = {
            {
                title = "Zoom Wheel Sensitivity",
                key = 'wheel_sensitivity',
                type = 'slider',
                default = 40,
                set = function(key,value,startup)
                    ConExecute("cam_ZoomAmount " .. tostring(value / 100))
                end,
                custom = {
                    min = 1,
                    max = 100,
                    inc = 0,
                },
            },
            {
                title = "Always Render Strategic Icons",
                key = 'strat_icons_always_on',
                type = 'toggle',
                default = 0,
                set = function(key,value,startup)
                    ConExecute("ui_AlwaysRenderStrategicIcons " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Construction Tooltip Information",
                tip = "Change the layout that information is displayed in the rollover window for units in the construction manager.",
                key = 'uvd_format',
                type = 'toggle',
                default = 'full',
                set = function(key,value,startup)
                    -- needs logic to set priority (do we really want to do this though?)
                end,
                custom = {
                    states = {
                        {text = "Full", key = 'full'},
                        {text = "Limited", key = 'limited'},
                        {text = "Off", key = 'off'},
                    },
                },
            },
            {
                title = "Economy Warnings",
                key = 'econ_warnings',
                type = 'toggle',
                default = true,
                custom = {
                    states = {
                        {text = "On", key = true,},
                        {text = "Off", key = false,},
                    },
                },
            },
            {
                title = "Show Waypoint ETAs",
                key = 'display_eta',
                type = 'toggle',
                default = true,
                custom = {
                    states = {
                        {text = "On", key = true,},
                        {text = "Off", key = false,},
                    },
                },
            },
            {
                title = "Multiplayer Taunts",
                tip = "Enable or Disable displaying taunts in multiplayer.",
                key = 'mp_taunt_head_enabled',
                type = 'toggle',
                default = 'true',
                set = function(key,value,startup)
                    -- needs logic to set priority (do we really want to do this though?)
                end,
                custom = {
                    states = {
                        {text = "On", key = 'true'},
                        {text = "Off", key = 'false'},
                    },
                },
            },
            {
                title = "Screen Edge Pans Main View",
                key = 'screen_edge_pans_main_view',
                type = 'toggle',
                default = 1,
                set = function(key,value,startup)
                    ConExecute("ui_ScreenEdgeScrollView " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Arrow Keys Pan Main View",
                key = 'arrow_keys_pan_main_view',
                type = 'toggle',
                default = 1,
                set = function(key,value,startup)
                    ConExecute("ui_ArrowKeysScrollView " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "OfF", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Pan Speed",
                key = 'keyboard_pan_speed',
                type = 'slider',
                default = 90,
                set = function(key,value,startup)
                    ConExecute("ui_KeyboardPanSpeed " .. tostring(value))
                end,
                custom = {
                    min = 1,
                    max = 200,
                    inc = 0,
                },
            },
            {
                title = "Accelerated Pan Speed Multiplier",
                key = 'keyboard_pan_accelerate_multiplier',
                type = 'slider',
                default = 4,
                set = function(key,value,startup)
                    ConExecute("ui_KeyboardPanAccelerateMultiplier " .. tostring(value))
                end,
                custom = {
                    min = 1,
                    max = 10,
                    inc = 1,
                },
            },
            {
                title = "Keyboard Rotation Speed",
                key = 'keyboard_rotate_speed',
                type = 'slider',
                default = 10,
                set = function(key,value,startup)
                    ConExecute("ui_KeyboardRotateSpeed " .. tostring(value))
                end,
                custom = {
                    min = 1,
                    max = 100,
                    inc = 0,
                },
            },
            {
                title = "Accelerated Keyboard Rotate Speed Multiplier",
                key = 'keyboard_rotate_accelerate_multiplier',
                type = 'slider',
                default = 2,
                set = function(key,value,startup)
                    ConExecute("ui_KeyboardRotateAccelerateMultiplier " .. tostring(value))
                end,
                custom = {
                    min = 1,
                    max = 10,
                    inc = 1,
                },
            },
            {
                title = "Accept Build Templates",
                key = 'accept_build_templates',
                type = 'toggle',
                default = 'yes',
                set = function(key,value,startup)
                end,
                custom = {
                    states = {
                        {text = "On", key = 'yes' },
                        {text = "Off", key = 'no' },
                    },
                },
            },
        },
    },
    ui = {
        title = "Interface",
        key = 'ui',
        items = {
            {
                title = "Display Subtitles",
                key = 'subtitles',
                type = 'toggle',
                default = false,
                custom = {
                    states = {
                        {text = "On", key = true},
                        {text = "Off", key = false},
                    },
                },
            },
            {
                title = "Display World Border",
                key = 'world_border',
                type = 'toggle',
                default = true,
                set = function(key, value, startup)
                    import('/lua/ui/uiutil.lua').UpdateWorldBorderState(nil, value)                        
                end,
                custom = {
                    states = {
                        {text = "On", key = true},
                        {text = "Off", key = false},
                    },
                },
            },
            {
                title = "Display Tooltips",
                key = 'tooltips',
                type = 'toggle',
                default = true,
                custom = {
                    states = {
                        {text = "On", key = true},
                        {text = "Off", key = false},
                    },
                },
            },
            {
                title = "Tooltip Delay",
                key = 'tooltip_delay',
                type = 'slider',
                default = 0,
                set = function(key,value,startup)
                end,
                custom = {
                    min = 0,
                    max = 3,
                    inc = 0,
                },
            },
            {
                title = "Quick Exit",
                tip = "When close box or alt-f4 are pressed, no confirmation dialog is shown",
                key = 'quick_exit',
                type = 'toggle',
                default = 'false',
                set = function(key,value,startup)
                end,
                custom = {
                    states = {
                        {text = "On", key = 'true'},
                        {text = "Off", key = 'false'},
                    },
                },
            },
            {
                title = "Lock Fullscreen Cursor To Window",
                key = 'lock_fullscreen_cursor_to_window',
                type = 'toggle',
                default = 0,
                set = function(key,value,startup)
                    ConExecute("SC_ToggleCursorClip " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Show Lifebars of Attached Units",
                key = 'show_attached_unit_lifebars',
                type = 'toggle',
                default = true,
                set = function(key,value,startup)
                end,
                custom = {
                    states = {
                        {text = "Off", key = false },
                        {text = "On", key = true },
                    },
                },
            },
            {
                title = "Use Factional UI Skin",
                key = 'skin_change_on_start',
                type = 'toggle',
                default = 'yes',
                set = function(key,value,startup)
                end,
                custom = {
                    states = {
                        {text = "On", key = 'yes' },
                        {text = "Off", key = 'no' },
                    },
                },
            },
			{
				title = "Visual Alerts Mode",
				key = "vo_VisualAlertsMode",
				type = 'toggle',
				default = 1,
				custom = {
					states = {
						{text = "None", key = 0 },
						{text = "Only 2D", key = 1 },
						{text = "Only 3D", key = 2 },
						{text = "Normal (Both)", key = 3 },
					},
				},
			},
			{
				title = "Visual Alert Ping Sound",
				key = "vo_PingSound",
				type = 'toggle',
				default = false,
				custom = {
					states = {
						{text = "No", key = false },
						{text = "Yes", key = true },
					},
				},
			},
			{
				title = "Go-To-Alert Camera Mode",
				tip = "Define the behavior of the camera when you press Alt-X (Go To Last Alert)",
				key = "alertcam_mode",
				type = 'toggle',
				default = 2,
				custom = {
					states = {
						{text = "Move to alert", key = 2 },
						{text = "Snap to alert", key = 3 },
						{text = "Snap to map", key = 4 },
						{text = "Snap to map then move to alert", key = 5 },
					},
				},
			},
			{
				title = "Go-To-Alert Camera Move Time",
				key = "alertcam_time",
				type = 'slider',
				default = 1,
				custom = {
					min = 1,
					max = 5,
					inc = 1,
				},
			},
			{
				title = "Go-To-Alert Camera Target Zoom",
				key = "alertcam_zoom",
				type = 'slider',
				default = 30,
				custom = {
					min = 11,
					max = 480,
					inc = 1,
				},
			},
			{
				title = "Hotbuild: Enable Cycle Preview",
				key = 'hotbuild_cycle_preview',
				type = 'toggle',
				default = 1,
				custom = {
					states = {
						{text = "<LOC _Off>", key = 0 },
						{text = "<LOC _On>", key = 1 },
					},
				},
			},
			{
				title = "Hotbuild: cycle reset time (ms)",
				key = 'hotbuild_cycle_reset_time',
				type = 'slider',
				default = 1100,
				custom = {
					min = 100,
					max = 5000,
					inc = 100,
				},
			},
            {
                title = "GUI: Display more Unit Stats",
                key = 'gui_detailed_unitview',
                type = 'toggle',
                default = 0,
                custom = {
                    states = {
                        {text = "<LOC _Off>", key = 0 },
                        {text = "<LOC _On>", key = 1 },
                    },
                },
            },
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
            },
            {
                title = "GUI: Render Custom Names",
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
            },
            {
                title = "GUI: Render Enemy Lifebars",
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
            },
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
            },
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
            },
            {
                title = "Land Unit Selection Priority",
                key = 'land_unit_select_prio',
                type = 'toggle',
                default = 0,
                custom = {
                    states = {
                        {text = "<LOC _Off>", key = 0 },
                        {text = "<LOC _On>", key = 1 },
                    },
                },
            }
        },
    },
    video = {
        title = "Video",
        key = 'video',
        items = {
            {
                title = "Primary Adapter",
                key = 'primary_adapter',
                type = 'toggle',
                default = '1024,768,60',
                verify = true,
                populate = function(value)
                    -- this is a bit odd, but the value of the primary determines how to populate the value of the secondary
                    ConExecute("SC_SecondaryAdapter " .. tostring( 'windowed' == value ))
                end,
                update = function(control,value)
                    ConExecute("SC_SecondaryAdapter " .. tostring( 'windowed' == value ))
                end,
                ignore = function(value)
                    if value == 'overridden' then
                        return '1024,768,60'
                    end
                end,
                set = function(key,value,startup)
                    if not startup then
                        ConExecute("SC_PrimaryAdapter " .. tostring(value))
                    end
                    ConExecute("SC_SecondaryAdapter " .. tostring( 'windowed' == value ))
                end,
                custom = {
                    states = {
                        { text = "Overridden", key = 'overridden' },
                        { text = "Windowed", key = 'windowed' },
                        -- the remaining values are populated at runtime from device caps
                        -- what follows is just an example of the data which will be encountered
                        { text =  "1024x768(60)", key = '1024,768,60' },
                        { text = "1152x864(60)", key = '1152,864,60' },
                        { text = "1280x768(60)", key = '1280,768,60' },
                        { text = "1280x800(60)", key = '1280,800,60' },
                        { text = "1280x1024(60)", key = '1280,1024,60' },
                    },
                },
            },
            {
                title = "Secondary Adapter",
                key = 'secondary_adapter',
                type = 'toggle',
                default = 'disabled',
                restart = true,
                ignore = function(value)
                    if value == 'overridden' then
                        return 'disabled'
                    end
                end,
                custom = {
                    states = {
                        { text = "Overridden", key = 'overridden' },
                        { text = "Disabled", key = 'disabled' },
                        -- the remaining values are populated at runtime from device caps
                        -- what follows is just an example of the data which will be encountered
                        { text =  "1024x768(60)", key = '1024,768,60' },
                        { text = "1152x864(60)", key = '1152,864,60' },
                        { text = "1280x768(60)", key = '1280,768,60' },
                        { text = "1280x800(60)", key = '1280,800,60' },
                        { text = "1280x1024(60)", key = '1280,1024,60' },
                    },
                },
            },
            {
                title = "Fidelity Presets",
                key = 'fidelity_presets',
                type = 'toggle',
                default = 4,
                update = function(control,value)
                    logic = import('/lua/options/optionsLogic.lua')
                    
                    aaoptions = GetAntiAliasingOptions()

                    aamax = 0
                    aamed = 0
                    if 0 < table.getn(aaoptions) then
						aahigh = aaoptions[table.getn(aaoptions)]
						aamed = aaoptions[math.ceil(table.getn(aaoptions)/2)]
					end
					
                    if 0 == value then
                        logic.SetValue('fidelity',0,true)
                        logic.SetValue('shadow_quality',0,true)
                        logic.SetValue('texture_level',2,true)
                        logic.SetValue('antialiasing',0,true)
                        logic.SetValue('level_of_detail',0,true)
                        logic.SetValue('bloom_render',0,true)
                        logic.SetValue('render_skydome',0,true)
                    elseif 1 == value then
                        logic.SetValue('fidelity',1,true)
                        logic.SetValue('shadow_quality',1,true)
                        logic.SetValue('texture_level',1,true)
                        logic.SetValue('antialiasing',0,true)
                        logic.SetValue('level_of_detail',1,true)
                        logic.SetValue('bloom_render',0,true)
                        logic.SetValue('render_skydome',1,true)
                    elseif 2 == value then
                        logic.SetValue('fidelity',2,true)
                        logic.SetValue('shadow_quality',2,true)
                        logic.SetValue('texture_level',0,true)
                        logic.SetValue('antialiasing',aamed,true)
                        logic.SetValue('level_of_detail',2,true)
                        logic.SetValue('bloom_render',1,true)
                        logic.SetValue('render_skydome',1,true)
                    elseif 3 == value then
                        logic.SetValue('fidelity',2,true)
                        logic.SetValue('shadow_quality',3,true)
                        logic.SetValue('texture_level',0,true)
                        logic.SetValue('antialiasing',aahigh,true)
                        logic.SetValue('level_of_detail',2,true)
                        logic.SetValue('bloom_render',1,true)
                        logic.SetValue('render_skydome',1,true)
                    else
                    end
                end,
                set = function(key,value,startup)
                end,
                custom = {
                    states = {
                        { text = "Low", key = 0 },
                        { text = "Medium", key = 1 },
                        { text = "High", key = 2 },
                        { text = "Ultra", key = 3 },
                        { text = "Custom", key = 4 },
                    },
                },
            },
            {
                title = "Render Sky",
                key = 'render_skydome',
                type = 'toggle',
                default = 1,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("ren_Skydome " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Fidelity",
                key = 'fidelity',
                type = 'toggle',
                default = 1,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("graphics_Fidelity " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Low", key = 0},
                        {text = "Medium", key = 1},
                        {text = "High", key = 2},
                    },
                },
            },
            {
                title = "Shadow Fidelity",
                key = 'shadow_quality',
                type = 'toggle',
                default = 1,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("shadow_Fidelity " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0},
                        {text = "Low", key = 1},
                        {text = "Medium", key = 2},
                        {text = "High", key = 3},
                    },
                },
            },
            {
                title = "Anti-Aliasing",
                key = 'antialiasing',
                type = 'toggle',
                default = 0,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    if not startup then
                        ConExecute("SC_AntiAliasingSamples " .. tostring(value))
                    end
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0},
                        -- the remaining values are populated at runtime from device caps
                        -- what follows is just an example of the data which will be encountered
                        {text =  "2", key =  2},
                        {text =  "4", key =  4},
                        {text =  "8", key =  8},
                        {text = "16", key = 16},
                    },
                },
            },
            {
                title = "Texture Detail",
                key = 'texture_level',
                type = 'toggle',
                default = 1,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("ren_MipSkipLevels " .. tostring(value))
                end,
                custom = {
                    states = {
                        { text = "Low", key = 2 },
                        { text = "Medium", key = 1 },
                        { text = "High", key = 0 },
                    },
                },
            },
            {
                title = "Level Of Detail",
                key = 'level_of_detail',
                type = 'toggle',
                default = 1,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("SC_CameraScaleLOD " .. tostring(value))
                end,
                custom = {
                    states = {
                        { text = "Low", key = 0 },
                        { text = "Medium", key = 1 },
                        { text = "High", key = 2 },
                    },
                },
            },
            {
                title = "Vertical Sync",
                key = 'vsync',
                type = 'toggle',
                default = 1,
                set = function(key,value,startup)
                    if not startup then
                        ConExecute("SC_VerticalSync " .. tostring(value))
                    end
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            },
            {
                title = "Bloom Render",
                key = 'bloom_render',
                type = 'toggle',
                default = 0,
                update = function(control,value)
                    import('/lua/options/optionsLogic.lua').SetValue('fidelity_presets',4,true)
                end,
                set = function(key,value,startup)
                    ConExecute("ren_bloom " .. tostring(value))
                end,
                custom = {
                    states = {
                        {text = "Off", key = 0 },
                        {text = "On", key = 1 },
                    },
                },
            }
        },
    },
    sound = {
        title = "Sound",
        items = {
            {
                title = "Master Volume",
                key = 'master_volume',
                type = 'slider',
                default = 100,
                
                init = function()
                    savedMasterVol = GetVolume("Global")
                end,
                
                cancel = function()
                    if savedMasterVol then
                        SetVolume("Global", savedMasterVol)
                    end
                end,
                
                set = function(key,value,startup)
                    SetVolume("Global", value / 100)
                    savedMasterVol = value/100                
                end,
                update = function(control,value)
                    SetVolume("Global", value / 100)
                end,
                custom = {
                    min = 0,
                    max = 100,
                    inc = 1,
                },
            },
            {
                title = "FX Volume",
                key = 'fx_volume',
                type = 'slider',
                default = 100,

                init = function()
                    savedFXVol = GetVolume("World")
                end,
                
                cancel = function()
                    if savedFXVol then
                        SetVolume("World", savedFXVol)
                        SetVolume("Interface", savedFXVol)
                    end
                end,

                set = function(key,value,startup)
                    SetVolume("World", value / 100)
                    SetVolume("Interface", value / 100)
                    savedFXVol = value/100
                end,
               
                update = function(control,value)
                    SetVolume("World", value / 100)
                    SetVolume("Interface", value / 100)
                    PlayTestSound()
                end,
                
                custom = {
                    min = 0,
                    max = 100,
                    inc = 1,
                },
            },
            {
                title = "Music Volume",
                key = 'music_volume',
                type = 'slider',
                default = 100,

                init = function()
                    savedMusicVol = GetVolume("Music")
                end,
                
                cancel = function()
                    if savedMusicVol then
                        SetVolume("Music", savedMusicVol)
                    end
                end,

                set = function(key,value,startup)
                    SetVolume("Music", value / 100)
                    savedMusicVol = value/100
                end,
                update = function(key,value)
                    SetVolume("Music", value / 100)
                end,
                custom = {
                    min = 0,
                    max = 100,
                    inc = 1,
                },
            },
            {
                title = "VO Volume",
                key = 'vo_volume',
                type = 'slider',
                default = 100,

                init = function()
                    savedVOVol = GetVolume("VO")
                end,
                
                cancel = function()
                    if savedVOVol then
                        SetVolume("VO", savedVOVol)
                    end
                end,

                set = function(key,value,startup)
                    SetVolume("VO", value / 100)
                    savedVOVol = value/100
                end,
                update = function(key,value)
                    SetVolume("VO", value / 100)
                    PlayTestVoice()
                end,
                custom = {
                    min = 0,
                    max = 100,
                    inc = 1,
                },
            },
        },
    },
}
