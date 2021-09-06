LOG("*AI DEBUG Loading Hotbuild")

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local CommandMode = import('/lua/ui/game/commandmode.lua')
local Effect = import('/lua/maui/effecthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local KeyMapper = import('/lua/keymap/keymapper.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Prefs = import('/lua/user/prefs.lua')
local Templates = import('/lua/ui/game/build_templates.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local pathMod = '/lua/hotbuild/'
local pathTex = pathMod .. 'textures/'

local LOUDINSERT = table.insert

local buildingTab

local upgradeTab = import(pathMod .. 'upgradeTab.lua').upgradeTab

local enabled = false

local cyclePos
local cycleMap
local cycleThread = false
local cycleLastName
local cycleLastMaxPos
local cycleButtons = {}

---- Non state changing getters

function getBuildingTab()

    --LOG("*AI DEBUG Hotbuild getBuildingTab")

    local btSource = import(pathMod .. 'buildingTab.lua').buildingTab
   
    local buildingTab = {}

    for name, values in btSource do
    
        buildingTab[name] = {}
        
        for i, value in values do
        
            if (nil ~= __blueprints[value]) then
            
                LOUDINSERT(buildingTab[name], value)
                
            elseif (nil ~= btSource[value]) then
            
                for i, realValue in btSource[value] do
                
                    if (nil ~= __blueprints[realValue]) then
                    
                        LOUDINSERT(buildingTab[name], realValue)
                        
                    else
                        LOG("!!!!! Invalid indirect building value " .. value .. " -> " .. realValue)
                    end
                end
                
            elseif (value == '_upgrade' or value == '_templates') then
            
                LOUDINSERT(buildingTab[name], value)
                
            else
            
                LOG("!!!!! Invalid building value " .. value)
                
            end
        end
    end
    
    return buildingTab
end

function getKeyDescriptions()

    --LOG("*AI DEBUG Hotbuild getKeyDescriptions")
    
    local kd = {}
    
    for name, values in getBuildingTab() do
    
        kd["build_" .. name] = "Build " .. name
        kd["build_" .. name .. "_shift"] = "Build(+shift) " .. name
        kd["build_" .. name .. "_alt"] = "Build(+alt) " .. name
        
    end
    
    return kd
end

function getKeyActions()

    --LOG("*AI DEBUG Hotbuild getKeyActions")
    
    local ka = {}
    local ukaOrder = 10000
    local ukaCategory = "hotbuild"
    
    local bt = getBuildingTab()
    
    --LOG("*AI DEBUG Hotbuild getKeyActions bt is "..repr(bt) ) 

    -- Hacky way to sort by name
    local btNames = {}
    local btNameIndices = {}
    
    for name, values in bt do
        LOUDINSERT(btNames, name)
    end
    
    table.sort(btNames)
  
    for i, name in btNames do
        btNameIndices[name] = i
    end
  
    for name, values in bt do
    
        local ukaName     = "build_" .. name
        local ukaModifier = ""
        local ukaAction   = "UI_Lua import('" .. pathMod .. "hotbuild.lua').buildAction('" .. name .. "','" .. ukaModifier .. "')"
        
        ukaOrder = btNameIndices[name] * 3 + 10000
        
        local ukaTable = {action = ukaAction, category = ukaCategory, order = ukaOrder}
        
        ka[ukaName] = ukaTable

        ukaName     = "build_" .. name .. "_shift"
        ukaModifier = "SHIFT"
        ukaAction   = "UI_Lua import('" .. pathMod .. "hotbuild.lua').buildAction('" .. name .. "','" .. ukaModifier .. "')"
        ukaOrder = btNameIndices[name] * 3 + 10001
        ukaTable = {action = ukaAction, category = ukaCategory, order = ukaOrder}
        
        ka[ukaName] = ukaTable
    
        ukaName     = "build_" .. name .. "_alt"
        ukaModifier = "ALT"
        ukaAction   = "UI_Lua import('" .. pathMod .. "hotbuild.lua').buildAction('" .. name .. "','" .. ukaModifier .. "')"
        ukaOrder = btNameIndices[name] * 3 + 10002
        ukaTable = {action = ukaAction, category = ukaCategory, order = ukaOrder}
        
        ka[ukaName] = ukaTable

    end
    
    return ka
end

---- End of Non state changing getters

function resetCycle(commandMode, modeData)

    --LOG("AI DEBUG Hotbuild resetCycle cmdmode: " .. repr(commandMode) .. " data: " .. repr(modeData))
    
    -- Commandmode = false is when a building is built (left click with mouse)
    -- modeData.isCancel = false is when building is aborted by a right click... whyever
    -- modeData.isCancel = true when "canceling" by releasing shift
    
    if ((commandMode == false) or (modeData.isCancel == false)) then
        cyclePos = 0
        -- Set to 0, first one is 1 but it will be incremented!
    end
end

---- Initialize functions
function init()

    -- Prevent this function from being called twice
    if (enabled) then return end

    LOG("*AI DEBUG Hotbuild INIT")

    enabled = true
    
    --import('/lua/lazyvar.lua').ExtendedErrorMessages = true

    buildingTab = getBuildingTab()
  
    initUserKeyActions()

    -- Prefer to do it manually with F1 -> reset
    -- initDefaultKeyMap()
  
    initCycleMap()
  
    CommandMode.AddEndBehavior(resetCycle)

    -- turns on the Build Item letters --
    -- which are incorrect at the moment --
    --import('/lua/ui/game/construction.lua').ShowBuildModeKeys(true)    

end

function initUserKeyActions()

    local ka = getKeyActions()
    
    --LOG("*AI DEBUG Hotbuild initUserKeyActions")
    
    for key, action in ka do
    
        --LOG("*AI DEBUG Hotbuild SetUserKeyAction "..repr(key).." "..repr(action))
    
        KeyMapper.SetUserKeyAction(key, action)
    end
    
end

function initDefaultKeyMap(suffix)

    local keyMapFile = pathMod .. "defaults/defaultKeyMap_" .. suffix .. ".lua"

    --LOG("*AI DEBUG Hotbuild initDefaultKeyMap from "..repr(keyMapFile))
    
    local defaultKeyMappings = import(keyMapFile).hotbuildDefaultKeyMap
    
    for pattern, action in defaultKeyMappings do
        KeyMapper.SetUserKeyMapping(pattern, false, action)
    end
    
    initUserKeyActions()
end

function initCycleButtons(values)

    --LOG("*AI DEBUG Hotbuild initCycleButtons")

    local buttonH = 48
    local buttonW = 48

    -- Delete old ones
    for _, button in cycleButtons do
        button:Destroy()
    end

    cycleButtons = {}
    local i = 1
    
    for i_whatever, value in values do
        cycleButtons[i] = Bitmap(cycleMap, UIUtil.SkinnableFile('/icons/units/' .. value .. '_icon.dds'))
        cycleButtons[i].Height:Set(buttonH)
        cycleButtons[i].Width:Set(buttonW)
        cycleButtons[i].Depth:Set(1002)
        LayoutHelpers.AtLeftTopIn(cycleButtons[i], cycleMap, 29 + buttonH * (i-1), 18)
        i=i+1
    end
  
    cycleMap.Height:Set(buttonH + 36)
    cycleMap.Width:Set((i-1) * buttonH + 58)
    cycleMap:DisableHitTest(true)
    
end

function initCycleMap()

    --LOG("*AI DEBUG Hotbuild initCycleMap")
    
    cycleMap = Group(GetFrame(0))

    cycleMap.Depth:Set(1000) --always on top
    cycleMap.Width:Set(400)
    cycleMap.Height:Set(150)

    cycleMap.Top:Set(function() return GetFrame(0).Bottom()*.75 end)
    cycleMap.Left:Set(function() return (GetFrame(0).Right()-cycleMap.Width())/2  end)
    cycleMap:DisableHitTest()
    cycleMap:Hide()

    cycle_Panel_tl = Bitmap(cycleMap)
    cycle_Panel_tl:SetTexture(pathTex .. 'cycle-panel-bg-tl.dds')
    cycle_Panel_tl.Top:Set(cycleMap.Top)
    cycle_Panel_tl.Left:Set(cycleMap.Left)
    cycle_Panel_tl.Width:Set(40)
  
    cycle_Panel_bl = Bitmap(cycleMap)
    cycle_Panel_bl:SetTexture(pathTex .. 'cycle-panel-bg-bl.dds')
    cycle_Panel_bl.Bottom:Set(cycleMap.Bottom)
    cycle_Panel_bl.Left:Set(cycleMap.Left)
    cycle_Panel_bl.Width:Set(40)
  	
    cycle_Panel_l = Bitmap(cycleMap)
    cycle_Panel_l:SetTexture(pathTex .. 'cycle-panel-bg-l.dds')
    cycle_Panel_l.Top:Set(cycle_Panel_tl.Bottom)
    cycle_Panel_l.Bottom:Set(cycle_Panel_bl.Top)
    cycle_Panel_l.Left:Set(cycleMap.Left)
    cycle_Panel_l.Width:Set(40)

    cycle_Panel_tr = Bitmap(cycleMap)
    cycle_Panel_tr:SetTexture(pathTex .. 'cycle-panel-bg-tr.dds')
    cycle_Panel_tr.Top:Set(cycleMap.Top)
    cycle_Panel_tr.Right:Set(cycleMap.Right)
    cycle_Panel_tr.Width:Set(40)
  
    cycle_Panel_br = Bitmap(cycleMap)
    cycle_Panel_br:SetTexture(pathTex .. 'cycle-panel-bg-br.dds')
    cycle_Panel_br.Bottom:Set(cycleMap.Bottom)
    cycle_Panel_br.Right:Set(cycleMap.Right)
    cycle_Panel_br.Width:Set(40)
  
    cycle_Panel_r = Bitmap(cycleMap)
    cycle_Panel_r:SetTexture(pathTex .. 'cycle-panel-bg-r.dds')
    cycle_Panel_r.Top:Set(cycle_Panel_tr.Bottom)
    cycle_Panel_r.Bottom:Set(cycle_Panel_br.Top)
    cycle_Panel_r.Right:Set(cycleMap.Right)
    cycle_Panel_r.Width:Set(40)
  
    cycle_Panel_t = Bitmap(cycleMap)
    cycle_Panel_t:SetTexture(pathTex .. 'cycle-panel-bg-t.dds')
    cycle_Panel_t.Top:Set(cycleMap.Top)
    cycle_Panel_t.Left:Set(cycle_Panel_l.Right)
    cycle_Panel_t.Right:Set(cycle_Panel_r.Left)
  
    cycle_Panel_b = Bitmap(cycleMap)
    cycle_Panel_b:SetTexture(pathTex .. 'cycle-panel-bg-b.dds')
    cycle_Panel_b.Bottom:Set(cycleMap.Bottom)
    cycle_Panel_b.Left:Set(cycle_Panel_l.Right)
    cycle_Panel_b.Right:Set(cycle_Panel_r.Left)
  
    cycle_Panel_m = Bitmap(cycleMap)
    cycle_Panel_m:SetTexture(pathTex .. 'cycle-panel-bg-m.dds')
    cycle_Panel_m.Top:Set(cycle_Panel_t.Bottom)
    cycle_Panel_m.Bottom:Set(cycle_Panel_b.Top)
    cycle_Panel_m.Left:Set(cycle_Panel_l.Right)
    cycle_Panel_m.Right:Set(cycle_Panel_r.Left)
    
end
---- End of Initialize functions

---- The actual key action callback
function buildAction(name, modifier)

    --LOG("---> buildAction " .. name .. " modifier: " .. modifier)
    
    local selection = GetSelectedUnits()
    
    if selection then
        --if current selection is engineer (includes commander)
        if table.getsize(EntityCategoryFilterDown(categories.ENGINEER, selection)) > 0 then 
            buildActionBuilding(name, modifier)
        else -- buildqueue or normal applying all the command
            buildActionUnit(name, modifier)
        end
    end
    
end

-- Some of the work here is redundant when cycle_preview is disabled
function buildActionBuilding(name, modifier)

    local options = Prefs.GetFromCurrentProfile('options')
    
    local allValues = buildingTab[name]
    local effectiveValues = {}

    if (table.find(allValues, "_templates")) then
        return buildActionTemplate(modifier)
    end
  
    -- Reset everything that could be fading or running  
    hideCycleMap()

    -- filter the values
    local selection=GetSelectedUnits()
    local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildable = EntityCategoryGetUnitList(buildableCategories)
    
    for i1, value in allValues do
    
        for i2, buildableValue in buildable do
            if value == buildableValue then
                LOUDINSERT(effectiveValues, value)
            end
        end
    end
  
    local maxPos = table.getsize(effectiveValues)
  
    if (maxPos == 0) then
        return
    end
  
    -- Check if the selection/key has changed
    if ((cycleLastName == name) and (cycleLastMaxPos == maxPos)) then
        cyclePos = cyclePos + 1
        
        if(cyclePos > maxPos) then
            cyclePos = 1
        end
    else
        initCycleButtons(effectiveValues)
        cyclePos = 1
        cycleLastName = name
        cycleLastMaxPos = maxPos
    end
  
    if (options.hotbuild_cycle_preview == 1) then
    
        -- Highlight the active button
        for i, button in cycleButtons do
            if (i == cyclePos) then
                button:SetAlpha(1, true)
            else
            button:SetAlpha(0.4, true)
        end
    end
  
    cycleMap:Show()
    
    -- Start the fading thread  
    cycleThread = ForkThread(function()
		stayTime = options.hotbuild_cycle_reset_time / 2000.0;
		fadeTime = options.hotbuild_cycle_reset_time / 2000.0;
		
        WaitSeconds(stayTime)
        
        if (not cycleMap:IsHidden()) then
            Effect.FadeOut(cycleMap, fadeTime, 0.6, 0.1)
        end
        
        WaitSeconds(fadeTime)
        cyclePos = 0
        end)
    else
        cycleThread = ForkThread(function()
            WaitSeconds(options.hotbuild_cycle_reset_time / 1000.0);
            cyclePos = 0
        end)
    end
    
    local cmd = effectiveValues[cyclePos]
    
    -- LOG("StartCommandMode:" .. cmd)
    
    ClearBuildTemplates()
    CommandMode.StartCommandMode("build", {name = cmd})
end


-- Some of the work here is redundant when cycle_preview is disabled
function buildActionTemplate(modifier)

    local options = Prefs.GetFromCurrentProfile('options')
  
    -- Reset everything that could be fading or running  
    hideCycleMap()

    -- find all avaiable templates
    local effectiveTemplates = {}
    local effectiveIcons = {}
    local allTemplates = Templates.GetTemplates()

    if (not allTemplates) or table.empty(allTemplates) then
        return
    end
  
    local selection = GetSelectedUnits()
    local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
  
    --Allow all races to build other races templates
    local currentFaction = selection[1]:GetBlueprint().General.FactionName
  
    if options.gui_all_race_templates != 0 and currentFaction then

        local function ConvertID(BPID)
    
            local prefixes = {
                ["AEON"]     = {"uab", "xab", "dab",},
                ["UEF"]      = {"ueb", "xeb", "deb",},
                ["CYBRAN"]   = {"urb", "xrb", "drb",},
                ["SERAPHIM"] = {"xsb", "usb", "dsb",},
            }
      
            for i, prefix in prefixes[string.upper(currentFaction)] do
      
                if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
                    return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
                end
        
            end
      
            return false
      
        end
    
    for templateIndex, template in allTemplates do
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
        table.insert(effectiveTemplates, template)
		table.insert(effectiveIcons, template.icon)
      end
    end
  else
    for templateIndex, template in allTemplates do
      local valid = true
      for _, entry in template.templateData do
        if type(entry) == 'table' then
          if not table.find(buildableUnits, entry[1]) then
            valid = false
            break
          end
        end
      end
      if valid then
        template.templateID = templateIndex
        table.insert(effectiveTemplates, template)
		table.insert(effectiveIcons, template.icon)
      end
    end
  end
  
  local maxPos = table.getsize(effectiveTemplates)
  if (maxPos == 0) then
    return
  end
  
  -- Check if the selection/key has changed
  if ((cycleLastName == '_templates') and (cycleLastMaxPos == maxPos)) then
    cyclePos = cyclePos + 1
    if(cyclePos > maxPos) then
      cyclePos = 1
    end
  else
    initCycleButtons(effectiveIcons)
    cyclePos = 1
    cycleLastName = '_templates'
    cycleLastMaxPos = maxPos
  end
  
  
  if (options.hotbuild_cycle_preview == 1) then
    -- Highlight the active button
    for i, button in cycleButtons do
      if (i == cyclePos) then
        button:SetAlpha(1, true)
      else
        button:SetAlpha(0.4, true)
      end
    end
  
    cycleMap:Show()
    -- Start the fading thread  
    cycleThread = ForkThread(function()
		stayTime = options.hotbuild_cycle_reset_time / 2000.0;
		fadeTime = options.hotbuild_cycle_reset_time / 2000.0;
		
        WaitSeconds(stayTime)
        if (not cycleMap:IsHidden()) then
          Effect.FadeOut(cycleMap, fadeTime, 0.6, 0.1)
        end
        WaitSeconds(fadeTime)
        cyclePos = 0
      end)
  else
      cycleThread = ForkThread(function()
		WaitSeconds(options.hotbuild_cycle_reset_time / 1000.0);
        cyclePos = 0
      end)
  end
    
  local template = effectiveTemplates[cyclePos]
  local cmd = template.templateData[3][1]

  -- LOG("BAT cmd: " .. cmd .. " tplD: " .. repr(template.templateData))

  ClearBuildTemplates()
  CommandMode.StartCommandMode("build", {name = cmd})
  SetActiveBuildTemplate(template.templateData)

end


function hideCycleMap()
  if (cycleThread) then
    KillThread(cycleThread)
  end

  cycleMap:SetNeedsFrameUpdate(false)
  cycleMap.OnFrame = function(self, elapsedTime)
                     end 
  cycleMap:Hide();
  cycleMap:SetAlpha(1, true)
end

function buildActionUnit(name, modifier)
  local values = buildingTab[name]
  
  -- Try to delete old units except for the one currently in construction
  if (modifier == 'ALT') then
    local currentCommandQueue = import('/lua/ui/game/construction.lua').getCurrentCommandQueue()
    if (currentCommandQueue) then
      for index = table.getn(currentCommandQueue), 1, -1  do
        local count = currentCommandQueue[index].count
        if (index == 1) then
          count = count - 1
        end
        DecreaseBuildCountInQueue(index, count)
      end
    end
  end
  
  for i, v in values do
    if (v == '_upgrade') then
      return buildActionUpgrade()
    end
  end
  local count = 1
  if (modifier == 'SHIFT') then
    count = 5
  end
  
  local selectedUnits = GetSelectedUnits()
  local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selectedUnits)
  local buildable = EntityCategoryGetUnitList(buildableCategories)

  for i, v in values do
    for ii, ba in buildable do
      if (v == ba) then
        IssueBlueprintCommand("UNITCOMMAND_BuildFactory", v, count)
      end
    end
  end
end


-- Does not upgrade T1 facs that are currently upgrading to T2 to T3 when issued
function buildActionUpgrade()
  local selectedUnits = GetSelectedUnits()
  local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selectedUnits)
--  local buildable = EntityCategoryGetUnitList(buildableCategories)
  local bpTypes = {}

  for index, unit in selectedUnits do
    local bpId = unit:GetBlueprint().BlueprintId
    -- LOG("bpid: " .. bpId)
    local cmd = upgradeTab[bpId]
    if (cmd) then
      SelectUnits({unit})
      -- LOG("upgrading: " .. repr(unit) .. " with cmd: " .. cmd)
      IssueBlueprintCommand("UNITCOMMAND_Upgrade", cmd, 1, false)
    end
  end
  SelectUnits(selectedUnits)
end