do
	local Prefs = import('/lua/user/prefs.lua')
	local options = Prefs.GetFromCurrentProfile('options')
	
	--middle click select all idle on screen
	if options.gui_idle_engineer_avatars != 0 then
		local oldClickFunc = ClickFunc
		function ClickFunc(self, event)
			if event.Type == 'ButtonPress' and event.Modifiers.Middle then
				if self.id then --it's a primary idle unit button, deal with all units
					if event.Modifiers.Shift then
						local curUnits = {}
						curUnits = GetSelectedUnits() or {}
						UISelectionByCategory(string.upper(self.id), false, true, false, true)
						local newSelection = GetSelectedUnits() or {}
						for i, unit in newSelection do
							table.insert(curUnits, unit)
						end
						SelectUnits(curUnits)
					else
						UISelectionByCategory(string.upper(self.id), false, true, false, true)
					end
				elseif self.ID then --it's an ACU icon
				else --it's a submenu button, restrict selection to tech levels
					if self.units[1] then
						local function UnitIsInList(testUnit)
							for i, unit in self.units do
								if unit == testUnit then
									return true
								end
							end
							return false
						end
						
						local curUnits = {}
						if event.Modifiers.Shift then
							curUnits = GetSelectedUnits() or {}
						end

						if self.units[1]:IsInCategory('ENGINEER') then
							UISelectionByCategory('ENGINEER', false, true, false, true)
						else
							UISelectionByCategory('FACTORY', false, true, false, true)
						end
						local tempSelection = GetSelectedUnits() or {}
						for i, unit in tempSelection do
							if UnitIsInList(unit) then
								table.insert(curUnits, unit)
							end
						end
						
						SelectUnits(curUnits)
					end
				end
				return true
			else
				return oldClickFunc(self, event)
			end
		end
	end
	
	--scu manager
	if options.gui_scu_manager != 0 then

		--display the upgrade buttons when there is a valid scu
		local oldAvatarUpdate = AvatarUpdate
		
		function AvatarUpdate()
		
			oldAvatarUpdate()
			
			local buttons = import('/mods/GAZ_UI/modules/scumanager.lua').buttonGroup
			local showing = false
			
			if controls.idleEngineers then
			
				local subCommanders = EntityCategoryFilterDown(categories.SUBCOMMANDER, GetIdleEngineers())
				
				if table.getsize(subCommanders) > 0 then
				
					local show = false
					
					for i, unit in subCommanders do
						if not unit.SCUType then
							show = true
							break
						end
					end
					
					if show then
						buttons:Show()
						buttons.Right:Set(function() return controls.collapseArrow.Right() - 2 end)
						buttons.Top:Set(function() return controls.collapseArrow.Bottom() end)
						showing = true
					end
					
				end
				
			end
			
			if not showing then
				buttons:Hide()
			end
		end
	end
end
