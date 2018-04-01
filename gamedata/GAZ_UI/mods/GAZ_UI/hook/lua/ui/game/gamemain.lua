do
	local Prefs = import('/lua/user/prefs.lua')
	local options = Prefs.GetFromCurrentProfile('options')
	if options.gui_scu_manager != 0 then
		local originalCreateUI = CreateUI
		function CreateUI(isReplay)
		    originalCreateUI(isReplay)
			import('/mods/GAZ_UI/modules/scumanager.lua').Init()
		end
	end
    if options.gui_render_enemy_lifebars == 1 or options.gui_render_custom_names == 0 then
        local originalCreateUI2 = CreateUI
        function CreateUI(isReplay)
            originalCreateUI2(isReplay)
            import('/mods/GAZ_UI/modules/console_commands.lua').Init()
        end
    end

	local originalOnSelectionChanged = OnSelectionChanged

	function OnSelectionChanged(oldSelection, newSelection, added, removed)
		--run old selection code
		originalOnSelectionChanged(oldSelection, newSelection, added, removed)
		local selUnits = newSelection

      if selUnits 
         and table.getn(selUnits) == 1 
         and import('/mods/GAZ_UI/modules/selectedinfo.lua').SelectedOverlayOn then
			import('/mods/GAZ_UI/modules/selectedinfo.lua').ActivateSingleRangeOverlay()
		else
			import('/mods/GAZ_UI/modules/selectedinfo.lua').DeactivateSingleRangeOverlay()
		end   
	end

	import('/mods/GAZ_UI/modules/keymapping.lua').Init()
end
