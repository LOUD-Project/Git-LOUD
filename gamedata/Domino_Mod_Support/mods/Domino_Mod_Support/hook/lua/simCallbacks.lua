
do
	--Toggles
	Callbacks.ToggleTheBit = function(data)
		local Units = data.Params.Units
		local ToggleState = data.Params.ToggleState
		local ToggleName = data.Params.BitName
				
		for i,u in Units do
			local unit = GetEntityById(u)
			if unit and UnitData[u].Data[ToggleName] then 
				if ToggleState then 
					--if true toggle the bit off
					unit.Sync[ToggleName ..'_state'] = ToggleState
					unit:OnExtraToggleSet(ToggleName)
				else
					--if false toggle the bit on
					unit.Sync[ToggleName ..'_state'] = ToggleState
					unit:OnExtraToggleClear(ToggleName)
				end
			end
		end
	end
	
	
	-----------------------------------------------------------------------------
	--Selected Units
	Callbacks.RemoveSelectedUnits = function(data)
		if table.getsize(data.OldSelection) > 0 then
			for i, unit in data.OldSelection do
				if GetEntityById(unit) then 
					local RemUnit = GetEntityById(unit)
							
					if RemUnit then 
						RemUnit.IsSelected = false
					end
				end
			end
		end
	end
	
	Callbacks.UpdateSelectedUnits = function(data)
		if table.getsize(data.NewSelection) > 0 then
			for i, unit in data.NewSelection do
				if GetEntityById(unit) then 
					local SelUnit = GetEntityById(unit)
							
					if SelUnit then 
						SelUnit.IsSelected = true
					end
				end
			end
		end
	end
	
	-----------------------------------------------------------------------------
	
	Callbacks.OnMFDMovieFinished = function(name)
		local flag = import('/mods/Domino_Mod_Support/lua/mfd_video/setup_video.lua').MfdVideoInfo
		if not flag.DialogueFinished[name] and flag.DialogueFinished[name] != nil then 
			import('/mods/Domino_Mod_Support/lua/mfd_video/setup_video.lua').DialogFinished(name)
		end
	end
	
end