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
		--add the 2 extra idle engineer classes
		function CreateIdleEngineerList(parent, units)
		    local group = Group(parent)
		    
		    local bgTop = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_t.dds'))
		    local bgBottom = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_b.dds'))
		    local bgStretch = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/panel-eng_bmp_m.dds'))
		    
		    group.Width:Set(bgTop.Width)
		    group.Height:Set(1)
		    
		    bgTop.Bottom:Set(group.Top)
		    bgBottom.Top:Set(group.Bottom)
		    bgStretch.Top:Set(group.Top)
		    bgStretch.Bottom:Set(group.Bottom)
		    
		    LayoutHelpers.AtHorizontalCenterIn(bgTop, group)
		    LayoutHelpers.AtHorizontalCenterIn(bgBottom, group)
		    LayoutHelpers.AtHorizontalCenterIn(bgStretch, group)
		    
		    group.connector = Bitmap(group, UIUtil.SkinnableFile('/game/avatar-engineers-panel/bracket_bmp.dds'))
		    group.connector.Right:Set(function() return parent.Left() + 8 end)
		    LayoutHelpers.AtVerticalCenterIn(group.connector, parent)
		    
		    LayoutHelpers.LeftOf(group, parent, 10)
		    group.Top:Set(function() return math.max(controls.avatarGroup.Top()+10, (parent.Top() + (parent.Height() / 2)) - (group.Height() / 2)) end)
		    
		    group:DisableHitTest(true)
		    
		    group.icons = {}
		    
		    group.Update = function(self, unitData)
		        local function CreateUnitEntry(techLevel, userUnits, icontexture)
		            local entry = Group(self)
		            
		            entry.icon = Bitmap(entry)
		            if DiskGetFileInfo('/textures/ui/common'..icontexture) then
		                entry.icon:SetTexture('/textures/ui/common'..icontexture)
		            else
		                entry.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
		            end
		            entry.icon.Height:Set(34)
		            entry.icon.Width:Set(34)
		            LayoutHelpers.AtRightIn(entry.icon, entry, 22)
		            LayoutHelpers.AtVerticalCenterIn(entry.icon, entry)
		            
		            entry.iconBG = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds'))
		            LayoutHelpers.AtCenterIn(entry.iconBG, entry.icon)
		            entry.iconBG.Depth:Set(function() return entry.icon.Depth() - 1 end)
		            
					--SCU MANAGER SHOW CORRECT ICON
					if techLevel == 'C' or techLevel == 'E' then
						entry.techIcon = Bitmap(entry, UIUtil.GUITexture('/scumanager/tech-'..techLevel..'_bmp.dds'))
					else
					    entry.techIcon = Bitmap(entry, UIUtil.SkinnableFile('/game/avatar-engineers-panel/tech-'..techLevel..'_bmp.dds'))
		            end
					
					LayoutHelpers.AtLeftIn(entry.techIcon, entry)
		            LayoutHelpers.AtVerticalCenterIn(entry.techIcon, entry.icon)
		            
		            entry.count = UIUtil.CreateText(entry, '', 20, UIUtil.bodyFont)
		            entry.count:SetColor('ffffffff')
		            entry.count:SetDropShadow(true)
		            LayoutHelpers.AtRightIn(entry.count, entry.icon)
		            LayoutHelpers.AtBottomIn(entry.count, entry.icon)
		            
		            entry.countBG = Bitmap(entry)
		            entry.countBG:SetSolidColor('77000000')
		            entry.countBG.Top:Set(function() return entry.count.Top() - 1 end)
		            entry.countBG.Left:Set(function() return entry.count.Left() - 1 end)
		            entry.countBG.Right:Set(function() return entry.count.Right() + 1 end)
		            entry.countBG.Bottom:Set(function() return entry.count.Bottom() + 1 end)
		            
		            entry.countBG.Depth:Set(function() return entry.Depth() + 1 end)
		            entry.count.Depth:Set(function() return entry.countBG.Depth() + 1 end)
		            
		            entry.Height:Set(function() return entry.iconBG.Height() end)
		            entry.Width:Set(self.Width)
		            
		            entry.icon:DisableHitTest()
		            entry.iconBG:DisableHitTest()
		            entry.techIcon:DisableHitTest()
		            entry.count:DisableHitTest()
		            entry.countBG:DisableHitTest()
		            
		            entry.curIndex = 1
		            entry.units = userUnits
		            entry.HandleEvent = ClickFunc
		            
		            return entry
		        end
		        local engineers = {}
				engineers[7] = {}
				engineers[6] = {}
		        engineers[5] = {}
		        engineers[4] = EntityCategoryFilterDown(categories.TECH3 - categories.SUBCOMMANDER, unitData)
		        engineers[3] = EntityCategoryFilterDown(categories.FIELDENGINEER, unitData)
		        engineers[2] = EntityCategoryFilterDown(categories.TECH2 - categories.FIELDENGINEER, unitData)
		        engineers[1] = EntityCategoryFilterDown(categories.TECH1, unitData)
		        
				local tempSCUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, unitData)
				
			    if table.getsize(tempSCUs) > 0 then
					for i, unit in tempSCUs do
						if unit.SCUType then
							if unit.SCUType == 'Combat' then
								table.insert(engineers[7], unit)
							elseif unit.SCUType == 'Engineer' then
			 					table.insert(engineers[6], unit)
							end
						else
							table.insert(engineers[5], unit)
						end
					end
			    end
				
		        local indexToIcon = {'1', '2', '2', '3', '3', 'E', 'C'}
		        local keyToIcon = {'T1','T2','T2F','T3','SCU', 'SCU', 'SCU'}
		        for index, units in engineers do
		            local i = index
		            if i == 3 and currentFaction != 1 then
		                continue
		            end
		            if not self.icons[i] then
		                self.icons[i] = CreateUnitEntry(indexToIcon[i], units, Factions[currentFaction].IdleEngTextures[keyToIcon[index]])
		                self.icons[i].priority = i
		            end
		            if table.getn(units) > 0 and not self.icons[i]:IsHidden() then
		                self.icons[i].units = units
		                self.icons[i].count:SetText(table.getn(units))
		                self.icons[i].count:Show()
		                self.icons[i].countBG:Show()
		                self.icons[i].icon:SetAlpha(1)
		            else
		                self.icons[i].units = {}
		                self.icons[i].count:Hide()
		                self.icons[i].countBG:Hide()
		                self.icons[i].icon:SetAlpha(.2)
		            end
		        end
		        local prevGroup = false
		        local groupHeight = 0
		        for index, engGroup in engineers do
		            local i = index
		            if not self.icons[i] then continue end
		            if prevGroup then
		                LayoutHelpers.Above(self.icons[i], prevGroup)
		            else
		                LayoutHelpers.AtLeftIn(self.icons[i], self, 7)
		                LayoutHelpers.AtBottomIn(self.icons[i], self, 2)
		            end
		            groupHeight = groupHeight + self.icons[i].Height()
		            prevGroup = self.icons[i]
		        end
		        group.Height:Set(groupHeight)
		    end
		    
		    group:Update(units)
		    
		    return group
		end

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
