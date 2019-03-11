do		
	local Prefs = import('/lua/user/prefs.lua')
	local options = Prefs.GetFromCurrentProfile('options')
	local Effect = import('/lua/maui/effecthelpers.lua')
    -- norem
    local TemplatesFactory = import('/mods/GAZ_UI/modules/templates_factory.lua')

--[[

	local oldOnSelection = OnSelection
	
	function OnSelection(buildableCategories, selection, isOldSelection)
	
		oldOnSelection(buildableCategories, selection, isOldSelection)

		if table.getsize(selection) > 0 then
			--repeated from original to access the local variables
	        local allSameUnit = true
	        local bpID = false
	        local allMobile = true
	        for i, v in selection do
	            if allMobile and not v:IsInCategory('MOBILE') then
	                allMobile = false
	            end
	            if allSameUnit and bpID and bpID != v:GetBlueprint().BlueprintId then
	                allSameUnit = false
	            else
	                bpID = v:GetBlueprint().BlueprintId
	            end
	            if not allMobile and not allSameUnit then
	                break
	            end
	        end

			--Upgrade multiple SCU at once
			if selection[1]:GetBlueprint().Enhancements and allSameUnit then
				controls.enhancementTab:Enable()
			end
			
			--Allow all races to build other races templates
			if options.gui_all_race_templates != 0 then
				local templates = Templates.GetTemplates()
		        local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
		        if allMobile and templates and table.getsize(templates) > 0 then
					local currentFaction = selection[1]:GetBlueprint().General.FactionName
					if currentFaction then
			            sortedOptions.templates = {}
						local function ConvertID(BPID)
							local prefixes = {
								["AEON"] = {
									"uab",
									"xab",
									"dab",
								},
								["UEF"] = {
									"ueb",
									"xeb",
									"deb",
								},
								["CYBRAN"] = {
									"urb",
									"xrb",
									"drb",
								},
								["SERAPHIM"] = {
									"xsb",
									"usb",
									"dsb",
								},
							}
							for i, prefix in prefixes[string.upper(currentFaction)] do
								if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
									return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
								end
							end
							return false
						end
						
			            for templateIndex, template in templates do
			                local valid = true
							local converted = false
							
			                for _, entry in template.templateData do
							
			                    if type(entry) == 'table' then
								
			                        if not table.find(buildableUnits, entry[1]) then

										entry[1] = ConvertID(entry[1])
										
										converted = true
										
				                        if not table.find(buildableUnits, entry[1]) then
											valid = false
				                            break
										end
			                        end
			                    end
			                end
							
			                if valid then
								if converted then
									template.icon = ConvertID(template.icon)
			                    end
								template.templateID = templateIndex
			                    table.insert(sortedOptions.templates, template)
							end
		                end
		            end

					--refresh the construction tab to show any new available templates
					if not isOldSelection then
			            if not controls.constructionTab:IsDisabled() then
			                controls.constructionTab:SetCheck(true)
			            else
			                controls.selectionTab:SetCheck(true)
			            end
			        elseif controls.constructionTab:IsChecked() then
			            controls.constructionTab:SetCheck(true)
			        elseif controls.enhancementTab:IsChecked() then
			            controls.enhancementTab:SetCheck(true)
			        else
			            controls.selectionTab:SetCheck(true)
			        end
		        end
			end
		end
	end
--]]

	--template rotator
	if options.gui_template_rotator != 0 then
	
		local oldOnClickHandler = OnClickHandler
		
		function OnClickHandler(button, modifiers)
		
			oldOnClickHandler(button, modifiers)
			
			local item = button.Data
			
			if item.type == "templates" then
			
				local activeTemplate = item.template.templateData
				local worldview = import('/lua/ui/game/worldview.lua').viewLeft
				local oldHandleEvent = worldview.HandleEvent
				
				worldview.HandleEvent = function(self, event)
				
					if event.Type == 'ButtonPress' then
					
						if event.Modifiers.Middle then
						
							ClearBuildTemplates()
							
							local tempTemplate = table.deepcopy(activeTemplate)
							
							for i = 3, table.getn(activeTemplate) do
								local index = i
								activeTemplate[index][3] = 0 - tempTemplate[index][4]
								activeTemplate[index][4] = tempTemplate[index][3]
							end
							
							SetActiveBuildTemplate(activeTemplate)
							
						elseif
							event.Modifiers.Shift then
							
						else
							worldview.HandleEvent = oldHandleEvent
						end
					end
				end
			end
		end
	end

	--draggable build queue
	if options.gui_draggable_queue != 0 then
		local dragging = false
		local index = nil			--index of the item in the queue currently being dragged
		local originalIndex = false	--original index of selected item (so that UpdateBuildQueue knows where to modify it from)
		local oldQueue = {}
		local modifiedQueue = {}
		local updateQueue = true	--if false then queue won't update in the ui
		local modified = false		--if false then buttonrelease will increase buildcount in queue
		local dragLock = false		--to disable quick successive drags, which doubles the units in the queue

		--add gameparent handleevent for if the drag ends outside the queue window
		local gameParent = import('gamemain.lua').GetGameParent()
		local oldGameParentHandleEvent = gameParent.HandleEvent
		gameParent.HandleEvent = function(self, event)
			if event.Type == 'ButtonRelease' then
				import('/lua/ui/game/construction.lua').ButtonReleaseCallback()
			end
			oldGameParentHandleEvent(self, event)
		end 

		function MoveItemInQueue(queue, indexfrom, indexto)
			modified = true
			local moveditem = queue[indexfrom]
			if indexfrom < indexto then
				--take indexfrom out and shunt all indices from indexfrom to indexto up one
				for i = indexfrom, (indexto - 1) do
					queue[i] = queue[i+1]
				end
			elseif indexfrom > indexto then
				--take indexfrom out and shunt all indices from indexto to indexfrom down one
				for i = indexfrom, (indexto + 1), -1 do
					queue[i] = queue[i-1]
				end
			end
			queue[indexto] = moveditem
			modifiedQueue = queue
			currentCommandQueue = queue
			--update buttons in the UI
			SetSecondaryDisplay('buildQueue')
		end

		function UpdateBuildList(newqueue, from)
		    --The way this does this is UGLY but I can only find functions to remove things from the build queue and to add them at the end
			--Thus the only way I can see to modify the build queue is to delete it back to the point it is modified from (the from argument) and then 
		    --add the modified version back in. Unfortunately this causes a momentary 'skip' in the displayed build cue as it is deleted and replaced

			for i = table.getn(oldQueue), from, -1  do
				DecreaseBuildCountInQueue(i, oldQueue[i].count)	
			end
			for i = from, table.getn(newqueue)  do
		        blueprint = __blueprints[newqueue[i].id]
		        if blueprint.General.UpgradesFrom == 'none' then
				    IssueBlueprintCommand("UNITCOMMAND_BuildFactory", newqueue[i].id, newqueue[i].count)
				else
				    IssueBlueprintCommand("UNITCOMMAND_Upgrade", newqueue[i].id, 1, false)
		        end
			end
			ForkThread(dragPause)
		end

		function dragPause()
			WaitSeconds(0.4)
			dragLock = false
		end

		function ButtonReleaseCallback()
		    if dragging == true then
			    PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
				--don't update the queue next time round, to avoid a list of 0 builds
				updateQueue = false
				--disable dragging until the queue is rebuilt
				dragLock = true
				--reset modified so buildcount increasing can be used again
				modified = false
		        --mouse button released so end drag
		        dragging = false
				if originalIndex <= index then
			        first_modified_index = originalIndex
				else 
					first_modified_index = index
				end
				--on the release of the mouse button we want to update the ACTUAL build queue that the factory does. So far, only the UI has been changed,
				UpdateBuildList(modifiedQueue, first_modified_index)
				--nothing is now selected
				index = nil    
		    end  
		end
		
		--don't update the queue the tick after a buttonreleasecallback
		local oldSetSecondaryDisplay = SetSecondaryDisplay
		function SetSecondaryDisplay(type)
			if updateQueue then
				oldSetSecondaryDisplay(type)
			else
				updateQueue = true
			end
		end
		
		local oldOnRolloverHandler = OnRolloverHandler
		function OnRolloverHandler(button, state)
		    local item = button.Data
			if item.type == 'queuestack' and prevSelection and EntityCategoryContains(categories.FACTORY, prevSelection[1]) then
			    if state == 'enter' then
					button.oldHandleEvent = button.HandleEvent
					--if we have entered the button and are dragging something then we want to replace it with what we are dragging
					if dragging == true then
						--move item from old location (index) to new location (this button's index)
						MoveItemInQueue(currentCommandQueue, index, item.position) 
						--since the currently selected button has now moved, update the index
						index = item.position
						
						button.dragMarker = Bitmap(button, '/mods/GAZ_UI/textures/queuedragger.dds')
						LayoutHelpers.FillParent(button.dragMarker, button)
						button.dragMarker:DisableHitTest()
						Effect.Pulse(button.dragMarker, 1.5, 0.6, 0.8)
		
					end
					button.HandleEvent = function(self, event)
						if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
							local count = 1
			                if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
			                    count = 5
			                end

			                if event.Modifiers.Left then
								if not dragLock then
									--left button pressed so start dragging procedure
									dragging = true
									index = item.position
									originalIndex = index
									
									self.dragMarker = Bitmap(self, '/mods/GAZ_UI/textures/queuedragger.dds')
									LayoutHelpers.FillParent(self.dragMarker, self)
									self.dragMarker:DisableHitTest()
									Effect.Pulse(self.dragMarker, 1.5, 0.6, 0.8)
									
									--copy un modified queue so that current build order is recorded (for deleting it)
									oldQueue = table.copy(currentCommandQueue)
								end
			                else
								PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
			                    DecreaseBuildCountInQueue(item.position, count)
			                end
						elseif event.Type == 'ButtonRelease' then
							if dragging then
								--if queue has changed then update queue, else increase build count (like default)
								if modified then
									ButtonReleaseCallback()
								else
									PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
									dragging = false
									local count = 1
					                if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
					                    count = 5
					                end
									IncreaseBuildCountInQueue(item.position, count)
								end
								if self.dragMarker then
									self.dragMarker:Destroy()
									self.dragMarker = false
								end
							end
						else
							button.oldHandleEvent(self, event)
						end
					end
					button.Glow:SetNeedsFrameUpdate(true)
			    else
					if button.oldHandleEvent then
						button.HandleEvent = button.oldHandleEvent
					else
						WARN('OLD HANDLE EVENT MISSING HOW DID THIS HAPPEN?!')
					end
					if button.dragMarker then
						button.dragMarker:Destroy()
						button.dragMarker = false
					end
					button.Glow:SetNeedsFrameUpdate(false)
			        button.Glow:SetAlpha(0)
			        UnitViewDetail.Hide()
			    end
			else
				oldOnRolloverHandler(button, state)
			end
		end
	end
    
    -- norem Factory Templates
    local allFactories = nil
    
    if options.gui_templates_factory != 0 then
        allFactories = false
        
        -- "Create Template" button
        local oldFormatData = FormatData
        function FormatData(unitData, type)
            -- replace inf button when factory is paused and in templates tab
			-- removed the need for the factory to be paused - LOUD
            if type == 'templates' and allFactories then --and controls.extraBtn2:IsChecked() then
                local ret = oldFormatData(unitData, type)
                
                -- replace Infinite queue by Create template
                Tooltip.AddCheckboxTooltip(controls.extraBtn1, 'save_template')
                if table.getsize(currentCommandQueue) > 0 then
                    controls.extraBtn1:Enable()
                    controls.extraBtn1.OnClick = function(self, modifiers)
                        TemplatesFactory.CreateBuildTemplate(currentCommandQueue)
                    end
                else
                    controls.extraBtn1:Disable()
                end
                controls.extraBtn1.icon.OnTexture = UIUtil.UIFile('/game/construct-sm_btn/template_on.dds')
                controls.extraBtn1.icon.OffTexture = UIUtil.UIFile('/game/construct-sm_btn/template_off.dds')
                if controls.extraBtn1:IsDisabled() then
                    controls.extraBtn1.icon:SetTexture(controls.extraBtn1.icon.OffTexture)
                else
                    controls.extraBtn1.icon:SetTexture(controls.extraBtn1.icon.OnTexture)
                end
                
                return ret
            else
                return oldFormatData(unitData, type)
            end
        end
        
        -- add valid templates for selection
        local oldOnSelection = OnSelection
        function OnSelection(buildableCategories, selection, isOldSelection)
            if table.empty(selection) then
                allFactories = false
            else
                allFactories = true
                for i, v in selection do
                    if not v:IsInCategory('FACTORY') then
                        allFactories = false
                        break
                    end
                end
            end
            
            oldOnSelection(buildableCategories, selection, isOldSelection)
            
            if allFactories then
                sortedOptions.templates = {}
                local templates = TemplatesFactory.GetTemplates()
                if templates and not table.empty(templates) then
                    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
                    for templateIndex, template in ipairs(templates) do
                        local valid = true
                        for index, entry in ipairs(template.templateData) do
                            if not table.find(buildableUnits, entry.id) then
                                valid = false
                                -- allow templates containing factory upgrades & higher tech units
                                if index > 1 then
                                    for i = index - 1, 1, -1 do
                                        local blueprint = __blueprints[template.templateData[i].id]
                                        if blueprint.General.UpgradesFrom ~= 'none' then
                                            -- previous entry is a (valid) upgrade
                                            valid = true
                                            break
                                        end
                                    end
                                end
                                break
                            end
                        end
                        if valid then
                            template.templateID = templateIndex
                            table.insert(sortedOptions.templates, template)
                        end
                    end
                end
                
                -- templates tab enable & refresh
                local templatesTab = GetTabByID('templates')
                if templatesTab then
                    templatesTab:Enable()
                    if templatesTab:IsChecked() then
                        templatesTab:SetCheck(true)
                    end
                end
            end
        end
        
        -- construction tab, this is called before fac templates have been added
        local oldCreateTabs = CreateTabs
        function CreateTabs(type)
            if type == 'construction' and allFactories then
                -- nil value would cause refresh issues if templates tab is currently selected
                sortedOptions.templates = {}
                
                -- prevent tab autoselection when in templates tab,
                -- normally triggered when number of active tabs has changed (fac upgrade added/removed from queue)
                local templatesTab = GetTabByID('templates')
                if templatesTab and templatesTab:IsChecked() then
                    local numActive = 0
                    for _, tab in controls.tabs do
                        if sortedOptions[tab.ID] and table.getn(sortedOptions[tab.ID]) > 0 then
                            numActive = numActive + 1
                        end
                    end
                    previousTabSize = numActive
                end
            end
            
            oldCreateTabs(type)
        end
        
        -- click actions
        local oldOnClickHandler = OnClickHandler
        function OnClickHandler(button, modifiers)
            local item = button.Data
            if item.type == "templates" and allFactories then
                PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
                if modifiers.Right then
                    -- options menu
                    if button.OptionMenu then
                        button.OptionMenu:Destroy()
                        button.OptionMenu = nil
                    else
                        button.OptionMenu = CreateFacTemplateOptionsMenu(button)
                    end
                    for _, otherBtn in controls.choices.Items do
                        if button != otherBtn and otherBtn.OptionMenu then
                            otherBtn.OptionMenu:Destroy()
                            otherBtn.OptionMenu = false
                        end
                    end
                else
                    -- add template to build queue
                    for _, data in ipairs(item.template.templateData) do
                        local blueprint = __blueprints[data.id]
                        if blueprint.General.UpgradesFrom == 'none' then
                            IssueBlueprintCommand("UNITCOMMAND_BuildFactory", data.id, data.count)
                        else
                            IssueBlueprintCommand("UNITCOMMAND_Upgrade", data.id, 1, false)
                        end
                    end
                end
            else
                oldOnClickHandler(button, modifiers)
            end
        end
        
        -- keybinding
        local oldProcessKeybinding = ProcessKeybinding
        function ProcessKeybinding(key, templateID)
            if allFactories then
                if key == UIUtil.VK_ESCAPE then
                    TemplatesFactory.ClearTemplateKey(capturingKeys or templateID)
                    RefreshUI()
                elseif key == string.byte('b') or key == string.byte('B') then
                    warningtext:SetText(LOC("<LOC CONSTRUCT_0005>Key must not be b!"))
                else
                    if (key >= string.byte('A') and key <= string.byte('Z')) or (key >= string.byte('a') and key <= string.byte('z')) then
                        if (key >= string.byte('a') and key <= string.byte('z')) then
                            key = string.byte(string.upper(string.char(key)))
                        end
                        if TemplatesFactory.SetTemplateKey(capturingKeys or templateID, key) then
                            RefreshUI()
                        else
                            warningtext:SetText(LOCF("<LOC CONSTRUCT_0006>%s is already used!", string.char(key)))
                        end
                    else
                        warningtext:SetText(LOC("<LOC CONSTRUCT_0007>Key must be a-z!"))
                    end
                end
                return true
            else
                oldProcessKeybinding(key, templateID)
            end
        end
        
        -- options menu
        function CreateFacTemplateOptionsMenu(button)
            local group = Group(button)
            group.Depth:Set(button:GetRootFrame():GetTopmostDepth() + 1)
            local title = Edit(group)
            local items = {
                {label = '<LOC _Rename>Rename',
                action = function()
                    title:AcquireFocus()
                end,},
                {label = '<LOC _Change_Icon>Change Icon',
                action = function()
                    local contents = {}
                    local controls = {}
                    for _, entry in button.Data.template.templateData do
                        if type(entry) != 'table' then continue end
                        if not contents[entry.id] then
                            contents[entry.id] = true
                        end
                    end
                    for iconType, _ in contents do
                        local bmp = Bitmap(group, '/textures/ui/common/icons/units/'..iconType..'_icon.dds')
                        bmp.Height:Set(30)
                        bmp.Width:Set(30)
                        bmp.ID = iconType
                        table.insert(controls, bmp)
                    end
                    group.SubMenu = CreateSubMenu(group, controls, function(id)
                        TemplatesFactory.SetTemplateIcon(button.Data.template.templateID, id)
                        RefreshUI()
                    end)
                end,
                arrow = true},
                {label = '<LOC _Change_Keybinding>Change Keybinding',
                action = function()
                    local text = UIUtil.CreateText(group, "<LOC CONSTRUCT_0008>Press a key to bind", 12, UIUtil.bodyFont)
                    if not BuildMode.IsInBuildMode() then
                        text:AcquireKeyboardFocus(false)
                        text.HandleEvent = function(self, event)
                            if event.Type == 'KeyDown' then
                                ProcessKeybinding(event.KeyCode, button.Data.template.templateID)
                            end
                            return true
                        end
                        local oldTextOnDestroy = text.OnDestroy
                        text.OnDestroy = function(self)
                            text:AbandonKeyboardFocus()
                            oldTextOnDestroy(self)
                        end
                    else
                        capturingKeys = button.Data.template.templateID
                    end
                    warningtext = text
                    group.SubMenu = CreateSubMenu(group, {text}, function(id)
                        TemplatesFactory.SetTemplateKey(button.Data.template.templateID, id)
                        RefreshUI()
                    end, false)
                end,},
                {label = '<LOC _Send_to>Send to',
                -- menu item disabled but not removed, to be consistent with standard templates menu
                action = function()
                    LOG('Send templates disabled')
                end,
                disabledFunc = function()
                    return true
                end,},
                {label = '<LOC _Delete>Delete',
                action = function()
                    TemplatesFactory.RemoveTemplate(button.Data.template.templateID)
                    RefreshUI()
                end,},
            }
            local function CreateItem(data)
                local bg = Bitmap(group)
                bg:SetSolidColor('00000000')
                bg.label = UIUtil.CreateText(bg, LOC(data.label), 12, UIUtil.bodyFont)
                bg.label:DisableHitTest()
                LayoutHelpers.AtLeftTopIn(bg.label, bg, 2)
                bg.Height:Set(function() return bg.label.Height() + 2 end)
                bg.HandleEvent = function(self, event)
                    if event.Type == 'MouseEnter' then
                        self:SetSolidColor('ff777777')
                    elseif event.Type == 'MouseExit' then
                        self:SetSolidColor('00000000')
                    elseif event.Type == 'ButtonPress' then
                        if group.SubMenu then
                            group.SubMenu:Destroy()
                            group.SubMenu = false
                        end
                        data.action()
                    end
                    return true
                end
                
                if data.disabledFunc and data.disabledFunc() then
                    bg:Disable()
                    bg.label:SetColor('ff777777')
                end
                
                return bg
            end
            local totHeight = 0
            local maxWidth = 0
            title.Height:Set(function() return title:GetFontHeight() end)
            title.Width:Set(function() return title:GetStringAdvance(LOC(button.Data.template.name)) end)
            UIUtil.SetupEditStd(title, "ffffffff", nil, "ffaaffaa", UIUtil.highlightColor, UIUtil.bodyFont, 14, 200)
            title:SetDropShadow(true)
            title:ShowBackground(true)
            title:SetText(LOC(button.Data.template.name))
            LayoutHelpers.AtLeftTopIn(title, group)
            totHeight = totHeight + title.Height()
            maxWidth = math.max(maxWidth, title.Width())
            local itemControls = {}
            local prevControl = false
            for index, actionData in items do
                local i = index
                itemControls[i] = CreateItem(actionData)
                if prevControl then
                    LayoutHelpers.Below(itemControls[i], prevControl)
                else
                    LayoutHelpers.Below(itemControls[i], title)
                end
                totHeight = totHeight + itemControls[i].Height()
                maxWidth = math.max(maxWidth, itemControls[i].label.Width()+4)
                prevControl = itemControls[i]
            end
            for _, control in itemControls do
                control.Width:Set(maxWidth)
            end
            title.Width:Set(maxWidth)
            group.Height:Set(totHeight)
            group.Width:Set(maxWidth)
            LayoutHelpers.Above(group, button, 10)
            
            title.HandleEvent = function(self, event)
                Edit.HandleEvent(self, event)
                return true
            end
            title.OnEnterPressed = function(self, text)
                TemplatesFactory.RenameTemplate(button.Data.template.templateID, text)
                RefreshUI()
            end
            
            local bg = CreateMenuBorder(group)
            
            group.HandleEvent = function(self, event)
                return true
            end
            
            return group
        end
    end
    
    --visible template names -ghaleon
    if options.gui_visible_template_names != 0 then
        local cutA = 0
        local cutB = 0
        if options.gui_template_name_cutoff != nil then
            cutA = options.gui_template_name_cutoff
            cutB = options.gui_template_name_cutoff
        end
        cutA = cutA + 1
        cutB = cutB + 7

        local oldCommonLogic = CommonLogic
        function CommonLogic()
            oldCommonLogic()
            local oldSecondary = controls.secondaryChoices.SetControlToType
            local oldPrimary = controls.choices.SetControlToType
            local oldPrimaryCreate = controls.choices.CreateElement
            controls.choices.CreateElement = function()
                local btn = oldPrimaryCreate()
-- creating the display area
                btn.Tmplnm = UIUtil.CreateText(btn.Icon, '', 11, UIUtil.bodyFont)
                btn.Tmplnm:SetColor('ffffff00')
                btn.Tmplnm:DisableHitTest()
                btn.Tmplnm:SetDropShadow(true)
                btn.Tmplnm:SetCenteredHorizontally(true)
                LayoutHelpers.CenteredBelow(btn.Tmplnm, btn, 0)
                btn.Tmplnm.Depth:Set(function() return btn.Icon.Depth() + 10 end)
                return btn
            end
            controls.secondaryChoices.SetControlToType = function(control, type)
                oldSecondary(control, type)
            end
            controls.choices.SetControlToType = function(control, type)
                oldPrimary(control, type)
-- the text
                if type == 'templates' and 'templates' then
                    control.Tmplnm.Width:Set(48)
                    control.Tmplnm:SetText(string.sub(control.Data.template.name, cutA, cutB))
                end
            end
        end
    end

    --Improved unit deselection -ghaleon
    if options.gui_improved_unit_deselection != 0 then
        local oldOnClickHandler = OnClickHandler
        function OnClickHandler(button, modifiers)
            local item = button.Data
            if item.type == 'unitstack' then
                if modifiers.Right then
                    if modifiers.Shift or modifiers.Ctrl or (modifiers.Shift and modifiers.Ctrl) then -- we have one of our modifiers
                        local selectionx = {}
                        local countx = 0
                        if modifiers.Shift then countx = 1 end 
                        if modifiers.Ctrl then countx = 5 end
                        if modifiers.Shift and modifiers.Ctrl then countx = 10 end
                        for _, unit in sortedOptions.selection do
                            local foundx = false
                            for _, checkUnit in item.units do
                                if checkUnit == unit and countx > 0 then
                                    foundx = true
                                    countx = countx - 1
                                    break
                                end
                            end
                            if not foundx then
                                table.insert(selectionx, unit)
                            end
                        end
                        SelectUnits(selectionx)
                    else -- default right-click behavior
                        local selection = {}
                        for _, unit in sortedOptions.selection do
                            local found = false
                            for _, checkUnit in item.units do
                                if checkUnit == unit then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(selection, unit)
                            end
                        end
                        SelectUnits(selection)
                    end
                end
                -- override default rightclick handler
                if modifiers.Right then return end
                -- else new code does not work as intended
            end
            oldOnClickHandler(button, modifiers)
        end
    end    
end
