local KeyMapper = import('/lua/keymap/keymapper.lua')
local Prefs = import('/lua/user/prefs.lua')

function Init()
    KeyMapper.SetUserKeyAction('toggle_repeat_build', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").ToggleRepeatBuild()', category = 'orders', order = 1})
    KeyMapper.SetUserKeyAction('show_enemy_life', {action = 'UI_ForceLifbarsOnEnemy', category = 'ui', order = 2})
    KeyMapper.SetUserKeyAction('show_network_stats', {action =  'ren_ShowNetworkStats', category = 'ui', order = 3})
    --add key to create an upgrade marker
    KeyMapper.SetUserKeyAction('scu_upgrade_marker', {action =  'UI_Lua import("/lua/gaz_ui/modules/scumanager.lua").CreateMarker()', category = 'user', order = 4})
    KeyMapper.SetUserKeyAction('toggle_shield', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Shield")', category = 'orders', order = 6})
    KeyMapper.SetUserKeyAction('toggle_weapon', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Weapon")', category = 'orders', order = 7})
    KeyMapper.SetUserKeyAction('toggle_jamming', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Jamming")', category = 'orders', order = 8})
    KeyMapper.SetUserKeyAction('toggle_intel', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Intel")', category = 'orders', order = 9})
    KeyMapper.SetUserKeyAction('toggle_production', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Production")', category = 'orders', order = 10})
    KeyMapper.SetUserKeyAction('toggle_stealth', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Stealth")', category = 'orders', order = 11})
    KeyMapper.SetUserKeyAction('toggle_generic', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Generic")', category = 'orders', order = 12})
    KeyMapper.SetUserKeyAction('toggle_special', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Special")', category = 'orders', order = 13})
    KeyMapper.SetUserKeyAction('toggle_cloak', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleScript("Cloak")', category = 'orders', order = 14})
    KeyMapper.SetUserKeyAction('toggle_all', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleAllScript()', category = 'orders', order = 15})
    KeyMapper.SetUserKeyAction('teleport', {action =  'StartCommandMode order RULEUCC_Teleport', category = 'orders', order = 5})
    KeyMapper.SetUserKeyAction('military_overlay', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleOverlay("Military")', category = 'ui', order = 16})
    KeyMapper.SetUserKeyAction('intel_overlay', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleOverlay("Intel")', category = 'ui', order = 17})
    KeyMapper.SetUserKeyAction('select_all_idle_eng_onscreen', {action =  'UI_SelectByCategory +inview +idle ENGINEER', category = 'selection', order = 18})
    KeyMapper.SetUserKeyAction('select_all_similar_units', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetSimilarUnits()', category = 'selection', order = 19})
    KeyMapper.SetUserKeyAction('select_next_land_factory', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetNextLandFactory()', category = 'selection', order = 20})
    KeyMapper.SetUserKeyAction('select_next_air_factory', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetNextAirFactory()', category = 'selection', order = 21})
    KeyMapper.SetUserKeyAction('select_next_naval_factory', {action =  'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetNextNavalFactory()', category = 'selection', order = 22})
    KeyMapper.SetUserKeyAction('toggle_selectedinfo', {action =  'UI_Lua import("/lua/gaz_ui/modules/selectedinfo.lua").ToggleOn()', category = 'ui', order = 23})
    KeyMapper.SetUserKeyAction('toggle_selectedrings', {action =  'UI_Lua import("/lua/gaz_ui/modules/selectedinfo.lua").ToggleOverlayOn()', category = 'ui', order = 24})
    KeyMapper.SetUserKeyAction('toggle_cloakjammingstealth', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleCloakJammingStealthScript()', category = 'orders', order = 25})
    KeyMapper.SetUserKeyAction('toggle_intelshield', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").toggleIntelShieldScript()', category = 'orders', order = 26})
    KeyMapper.SetUserKeyAction('toggle_mdf_panel', {action = 'UI_Lua import("/lua/ui/game/multifunction.lua").ToggleMFDPanel()', category = 'ui', order = 27})
    KeyMapper.SetUserKeyAction('toggle_tab_display', {action = 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTabDisplay()', category = 'ui', order = 28})
    KeyMapper.SetUserKeyAction('zoom_pop', {action = 'UI_Lua import("/lua/gaz_ui/modules/zoompopper.lua").ToggleZoomPop()', category = 'camera', order = 29})
    KeyMapper.SetUserKeyAction('select_inview_idle_mex', {action = 'UI_SelectByCategory +inview +idle MASSEXTRACTION', category = 'selection', order = 30})
    KeyMapper.SetUserKeyAction('select_all_mex', {action = 'UI_SelectByCategory MASSEXTRACTION', category = 'selection', order = 31})
    KeyMapper.SetUserKeyAction('select_nearest_idle_lt_mex', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetNearestIdleLTMex()', category = 'selection', order = 32})
-- by norem
    KeyMapper.SetUserKeyAction('acu_select_cg', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").ACUSelectCG()', category = 'selection', order = 33})
    KeyMapper.SetUserKeyAction('acu_append_cg', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").ACUAppendCG()', category = 'selection', order = 34})
    KeyMapper.SetUserKeyAction('select_nearest_idle_eng_not_acu', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").GetNearestIdleEngineerNotACU()', category = 'selection', order = 35})
    KeyMapper.SetUserKeyAction('add_nearest_idle_engineers_seq', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").AddNearestIdleEngineersSeq()', category = 'selection', order = 36})
    KeyMapper.SetUserKeyAction('cycle_idle_factories', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").CycleIdleFactories()', category = 'selection', order = 37})
    KeyMapper.SetUserKeyAction('cycle_unit_types_in_sel', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").CycleUnitTypesInSel()', category = 'selection', order = 38})

    KeyMapper.SetUserKeyAction('create_template_factory', {action = 'UI_Lua import("/lua/gaz_ui/modules/keymapping.lua").CreateTemplateFactory()', category = 'selection', order = 39})
-- end by norem
-- start Ghaleon
    local number = 40
    KeyMapper.SetUserKeyAction('select_gunships', {action = 'UI_SelectByCategory AIR GROUNDATTACK', category = 'selection', order = number})
    KeyMapper.SetUserKeyAction('select_anti_air_fighters', {action = 'UI_SelectByCategory AIR HIGHALTAIR ANTIAIR', category = 'selection', order = number + 1})
    KeyMapper.SetUserKeyAction('select_all_tml', {action = 'UI_SelectByCategory STRUCTURE TACTICALMISSILEPLATFORM', category = 'selection', order = number + 2})
    KeyMapper.SetUserKeyAction('select_all_stationdrones', {action = 'UI_SelectByCategory AIR STATIONASSISTPOD', category = 'selection', order = number + 3})
    KeyMapper.SetUserKeyAction('select_all_t2_podstations', {action = 'UI_SelectByCategory STRUCTURE PODSTAGINGPLATFORM TECH2', category = 'selection', order = number + 4})
    KeyMapper.SetUserKeyAction('select_all_air_exp', {action = 'UI_SelectByCategory AIR EXPERIMENTAL', category = 'selection', order = number + 5})
    KeyMapper.SetUserKeyAction('select_all_antinavy_subs', {action = 'UI_SelectByCategory SUBMERSIBLE OVERLAYANTINAVY', category = 'selection', order = number + 6})
    KeyMapper.SetUserKeyAction('select_all_land_exp', {action = 'UI_SelectByCategory LAND MOBILE OVERLAYDIRECTFIRE EXPERIMENTAL', category = 'selection', order = number + 7})
    KeyMapper.SetUserKeyAction('select_all_land_indirectfire', {action = 'UI_SelectByCategory LAND OVERLAYINDIRECTFIRE', category = 'selection', order = number + 8})
    KeyMapper.SetUserKeyAction('select_all_land_directfire', {action = 'UI_SelectByCategory +excludeengineers LAND OVERLAYDIRECTFIRE', category = 'selection', order = number + 9})
    KeyMapper.SetUserKeyAction('select_all_air_factories', {action = 'UI_SelectByCategory STRUCTURE FACTORY AIR', category = 'selection', order = number + 10})
    KeyMapper.SetUserKeyAction('select_all_land_factories', {action = 'UI_SelectByCategory STRUCTURE FACTORY LAND', category = 'selection', order = number + 11})
    KeyMapper.SetUserKeyAction('select_all_naval_factories', {action = 'UI_SelectByCategory STRUCTURE FACTORY NAVAL', category = 'selection', order = number + 12})
    KeyMapper.SetUserKeyAction('select_all_t1_engineers', {action = 'UI_SelectByCategory LAND TECH1 ENGINEER', category = 'selection', order = number + 13})
    KeyMapper.SetUserKeyAction('select_all_battleships', {action = 'UI_SelectByCategory NAVAL BATTLESHIP', category = 'selection', order = number + 14})
    KeyMapper.SetUserKeyAction('Render_SelectionSet_Names', {action = 'ui_RenderSelectionSetNames', category = 'ui', order = number+ 15})
    KeyMapper.SetUserKeyAction('Render_Custom_Names', {action = 'ui_RenderCustomNames', category = 'ui', order = number + 16})
    KeyMapper.SetUserKeyAction('Render_Unit_Bars', {action = 'ui_RenderUnitBars', category = 'ui', order = number + 17})
    KeyMapper.SetUserKeyAction('Render_Icons', {action = 'ui_RenderIcons', category = 'ui', order = number + 18})
    KeyMapper.SetUserKeyAction('Always_Render_Strategic_Icons', {action = 'ui_AlwaysRenderStrategicIcons', category = 'ui', order = number + 19})
    KeyMapper.SetUserKeyAction('Kill_Selected_Units', {action = 'KillSelectedUnits', category = 'orders', order = number + 20})
    KeyMapper.SetUserKeyAction('Kill_All', {action = 'KillAll', category = 'orders', order = number + 21 })
    KeyMapper.SetUserKeyAction('Show_Bandwidth_Usage', {action = 'ren_ShowBandwidthUsage', category = 'ui', order = number + 22})
    KeyMapper.SetUserKeyAction('Execute_Paste_Buffer', {action = 'ExecutePasteBuffer', category = 'ui', order = number + 23})
-- end Ghaleon

end

function ToggleRepeatBuild()
    local selection = GetSelectedUnits()
    if selection then
        local allFactories = true
        local currentInfiniteQueueCheckStatus = false
        for i,v in selection do
            if v:IsRepeatQueue() then
                currentInfiniteQueueCheckStatus = true
            end
            if not v:IsInCategory('FACTORY') then
                allFactories = false
            end
        end
        if allFactories then
            for i,v in selection do
                if currentInfiniteQueueCheckStatus then
                    v:ProcessInfo('SetRepeatQueue', 'false')
                else
                    v:ProcessInfo('SetRepeatQueue', 'true')
                end
            end
        end
    end
end

--function to toggle things like shields etc
-- Unit toggle rules copied from orders.lua, used for converting to the numbers needed for the togglescriptbit function
unitToggleRules = {
    Shield =  0,
    Weapon = 1,
    Jamming = 2,
    Intel = 3,
    Production = 4,
    Stealth = 5,
    Generic = 6,
    Special = 7,
Cloak = 8,}

function toggleScript(name)
    local selection = GetSelectedUnits()
    local number = unitToggleRules[name]
    local currentBit = GetScriptBit(selection, number)
    ToggleScriptBit(selection, number, currentBit)
end

function toggleAllScript(name)
    local selection = GetSelectedUnits()
    for i = 0,8 do
        local currentBit = GetScriptBit(selection, i)
        ToggleScriptBit(selection, i, currentBit)
    end
end

local MilitaryFilters = {"Defense","AntiNavy","Miscellaneous","AntiAir","DirectFire","IndirectFire"}
local IntelFilters = {"CounterIntel", "Omni", "Radar", "Sonar"}

function toggleOverlay(type)
    local currentFilters = Prefs.GetFromCurrentProfile('activeFilters') or {}
    local tempFilters = {}
    local MilitaryActive = false
    local IntelActive = false
    for i, filter in MilitaryFilters do
        if currentFilters[string.lower(filter)] then
            MilitaryActive = true
        end
    end
    for i, filter in IntelFilters do
        if currentFilters[string.lower(filter)] then
            IntelActive = true
        end
    end

    local function toggleFilters(filterTable, active)
        for i, filter in filterTable do
            if active then
                currentFilters[string.lower(filter)] = nil
            else
                currentFilters[string.lower(filter)] = true
                table.insert(tempFilters, filter)
            end
        end
    end

    if type == 'Military' then
        toggleFilters(MilitaryFilters, MilitaryActive)
        if IntelActive then
            for i, filter in IntelFilters do
                table.insert(tempFilters, filter)
            end
        end
    end

    if type == 'Intel' then
        toggleFilters(IntelFilters, IntelActive)
        if MilitaryActive then
            for i, filter in MilitaryFilters do
                table.insert(tempFilters, filter)
            end
        end
    end

    Prefs.SetToCurrentProfile('activeFilters', currentFilters)
    import('/lua/ui/game/multifunction.lua').UpdateActiveFilters()
end

local currentLandFactoryIndex = 1
local currentAirFactoryIndex = 1
local currentNavalFactoryIndex = 1


function GetNextLandFactory()
    UISelectionByCategory("FACTORY * LAND", false, false, false, false)
    local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentLandFactoryIndex] or FactoryList[1]
        currentLandFactoryIndex = currentLandFactoryIndex + 1
        if currentLandFactoryIndex > table.getn(FactoryList) then
            currentLandFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNextAirFactory()
    UISelectionByCategory("FACTORY * AIR", false, false, false, false)
    local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentAirFactoryIndex] or FactoryList[1]
        currentAirFactoryIndex = currentAirFactoryIndex + 1
        if currentAirFactoryIndex > table.getn(FactoryList) then
            currentAirFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNextNavalFactory()
    UISelectionByCategory("FACTORY * NAVAL", false, false, false, false)
    local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentNavalFactoryIndex] or FactoryList[1]
        currentNavalFactoryIndex = currentNavalFactoryIndex + 1
        if currentNavalFactoryIndex > table.getn(FactoryList) then
            currentNavalFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNearestIdleLTMex()
    local tech = 1
    while (tech < 4) do
        ConExecute('UI_SelectByCategory +nearest +idle +inview MASSEXTRACTION TECH' .. tech)
        tech = tech + 1
        local tempList = GetSelectedUnits()
        if (tempList ~= nil) and (table.getn(tempList) > 0) then
            break
        end
    end
end

function toggleCloakJammingStealthScript()
    toggleScript("Cloak")
    toggleScript("Jamming")
    toggleScript("Stealth")
end

function toggleIntelShieldScript()
    toggleScript("Intel")
    toggleScript("Shield")
end

--this function might be too slow in larger games, needs testing
function GetSimilarUnits()
    local enhance = import('/lua/enhancementcommon.lua')
    local curSelection = GetSelectedUnits()
    if curSelection then
        --find out what enhancements the current unit has
        local curUnitId = curSelection[1]:GetEntityId()
        local curUnitEnhancements = enhance.GetEnhancements(curUnitId)

        --select all similar units by category
        local bp = curSelection[1]:GetBlueprint()
        local bpCats = bp.Categories
        local catString = ""
        for i, cat in bpCats do
            if i == 1 then
                catString = cat
            else
                catString = catString.." * " ..cat
            end
        end
        UISelectionByCategory(catString, false, false, false, false)

        --get enhancements on each unit and filter down to only those with the same as the first unit
        local newSelection = GetSelectedUnits()
        local tempSelectionTable = {}
        for i, unit in newSelection do
            local unitId = unit:GetEntityId()
            local unitEnhancements = enhance.GetEnhancements(unitId)
            if curUnitEnhancements and unitEnhancements then
                if table.equal(unitEnhancements, curUnitEnhancements) then
                    table.insert(tempSelectionTable, unit)
                end
            elseif curUnitEnhancements == nil and unitEnhancements == nil then
                table.insert(tempSelectionTable, unit)
            end
        end
        SelectUnits(tempSelectionTable)

    end
end

-- by norem
local lastACUSelectionTime = 0

function ACUSelectCG()
    local curTime = GetSystemTimeSeconds()
    local diffTime = curTime - lastACUSelectionTime
    if diffTime > 1.0 then
        ConExecute('UI_SelectByCategory +nearest COMMAND')
    else
        ConExecute('UI_SelectByCategory +nearest +goto COMMAND')
    end

    lastACUSelectionTime = curTime
end

function ACUAppendCG()
    local selection = GetSelectedUnits() or {}
    ACUSelectCG()
    AddSelectUnits(selection)
end

local GetDistanceBetweenTwoVectors = import('/lua/utilities.lua').GetDistanceBetweenTwoVectors

function GetNearestIdleEngineerNotACU()
    local idleEngineers = GetIdleEngineers()
    if not idleEngineers then
        return
    end

    local mousePos = GetMouseWorldPos()
    local nearestIndex = 1
    local nearestDist = GetDistanceBetweenTwoVectors(mousePos, idleEngineers[nearestIndex]:GetPosition())
    for index, unit in idleEngineers do
        local dist = GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
        if dist < nearestDist then
            nearestIndex = index
            nearestDist = dist
        end
    end

    SelectUnits({idleEngineers[nearestIndex]})
end

function AddNearestIdleEngineersSeq()
    local allIdleEngineers = GetIdleEngineers() or {}
    local currentSelection = GetSelectedUnits() or {}

    -- check if current selection contains only idle engineers
    local idleEngineers = allIdleEngineers
    for i, unit in currentSelection do
        local key = table.find(idleEngineers, unit)
        if key then
            table.remove(idleEngineers, key)
        else
            -- not an idle engineer, clear selection
            SelectUnits(nil)
            currentSelection = {}
            idleEngineers = allIdleEngineers
            break
        end
    end
    if table.empty(idleEngineers) then
        return
    end

    -- get nearest in list of unselected, idle
    local mousePos = GetMouseWorldPos()
    local nearestIndex = 1
    local nearestDist = GetDistanceBetweenTwoVectors(mousePos, idleEngineers[nearestIndex]:GetPosition())
    for index, unit in idleEngineers do
        local dist = GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition())
        if dist < nearestDist then
            nearestIndex = index
            nearestDist = dist
        end
    end

    -- compare nearest with already selected
    -- if it is closer than any of them, select it and deselect the others
    -- can be confusing in some situations
    --[[for i, unit in currentSelection do
    if GetDistanceBetweenTwoVectors(mousePos, unit:GetPosition()) > nearestDist then
        SelectUnits({idleEngineers[nearestIndex]})
        return
    end
end]]

AddSelectUnits({idleEngineers[nearestIndex]})
end

local categoryTable = {'LAND','AIR','NAVAL'}
local curFacIndex = 1

function CycleIdleFactories()
    local idleFactories = GetIdleFactories()
    if not idleFactories then
        return
    end

    local sortedFactories = {}
    for i, cat in categoryTable do
        sortedFactories[i] = {}
        sortedFactories[i][1] = EntityCategoryFilterDown(categories.TECH1 * categories[cat], idleFactories)
        sortedFactories[i][2] = EntityCategoryFilterDown(categories.TECH2 * categories[cat], idleFactories)
        sortedFactories[i][3] = EntityCategoryFilterDown(categories.TECH3 * categories[cat], idleFactories)
    end

    local factoriesList = {}
    local i = 3
    while i > 0 do
        for curCat = 1, 3 do
            if table.getn(sortedFactories[curCat][i]) > 0 then
                for _, unit in sortedFactories[curCat][i] do
                    table.insert(factoriesList, unit)
                end
            end
        end
        i = i - 1
    end

    local selection = GetSelectedUnits() or {}
    if table.equal(selection, {factoriesList[curFacIndex]}) then
        curFacIndex = curFacIndex + 1
        if not factoriesList[curFacIndex] then
            curFacIndex = 1
        end
    else
        curFacIndex = 1
    end

    SelectUnits({factoriesList[curFacIndex]})
end

local unitTypes = {
    categories.LAND * categories.MOBILE - categories.ENGINEER + categories.COMMAND,
    categories.NAVAL * categories.MOBILE,
    categories.AIR * categories.MOBILE,
}
local sortedUnits = {}
local unitCurType = nil

function CycleUnitTypesInSel()
    local selection = GetSelectedUnits()
    if not selection then
        return
    end

    local isNewSel = false
    if sortedUnits[unitCurType] then
        for i, unit in selection do
            if not table.find(sortedUnits[unitCurType], unit) then
                isNewSel = true
                break
            end
        end
    else
        isNewSel = true
    end

    if isNewSel then
        -- sort units
        sortedUnits = {}
        for i, cat in ipairs(unitTypes) do
            local units = EntityCategoryFilterDown(cat, selection)
            if not table.empty(units) then
                table.insert(sortedUnits, units)
            end
        end

        -- first type should be selected
        if not table.empty(sortedUnits) then
            unitCurType = 1
        else
            unitCurType = nil
            return
        end
    else
        -- next type should be selected
        unitCurType = unitCurType + 1
        if not sortedUnits[unitCurType] then
            unitCurType = 1
        end
    end

    SelectUnits(sortedUnits[unitCurType])
end

function CreateTemplateFactory()
    local currentCommandQueue = nil
    local selection = GetSelectedUnits()
    if selection and table.getn(selection) == 1 and selection[1]:IsInCategory('FACTORY') then
        currentCommandQueue = SetCurrentFactoryForQueueDisplay(selection[1])
    end
    import('/lua/gaz_ui/modules/templates_factory.lua').CreateBuildTemplate(currentCommandQueue)
end

-- end by norem