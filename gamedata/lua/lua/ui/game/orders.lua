-- File: lua/modules/ui/game/orders.lua
-- Author: Chris Blackwell
-- Summary: Unit orders UI

local Bitmap        = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox      = import('/lua/maui/checkbox.lua').Checkbox
local CommandMode   = import("/lua/ui/game/commandmode.lua")
local Construction  = import("/lua/ui/game/construction.lua")
local GameCommon    = import('/lua/ui/game/gamecommon.lua')
local Grid          = import('/lua/maui/grid.lua').Grid
local Keymapping    = import('/lua/keymap/defaultKeyMap.lua').defaultKeyMap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Prefs         = import('/lua/user/prefs.lua')
local Tooltip       = import('/lua/ui/game/tooltip.lua')
local TooltipInfo   = import('/lua/ui/help/tooltips.lua')
local UIMain        = import('/lua/ui/uimain.lua')
local UIUtil        = import('/lua/ui/uiutil.lua')

controls = {
    mouseoverDisplay = false,
    orderButtonGrid = false,
    bg = false,
    orderGlow = false,
    controlClusterGroup = false,
    mfdControl = false,
}

-- this sets up the basic grid
function ResetGrid()

    OrderNum = 0

    Grid_Params = {
        Grid = { 
            numSlots = 16,
            firstAltSlot = 4,
            vertRows = 8,
            horzRows = 2,

            ---------------------
            --colums & rows
            vertCols = 2,
            horzCols = 8,

            ---------------------
            --icon size
            iconsize = { 
                height = 43,
                width = 40,
            },

            ---------------------
            --panel size
            panelsize = { 
                width = 346,
                height = 120,
            },
        },

        Order_Slots = {
            numSlots = 16,
            firstAltSlot = 4,
            vertRows = 8,
            horzRows = 2,

            ---------------------
            --colums & rows
            vertCols = 2,
            horzCols = 8,

            ---------------------
            --icon size
            iconsize = { 
                height = 43,
                width = 40,
            },

            ---------------------
            --panel size
            panelsize = { 
                width = 346,
                height = 120,
            },
        }
    }
end

ResetGrid()     -- this sets up the default grid and order slots

-- positioning controls, don't belong to file
local layoutVar = false
local glowThread = false

-- these variables control the number of slots available for orders
-- from DMS -- 
local numSlots = Grid_Params.Grid.numSlots
local firstAltSlot = Grid_Params.Grid.firstAltSlot
local vertRows = Grid_Params.Grid.vertRows
local horzRows = Grid_Params.Grid.horzRows

local vertCols = Grid_Params.Grid.vertCols
local horzCols = Grid_Params.Grid.horzCols

local function CreateOrderGlow(parent)
    controls.orderGlow = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.orderGlow, parent)
    controls.orderGlow:SetAlpha(0.0)
    controls.orderGlow:DisableHitTest()
    controls.orderGlow:SetNeedsFrameUpdate(true)
    local alpha = 0.0
    local incriment = true
    controls.orderGlow.OnFrame = function(self, deltaTime)
        if incriment then
            alpha = alpha + (deltaTime * 0.5)
        else
            alpha = alpha - (deltaTime * 0.5)
        end
        if alpha < 0 then
            alpha = 0.0
            incriment = true
        end
        if alpha > .0600 then
            alpha = .0600
            incriment = false
        end
        controls.orderGlow:SetAlpha(alpha)
    end
end

-- hotkey labels on orders
local hotkeyLabel_addLabel = import('/lua/keymap/hotkeylabelsUI.lua').addLabel
local orderKeys = {}

function setOrderKeys(orderKeys_)
    orderKeys = orderKeys_
end

local function CreateAutoBuildEffect(parent)
    local glow = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(glow, parent)
    glow:SetAlpha(0.0)
    glow:DisableHitTest()
    glow:SetNeedsFrameUpdate(true)
    glow.alpha = 0.0
    glow.incriment = true
    glow.OnFrame = function(self, deltaTime)
        if self.incriment then
            self.alpha = self.alpha + (deltaTime * .35)
        else
            self.alpha = self.alpha - (deltaTime * .35)
        end
        if self.alpha < 0 then
            self.alpha = 0.0
            self.incriment = true
        end
        if self.alpha > .4 then
            self.alpha = .4
            self.incriment = false
        end
        self:SetAlpha(self.alpha)
    end
    return glow
end

function CreateMouseoverDisplay(parent, ID)
    if controls.mouseoverDisplay then
        controls.mouseoverDisplay:Destroy()
        controls.mouseoverDisplay = false
    end

    if not Prefs.GetOption('tooltips') then return end

    local createDelay = Prefs.GetOption('tooltip_delay') or 0
    local text = TooltipInfo['Tooltips'][ID]['title'] or ID
    local desc = TooltipInfo['Tooltips'][ID]['description'] or ID

    if TooltipInfo['Tooltips'][ID]['keyID'] and TooltipInfo['Tooltips'][ID]['keyID'] != "" then
        for i, v in Keymapping do
            if v == TooltipInfo['Tooltips'][ID]['keyID'] then
                local properkeyname = import('/lua/ui/dialogs/keybindings.lua').FormatKeyName(i)
                text = LOCF("%s (%s)", text, properkeyname)
                break
            end
        end
    end

    if not text or not desc then
        return
    end

    controls.mouseoverDisplay = Tooltip.CreateExtendedToolTip(parent, text, desc)
    local Frame = GetFrame(0)
    controls.mouseoverDisplay.Bottom:Set(parent.Top)

    if (parent.Left() + (parent.Width() / 2)) - (controls.mouseoverDisplay.Width() / 2) < 0 then
        controls.mouseoverDisplay.Left:Set(4)
    elseif (parent.Right() - (parent.Width() / 2)) + (controls.mouseoverDisplay.Width() / 2) > Frame.Right() then
        controls.mouseoverDisplay.Right:Set(function() return Frame.Right() - 4 end)
    else
        LayoutHelpers.AtHorizontalCenterIn(controls.mouseoverDisplay, parent)
    end

    local alpha = 0.0
    controls.mouseoverDisplay:SetAlpha(alpha, true)
    local mdThread = ForkThread(function()
        WaitSeconds(createDelay)
        while alpha <= 1.0 do
            controls.mouseoverDisplay:SetAlpha(alpha, true)
            alpha = alpha + 0.1
            WaitSeconds(0.01)
        end
    end)

    controls.mouseoverDisplay.OnDestroy = function(self)
        KillThread(mdThread)  
    end
end

local function CreateOrderButtonGrid()
    controls.orderButtonGrid = Grid(controls.bg, Grid_Params.Grid.iconsize.width, Grid_Params.Grid.iconsize.height)
    controls.orderButtonGrid:SetName("Orders Grid")
    controls.orderButtonGrid:DeleteAll()
end

-- local logic data
local orderCheckboxMap = false
local currentSelection = false

-- helper function to create order bitmaps
-- note, your bitmaps must be in /game/orders/ and have the standard button naming convention
local function GetOrderBitmapNames(bitmapId)

    if bitmapId == nil then
        LOG("Error - nil bitmap passed to GetOrderBitmapNames")
        bitmapId = "basic-empty"    -- TODO do I really want to default it?
    end

    local button_prefix = "/game/orders/" .. bitmapId .. "_btn_"
    return UIUtil.SkinnableFile(button_prefix .. "up.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "up_sel.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "over.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "over_sel.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "dis.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "dis_sel.dds")
        , "UI_Action_MouseDown", "UI_Action_Rollover"   -- sets click and rollover cues
end

-- used by most orders, which start and stop a command mode, so they toggle on when pressed
-- and toggle off when done
local function StandardOrderBehavior(self, modifiers)
    -- if we're checked, end the current command mode, otherwise start it
    if self:IsChecked() then
        CommandMode.EndCommandMode(true)
    else
        CommandMode.StartCommandMode("order", {name=self._order})
    end
end

--TODO: set up these functions so they are abstracted for all orders, so you can check them for anything like OC, diving, production, whatever.
--returns 0 for no units found, 1 for only snipes on, 2 for only snipes off, 3 for mixed.
local function IsToggleMode(unitList, variable, value)

    local toggleStateTrue
    local toggleStateFalse
    -- we search the unit list for the either condition to determine the icon state.

    for k, unit in unitList do
        local toggleState = UnitData[unit:GetEntityId()][variable] == value
        if toggleState == true then
            toggleStateTrue = 1
        elseif toggleState == false then
            toggleStateFalse = 2
        end
        -- if we find out we have mixed states we dont need to continue, so we bail
        if toggleStateTrue and toggleStateFalse then
            break
        end
    end
    return ((toggleStateTrue or 0) + (toggleStateFalse or 0))
end

-- we store all the things we want to run when we toggle the toggle in here, in one neat table :>
local OrderTogglesTable = {
    Attack = {
        ToggleFromOn = function() SetWeaponPriorities(0, 'Default') end,
        ToggleFromOff = function() SetWeaponPriorities("{categories.COMMAND, categories.STRATEGIC, categories.ANTIMISSILE * categories.TECH3, categories.MASSEXTRACTION * categories.STRUCTURE * categories.TECH3, categories.MASSEXTRACTION * categories.STRUCTURE * categories.TECH2, categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH3, categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH2, categories.MASSFABRICATION * categories.STRUCTURE, categories.SHIELD,}",
                                    'Snipe', false) end,
    },
}
-- we can add duplicate fields in like this:
OrderTogglesTable.Attack.ToggleFromBoth = OrderTogglesTable.Attack.ToggleFromOff

-- toggle mode: 1 - true; 2 - false; 3 - both; 0 - error
-- call the functions from the OrderTogglesTable
local function ToggleOrder(control, ordertype)
    if control._toggleMode == 1 then
        OrderTogglesTable[ordertype].ToggleFromOn()
        control._toggleMode = 2
    elseif control._toggleMode == 2 then
        OrderTogglesTable[ordertype].ToggleFromOff()
        control._toggleMode = 1
    elseif control._toggleMode == 3 then
        OrderTogglesTable[ordertype].ToggleFromBoth()
        control._toggleMode = 1
    end
end

-- toggle mode: 1 - true; 2 - false; 3 - both; 0 - error
local function UpdateToggleIcon(control)
    if control._toggleMode == 1 then
        control.toggleModeIcon:SetAlpha(1)
        control.mixedModeIcon:SetAlpha(0)
    elseif control._toggleMode == 2 then
        control.toggleModeIcon:SetAlpha(0)
        control.mixedModeIcon:SetAlpha(0)
    elseif control._toggleMode == 3 then
        control.toggleModeIcon:SetAlpha(0)
        control.mixedModeIcon:SetAlpha(1)
    else
        WARN('found a toggle value of 0 which shouldnt ever happen, showing as mixed')
        control.toggleModeIcon:SetAlpha(0)
        control.mixedModeIcon:SetAlpha(1)
    end
end

--------------------------------
--Weapon priority switching
--------------------------------

local function AttackOrderInit(control, unitList)
    if not unitList[1] then
        return true
    end

    --set up the icons that will be toggled on/off
    if not control.toggleModeIcon then
        control.toggleModeIcon = Bitmap(control, UIUtil.UIFile('/game/orders/toggle_red.dds'))
        LayoutHelpers.AtCenterIn(control.toggleModeIcon, control)
        control.toggleModeIcon:DisableHitTest()
        control.toggleModeIcon:SetAlpha(0)
        control.toggleModeIcon.OnHide = function(self, hidden)
            if not hidden and control:IsDisabled() then
                return true
            end
        end
    end

    if not control.mixedModeIcon then
        control.mixedModeIcon = Bitmap(control.toggleModeIcon, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        LayoutHelpers.AtRightTopIn(control.mixedModeIcon, control)
        control.mixedModeIcon:DisableHitTest()
        control.mixedModeIcon:SetAlpha(0)
        control.mixedModeIcon.OnHide = function(self, hidden)
            if not hidden and control:IsDisabled() then
                return true
            end
        end
    end

    control._curHelpText = control._data.helpText
    control._toggleMode = IsToggleMode(unitList, 'WepPriority', 'Snipe')
    UpdateToggleIcon(control)
end

-- Allow the right button on the attack order to change target priorities, while the left button stays as before.
-- would be cool to implement overloading like this onto other orders too for epic things.
local function AttackOrderBehavior(self, modifiers)
    if modifiers.Left then
        StandardOrderBehavior(self, modifiers)
    elseif modifiers.Right then
        ToggleOrder(self,'Attack')
        UpdateToggleIcon(self)
    end
end

-- used by orders that happen immediately and don't change the command mode (ie the stop button)
local function DockOrderBehavior(self, modifiers)
    if modifiers.Shift then
        IssueDockCommand(false)
    else
        IssueDockCommand(true)
    end
    self:SetCheck(false)
end

-- used by orders that happen immediately and don't change the command mode (ie the stop button)
local function MomentaryOrderBehavior(self, modifiers)
    IssueCommand(GetUnitCommandFromCommandCap(self._order))
    self:SetCheck(false)
end


-- used by things that build weapons, etc
local function BuildOrderBehavior(self, modifiers)
    if modifiers.Left then
        IssueCommand(GetUnitCommandFromCommandCap(self._order))
    elseif modifiers.Right then
        self:ToggleCheck()
        if self:IsChecked() then
            self._curHelpText = self._data.helpText .. "_auto"
            self.autoBuildEffect = CreateAutoBuildEffect(self)
        else
            self._curHelpText = self._data.helpText
            self.autoBuildEffect:Destroy()
        end
        if controls.mouseoverDisplay.text then
            controls.mouseoverDisplay.text:SetText(self._curHelpText)
        end
        SetAutoMode(currentSelection, self:IsChecked())
    end
end

local function BuildInitFunction(control, unitList)
    local isAutoMode = GetIsAutoMode(unitList)
    control:SetCheck(isAutoMode)
    if isAutoMode then
        control._curHelpText = control._data.helpText .. "_auto"
        control.autoBuildEffect = CreateAutoBuildEffect(control)
    else
        control._curHelpText = control._data.helpText
    end
end

-- used by subs that can dive/surface
local function DiveOrderBehavior(self, modifiers)
    if modifiers.Left then
        IssueCommand(GetUnitCommandFromCommandCap(self._order))
        self:ToggleCheck()
    elseif modifiers.Right then
        if self._isAutoMode then
            self._curHelpText = self._data.helpText
            if self.autoBuildEffect then
                self.autoBuildEffect:Destroy()
            end
            self.autoModeIcon:SetAlpha(0)
            self._isAutoMode = false
        else
            self._curHelpText = self._data.helpText .. "_auto"
            if not self.autoBuildEffect then
                self.autoBuildEffect = CreateAutoBuildEffect(self)
            end
            self.autoModeIcon:SetAlpha(1)
            self._isAutoMode = true
        end
        if controls.mouseoverDisplay.text then
            controls.mouseoverDisplay.text:SetText(self._curHelpText)
        end
        SetAutoSurfaceMode(currentSelection, self._isAutoMode)
    end
end

local function DiveInitFunction(control, unitList)
    if not control.autoModeIcon then
        control.autoModeIcon = Bitmap(control, UIUtil.UIFile('/game/orders/autocast_bmp.dds'))
        LayoutHelpers.AtCenterIn(control.autoModeIcon, control)
        control.autoModeIcon:DisableHitTest()
        control.autoModeIcon:SetAlpha(0)
        control.autoModeIcon.OnHide = function(self, hidden)
            if not hidden and control:IsDisabled() then
                return true
            end
        end
    end

    if not control.mixedModeIcon then
        control.mixedModeIcon = Bitmap(control.autoModeIcon, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        LayoutHelpers.AtRightTopIn(control.mixedModeIcon, control)
        control.mixedModeIcon:DisableHitTest()
        control.mixedModeIcon:SetAlpha(0)
        control.mixedModeIcon.OnHide = function(self, hidden)
            if not hidden and control:IsDisabled() then
                return true
            end
        end
    end

    control._isAutoMode = GetIsAutoSurfaceMode(unitList)

    if control._isAutoMode then
        control._curHelpText = control._data.helpText .. "_auto"
        control.autoBuildEffect = CreateAutoBuildEffect(control)
        control.autoModeIcon:SetAlpha(1)
    else
        control._curHelpText = control._data.helpText
    end

    local submergedState = GetIsSubmerged(unitList)

    if submergedState == -1 then
        control:SetCheck(true)
    elseif submergedState == 1 then
        control:SetCheck(false)
    else
        control:SetCheck(false)
        control.mixedModeIcon:SetAlpha(1)
    end
end

function ToggleDiveOrder()
    local diveCB = orderCheckboxMap["RULEUCC_Dive"]
    if diveCB then
        DiveOrderBehavior(diveCB, {Left = true})
    end
end

-- pause button specific behvior
-- TODO pause button will be moved to construction manager
local function PauseOrderBehavior(self, modifiers)
    Checkbox.OnClick(self)
    SetPaused(currentSelection, self:IsChecked())
end

local function PauseInitFunction(control, unitList)
    control:SetCheck(GetIsPaused(unitList))
end

function TogglePauseState()
    local pauseState = GetIsPaused(currentSelection)
    SetPaused(currentSelection, not pauseState)
end

-- some toggleable abilities need reverse semantics.
local function CheckReverseSemantics(scriptBit)
    if scriptBit == 0 then -- shields
        return true
    end

    return false
end

local function AttackMoveBehavior(self, modifiers)
    if self:IsChecked() then
        CommandMode.EndCommandMode(true)
    else
        local modeData = { name = "RULEUCC_Script", AbilityName = 'AttackMove', TaskName = 'AttackMove', cursor = 'ATTACK_MOVE' }
        CommandMode.StartCommandMode("order", modeData)
    end
end

local function AbilityButtonBehavior(self, modifiers)
    if self:IsChecked() then
        CommandMode.EndCommandMode(true)
    else
        local modeData = { name = "RULEUCC_Script", AbilityName = self._script, TaskName = self._script }
        CommandMode.StartCommandMode("order", modeData)
    end
end

-- generic script button specific behvior
local function ScriptButtonOrderBehavior(self, modifiers)
    local state = self:IsChecked()
    if self._mixedIcon then
        self._mixedIcon:Destroy()
        self._mixedIcon = nil
    end

    ToggleScriptBit(currentSelection, self._data.extraInfo, state)

    if controls.mouseoverDisplay.text then
        controls.mouseoverDisplay.text:SetText(self._curHelpText)
    end

    Checkbox.OnClick(self)
end

local function ScriptButtonInitFunction(control, unitList)
    local result = nil
    local mixed = false
    for i, v in unitList do
        local thisUnitStatus = GetScriptBit({v}, control._data.extraInfo)
        if result == nil then
            result = thisUnitStatus
        else
            if thisUnitStatus != result then
                mixed = true
                result = true
                break
            end
        end
    end

    if mixed then
        control._mixedIcon = Bitmap(control, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        LayoutHelpers.AtRightTopIn(control._mixedIcon, control, -2, 2)
    end
    control:SetCheck(result)    -- selected state
end

local function DroneBehavior(self, modifiers)
    if modifiers.Left then
        SelectUnits( { self._unit } )
    end

    if modifiers.Right then
        if self:IsChecked() then
            self._pod:ProcessInfo('SetAutoMode', 'false')
            self:SetCheck(false)
        else
            self._pod:ProcessInfo('SetAutoMode', 'true')
            self:SetCheck(true)
        end
    end
end

local function DroneInit(self, selection)
    self:SetCheck(self._pod:IsAutoMode())
end

-- retaliate button specific behvior
local retaliateStateInfo = {
    [-1] = {bitmap = 'stand-ground',    helpText = "mode_mixed"},
    [0] = { bitmap = 'return-fire',     helpText = "mode_return_fire",   id = 'ReturnFire'},
    [1] = { bitmap = 'hold-fire',       helpText = "mode_hold_fire",     id = 'HoldFire'},
    [2] = { bitmap = 'stand-ground',    helpText = "mode_hold_ground",   id = 'HoldGround'},
}

local function CreateBorder(parent)
    local border = {}

    border.tl = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_ul.dds'))
    border.tm = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_horz_um.dds'))
    border.tr = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_ur.dds'))
    border.ml = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_vert_l.dds'))
    border.mr = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_vert_r.dds'))
    border.bl = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_ll.dds'))
    border.bm = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_lm.dds'))
    border.br = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_lr.dds'))

    border.tl.Bottom:Set(parent.Top)
    border.tl.Right:Set(parent.Left)

    border.bl.Top:Set(parent.Bottom)
    border.bl.Right:Set(parent.Left)

    border.tr.Bottom:Set(parent.Top)
    border.tr.Left:Set(parent.Right)

    border.br.Top:Set(parent.Bottom)
    border.br.Left:Set(parent.Right)

    border.tm.Bottom:Set(parent.Top)
    border.tm.Left:Set(parent.Left)
    border.tm.Right:Set(parent.Right)

    border.bm.Top:Set(parent.Bottom)
    border.bm.Left:Set(parent.Left)
    border.bm.Right:Set(parent.Right)

    border.ml.Top:Set(parent.Top)
    border.ml.Bottom:Set(parent.Bottom)
    border.ml.Right:Set(parent.Left)

    border.mr.Top:Set(parent.Top)
    border.mr.Bottom:Set(parent.Bottom)
    border.mr.Left:Set(parent.Right)

    return border
end

local function CreateFirestatePopup(parent, selected)
    local bg = Bitmap(parent, UIUtil.UIFile('/game/ability_brd/chat_brd_m.dds'))

    bg.border = CreateBorder(bg)
    bg:DisableHitTest(true)

    local function CreateButton(index, info)
        local btn = Checkbox(bg, GetOrderBitmapNames(info.bitmap))
        btn.info = info
        btn.index = index
        btn.HandleEvent = function(control, event)
            if event.Type == 'MouseEnter' then
                CreateMouseoverDisplay(control, control.info.helpText, 1)
            elseif event.Type == 'MouseExit' then
                if controls.mouseoverDisplay then
                    controls.mouseoverDisplay:Destroy()
                    controls.mouseoverDisplay = false
                end
            end
            return Checkbox.HandleEvent(control, event)
        end
        btn.OnCheck = function(control, checked)
            parent:_OnFirestateSelection(control.index, control.info.id)
        end
        return btn
    end

    local i = 1
    bg.buttons = {}
    for index, state in retaliateStateInfo do
        if index != -1 then
            bg.buttons[i] = CreateButton(index, state)
            if i == 1 then
                LayoutHelpers.AtBottomIn(bg.buttons[i], bg)
                LayoutHelpers.AtLeftIn(bg.buttons[i], bg)
            else
                LayoutHelpers.Above(bg.buttons[i], bg.buttons[i-1])
            end
            i = i + 1
        end
    end

    bg.Height:Set(function() return table.getsize(bg.buttons) * bg.buttons[1].Height() end)
    bg.Width:Set(bg.buttons[1].Width)

    if UIUtil.currentLayout == 'left' then
        LayoutHelpers.RightOf(bg, parent, 40)
    else
        LayoutHelpers.Above(bg, parent, 20)
    end

    -- all credit to Domino Mod Support
    -- resize the popup icons
    for _, btn in bg.buttons do
        LayoutHelpers.SetDimensions(btn, Grid_Params.Order_Slots.iconsize.width, Grid_Params.Order_Slots.iconsize.height)
    end

    return bg
end

local function RetaliateOrderBehavior(self, modifiers)
    if not self._OnFirestateSelection then
        self._OnFirestateSelection = function(self, newState, id)
            self._toggleState = newState
            SetFireState(currentSelection, id)
            self:SetNewTextures(GetOrderBitmapNames(retaliateStateInfo[newState].bitmap))
            self._curHelpText = retaliateStateInfo[newState].helpText
            self._popup:Destroy()
            self._popup = nil
        end
    end
    if self._popup then
        self._popup:Destroy()
        self._popup = nil
    else
        self._popup = CreateFirestatePopup(self, self._toggleState)
        local function CollapsePopup(event)
            if (event.y < self._popup.Top() or event.y > self._popup.Bottom()) or (event.x < self._popup.Left() or event.x > self._popup.Right()) then
                self._popup:Destroy()
                self._popup = nil
            end
        end

        UIMain.AddOnMouseClickedFunc(CollapsePopup)

        self._popup.OnDestroy = function(self)
            UIMain.RemoveOnMouseClickedFunc(CollapsePopup)
            Checkbox.OnDestroy(self)
        end
    end
end

local function RetaliateInitFunction(control, unitList)
    control._toggleState = GetFireState(unitList)
    if not retaliateStateInfo[control._toggleState] then
        LOG("Error: orders.lua - invalid toggle state: ", tostring(self._toggleState))
    end
    control:SetNewTextures(GetOrderBitmapNames(retaliateStateInfo[control._toggleState].bitmap))
    control._curHelpText = retaliateStateInfo[control._toggleState].helpText
    if control._toggleState == -1 then
        if not control.mixedIcon then
            control.mixedIcon = Bitmap(control, UIUtil.UIFile('/game/orders-panel/question-mark_bmp.dds'))
        end
        LayoutHelpers.AtRightTopIn(control.mixedIcon, control, 3, 6)
        control.mixedIcon:DisableHitTest()
        control.mixedIcon:SetAlpha(0)
        control.mixedIcon.OnHide = function(self, hidden)
            if not hidden and control:IsDisabled() then
                return true
            end
        end
    end
    control.OnEnable = function(self)
        if self.mixedIcon then
            self.mixedIcon:SetAlpha(1)
        end
        Checkbox.OnEnable(self)
    end
    control.OnDisable = function(self)
        if self.mixedIcon then
            self.mixedIcon:SetAlpha(0)
        end
        Checkbox.OnDisable(self)
    end
end

function CycleRetaliateStateUp()
    local currentFireState = GetFireState(currentSelection)
    if currentFireState > 3 then
        currentFireState = 0
    end
    ToggleFireState(currentSelection, currentFireState)
end

local function pauseFunc()
    Construction.EnablePauseToggle()
end

local function disPauseFunc()
    Construction.DisablePauseToggle()
end

local function NukeBtnText(button)
    if not currentSelection[1] or currentSelection[1]:IsDead() then return '' end
    if table.getsize(currentSelection) > 1 then
        button.buttonText:SetColor('fffff600')
        return '?'
    else
        local info = currentSelection[1]:GetMissileInfo()
        if info.nukeSiloStorageCount == 0 then
            button.buttonText:SetColor('ffff7f00')
        else
            button.buttonText:SetColor('ffffffff')
        end
        return string.format('%d/%d', info.nukeSiloStorageCount, info.nukeSiloMaxStorageCount)
    end
end

local function TacticalBtnText(button)
    if not currentSelection[1] or currentSelection[1]:IsDead() then return '' end
    if table.getsize(currentSelection) > 1 then
        button.buttonText:SetColor('fffff600')
        return '?'
    else
        local info = currentSelection[1]:GetMissileInfo()
        if info.nukeSiloStorageCount == 0 then
            button.buttonText:SetColor('ffff7f00')
        else
            button.buttonText:SetColor('ffffffff')
        end
        return string.format('%d/%d', info.tacticalSiloStorageCount, info.tacticalSiloMaxStorageCount)
    end
end

function EnterOverchargeMode()
    local econData = GetEconomyTotals()

    if not currentSelection[1] or currentSelection[1]:IsDead() then return end

    local bp = currentSelection[1]:GetBlueprint()

    local overchargeLevel = 0
    local overchargeFound = false
    local overchargePaused = currentSelection[1]:IsOverchargePaused()

    for index, weapon in bp.Weapon do
        if weapon.OverChargeWeapon then
            overchargeLevel = weapon.EnergyRequired
            overchargeFound = true
            break
        end
    end

    if overchargeFound then
        if overchargeLevel > 0 and econData["stored"]["ENERGY"] > overchargeLevel and not overchargePaused then
            ConExecute('StartCommandMode order RULEUCC_Overcharge')
        end
    end
end

local function OverChargeFrame(self, deltaTime)

    if deltaTime and currentSelection[1] then

        if currentSelection[1]:IsDead() then return end

        local bp = currentSelection[1]:GetBlueprint()
        local overchargeLevel = false

        -- find the overcharge weapon --
        for index, weapon in bp.Weapon do
            if weapon.OverChargeWeapon then
                overchargeLevel = weapon.EnergyRequired
                break
            end
        end

        -- now see if there's enough power to use the weapon --
        if overchargeLevel then

            if not currentSelection[1]:IsOverchargePaused() then

                local econData = GetEconomyTotals()

                -- if we have the charge - enable the weapon & play the sound
                if econData["stored"]["ENERGY"] > overchargeLevel then

                    if self:IsDisabled() then

                        self:Enable()

                        local armyTable = GetArmiesTable()
                        local facStr = import('/lua/factions.lua').Factions[armyTable.armiesTable[armyTable.focusArmy].faction + 1].SoundPrefix
                        local sound = Sound({Bank = 'XGG', Cue = 'Computer_Computer_Basic_Orders_01173'})

                        PlayVoice(sound)
                    end

                else
                    self:Disable()
                end

            else
                if not self:IsDisabled() then
                    self:Disable()
                end
            end

        else
            self:SetNeedsFrameUpdate(false)
        end
    end
end

-- sets up an orderInfo for each order that comes in
-- preferredSlot is custom data that is used to determine what slot the order occupies
-- initialStateFunc is a function that gets called once the control is created and allows you to set the initial state of the button
--      the function should have this declaration: function(checkbox, unitList)
-- extraInfo is used for storing any extra information required in setting up the button
local defaultOrdersTable = {
    -- Common rules
    RULEUCC_Move = {                helpText = "move",          bitmapId = 'move',                  preferredSlot = 1,  behavior = StandardOrderBehavior    },
    RULEUCC_Attack = {              helpText = "attack",        bitmapId = 'attack',                preferredSlot = 2,  behavior = StandardOrderBehavior    },
    AttackMove = {                  helpText = "attack_move",   bitmapId = 'attack_move',           preferredSlot = 3,  behavior = AttackMoveBehavior       },
    RULEUCC_Overcharge = {          helpText = "overcharge",    bitmapId = 'overcharge',            preferredSlot = 4,  behavior = StandardOrderBehavior,   onframe = OverChargeFrame},
    RULEUCC_Patrol = {              helpText = "patrol",        bitmapId = 'patrol',                preferredSlot = 5,  behavior = StandardOrderBehavior    },
    RULEUCC_Stop = {                helpText = "stop",          bitmapId = 'stop',                  preferredSlot = 6,  behavior = MomentaryOrderBehavior   },
    RULEUCC_Guard = {               helpText = "assist",        bitmapId = 'guard',                 preferredSlot = 7,  behavior = StandardOrderBehavior    },
    RULEUCC_RetaliateToggle = {     helpText = "mode",          bitmapId = 'stand-ground',          preferredSlot = 8,  behavior = RetaliateOrderBehavior,  initialStateFunc = RetaliateInitFunction, },

    -- Unit specific rules
    RULEUCC_Script = {      		helpText = "special_action",bitmapId = 'overcharge',            preferredSlot = 9,  behavior = StandardOrderBehavior    },

    RULEUCC_Transport = {           helpText = "transport",     bitmapId = 'unload',                preferredSlot = 10, behavior = StandardOrderBehavior    },
    RULEUCC_Ferry = {               helpText = "ferry",         bitmapId = 'ferry',                 preferredSlot = 11, behavior = StandardOrderBehavior    },
    RULEUCC_Sacrifice = {           helpText = "sacrifice",     bitmapId = 'sacrifice',             preferredSlot = 11, behavior = StandardOrderBehavior    },

    RULEUCC_SiloBuildTactical = {   helpText = "build_tactical",bitmapId = 'silo-build-tactical',   preferredSlot = 11, behavior = BuildOrderBehavior,      initialStateFunc = BuildInitFunction,},
    RULEUCC_SiloBuildNuke = {       helpText = "build_nuke",    bitmapId = 'silo-build-nuke',       preferredSlot = 11, behavior = BuildOrderBehavior,      initialStateFunc = BuildInitFunction,},

    RULEUCC_Tactical = {            helpText = "fire_tactical", bitmapId = 'launch-tactical',       preferredSlot = 12, behavior = StandardOrderBehavior,   ButtonTextFunc = TacticalBtnText},
    RULEUCC_Nuke = {                helpText = "fire_nuke",     bitmapId = 'launch-nuke',           preferredSlot = 12, behavior = StandardOrderBehavior,   ButtonTextFunc = NukeBtnText},

    RULEUCC_Dive = {                helpText = "dive",          bitmapId = 'dive',                  preferredSlot = 13, behavior = DiveOrderBehavior,       initialStateFunc = DiveInitFunction,},   
    RULEUCC_Teleport = {            helpText = "teleport",      bitmapId = 'teleport',              preferredSlot = 13, behavior = StandardOrderBehavior    },

    RULEUCC_Reclaim = {             helpText = "reclaim",       bitmapId = 'reclaim',               preferredSlot = 14, behavior = StandardOrderBehavior    },
    RULEUCC_Capture = {             helpText = "capture",       bitmapId = 'convert',               preferredSlot = 15, behavior = StandardOrderBehavior    },
    RULEUCC_Repair = {              helpText = "repair",        bitmapId = 'repair',                preferredSlot = 16, behavior = StandardOrderBehavior    },
    RULEUCC_Dock = {                helpText = "dock",          bitmapId = 'dock',                  preferredSlot = 16, behavior = DockOrderBehavior        },
    
    DroneL = {                      helpText = "drone",         bitmapId = 'unload02',              preferredSlot = 14, behavior = DroneBehavior,           initialStateFunc = DroneInit,},
    DroneR = {                      helpText = "drone",         bitmapId = 'unload02',              preferredSlot = 14, behavior = DroneBehavior,           initialStateFunc = DroneInit,},

    -- Unit toggle rules
    RULEUTC_ShieldToggle = {        helpText = "toggle_shield",     bitmapId = 'shield',            preferredSlot = 9,  behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 0,},
    RULEUTC_WeaponToggle = {        helpText = "toggle_weapon",     bitmapId = 'toggle-weapon',     preferredSlot = 9,  behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 1,},    
    RULEUTC_JammingToggle = {       helpText = "toggle_jamming",    bitmapId = 'jamming',           preferredSlot = 10, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 2,},
    RULEUTC_IntelToggle = {         helpText = "toggle_intel",      bitmapId = 'intel',             preferredSlot = 10, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 3,},
    RULEUTC_ProductionToggle = {    helpText = "toggle_production", bitmapId = 'production',        preferredSlot = 11, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 4,},
    RULEUTC_StealthToggle = {       helpText = "toggle_stealth",    bitmapId = 'stealth',           preferredSlot = 11, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 5,},
    RULEUTC_GenericToggle = {       helpText = "toggle_generic",    bitmapId = 'production',        preferredSlot = 12, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 6,},
    RULEUTC_SpecialToggle = {       helpText = "toggle_special",    bitmapId = 'activate-weapon',   preferredSlot = 13, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 7,},
    RULEUTC_CloakToggle = {         helpText = "toggle_cloak",      bitmapId = 'intel-counter',     preferredSlot = 13, behavior = ScriptButtonOrderBehavior,   initialStateFunc = ScriptButtonInitFunction, extraInfo = 8,},
}

local standardOrdersTable = nil

local specialOrdersTable = {
    RULEUCC_Pause = {behavior = pauseFunc, notAvailableBehavior = disPauseFunc},
}


-- this is a used as a set
local commonOrders = {
    RULEUCC_Move = true,
    RULEUCC_Attack = true,
    AttackMove = true,
    RULEUCC_Patrol = true,
    RULEUCC_Stop = true,
    RULEUCC_Guard = true, 
    RULEUCC_RetaliateToggle = true,
}

--[[
Add an order to a particular slot, destroys what's currently in the slot if anything
Returns checkbox if you need to add any data to the structure

The orderInfo format is:
{
    helpText = <string>,    --
    bitmapId = <string>,    -- the id used to construct the bitmap name (see GetOrderBitmapNames above)
    disabled = <bool>,      -- if true, button will start disabled
    behavior = <function>,  -- function(self, modifiers) this is the checkbox OnClick behavior
}

Since this is a table, if you need any more information, for instance, the command to be emmited from the OnClick
you can add it to the table and it will be ignored, so you're safe to put whatever info you need in to it. When the
OnClick callback is called, self._data will contain this info.
--]]
local function AddOrder(orderInfo, slot, batchMode)
    if not slot then return end
    batchMode = batchMode or false

    --LOG("*AI DEBUG Adding Order "..repr(orderInfo.helpText).." to slot "..slot )
    local checkbox = Checkbox(controls.orderButtonGrid, GetOrderBitmapNames(orderInfo.bitmapId))

    -- set the info in to the data member for retrieval
    checkbox._data = orderInfo

    -- set up initial help text
    checkbox._curHelpText = orderInfo.helpText

    -- set up click handler
    checkbox.OnClick = orderInfo.behavior

    -- if the order has an onframe value - do it
    if orderInfo.onframe then
        checkbox.EnableEffect = Bitmap(checkbox, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
        LayoutHelpers.AtCenterIn(checkbox.EnableEffect, checkbox)
        checkbox.EnableEffect:DisableHitTest()
        checkbox.EnableEffect:SetAlpha(0)
        checkbox.EnableEffect.Incrimenting = false
        checkbox.EnableEffect.OnFrame = function(self, deltatime)
            local alpha
            if self.Incrimenting then
                alpha = self.Alpha + (deltatime * 2)
                if alpha > 1 then
                    alpha = 1
                    self.Incrimenting = false
                end
            else
                alpha = self.Alpha - (deltatime * 2)
                if alpha < 0 then
                    alpha = 0
                    self.Incrimenting = true
                end
            end
            self.Height:Set(function() return checkbox.Height() + (checkbox.Height() * alpha * .5) end)
            self.Width:Set(function() return checkbox.Height() + (checkbox.Height() * alpha * .5) end)
            self.Alpha = alpha
            self:SetAlpha(alpha * .45)
        end
        checkbox:SetNeedsFrameUpdate(true)
        checkbox.OnFrame = orderInfo.onframe
        checkbox.OnEnable = function(self)
            self.EnableEffect:SetNeedsFrameUpdate(true)
            self.EnableEffect.Incrimenting = false
            self.EnableEffect:SetAlpha(1)
            self.EnableEffect.Alpha = 1
            Checkbox.OnEnable(self)
        end
        checkbox.OnDisable = function(self)
            self.EnableEffect:SetNeedsFrameUpdate(false)
            self.EnableEffect:SetAlpha(0)
            Checkbox.OnDisable(self)
        end
    end

    -- if the order has functions associated with the button text
    if orderInfo.ButtonTextFunc then
        checkbox.buttonText = UIUtil.CreateText(checkbox, '', 18, UIUtil.bodyFont)
        checkbox.buttonText:SetText(orderInfo.ButtonTextFunc(checkbox))
        checkbox.buttonText:SetColor('ffffffff')
        checkbox.buttonText:SetDropShadow(true)

        LayoutHelpers.AtBottomIn(checkbox.buttonText, checkbox)
        LayoutHelpers.AtHorizontalCenterIn(checkbox.buttonText, checkbox)
        checkbox.buttonText:DisableHitTest()
        checkbox.buttonText:SetNeedsFrameUpdate(true)
        checkbox.buttonText.OnFrame = function(self, delta)
            self:SetText(orderInfo.ButtonTextFunc(checkbox))
        end
    end

    -- set up tooltips
    checkbox.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            if controls.orderGlow then
                controls.orderGlow:Destroy()
                controls.orderGlow = false
            end                
            CreateMouseoverDisplay(self, self._curHelpText, 1)
            glowThread = CreateOrderGlow(self)
        elseif event.Type == 'MouseExit' then
            if controls.mouseoverDisplay then
                controls.mouseoverDisplay:Destroy()
                controls.mouseoverDisplay = false
            end
            if controls.orderGlow then
                controls.orderGlow:Destroy()
                controls.orderGlow = false
                KillThread(glowThread)
            end
        end
        Checkbox.HandleEvent(self, event)
    end

    -- calculate row and column, remove old item, add new checkbox
    local cols, rows = controls.orderButtonGrid:GetDimensions()
    local row = math.ceil(slot / cols)
    local col = math.mod(slot - 1, cols) + 1
    controls.orderButtonGrid:DestroyItem(col, row, batchMode)
    controls.orderButtonGrid:SetItem(checkbox, col, row, batchMode)

    -- all credit to Domino Mod Support	-- resize our icons
    LayoutHelpers.SetDimensions(checkbox, Grid_Params.Order_Slots.iconsize.width, Grid_Params.Order_Slots.iconsize.height)

    -- Handle Hotbuild labels
    if orderKeys[orderInfo.helpText] then
        hotkeyLabel_addLabel(checkbox, checkbox, orderKeys[orderInfo.helpText])
    end

    return checkbox
end

-- creates the buttons for the common orders, and then disables them if they aren't in the order set
local function CreateCommonOrders(availableOrders, init)
    -- setup the common (always added) orders
    for key in commonOrders do
        local orderInfo = standardOrdersTable[key]

        local orderCheckbox = AddOrder(orderInfo, orderInfo.preferredSlot, true)
        orderCheckbox._order = key
        orderCheckbox._toggleState = 0

        if not init and orderInfo.initialStateFunc then
            orderInfo.initialStateFunc(orderCheckbox, currentSelection)
        end

        orderCheckbox:Disable()

        orderCheckboxMap[key] = orderCheckbox
    end

    --LOG("*AI DEBUG Available Common Orders are "..repr(availableOrders))
    -- loop thru ALL available orders and set them up if they are standard
    for index, availOrder in availableOrders do
        -- skip any orders not in the standard table --
        if not standardOrdersTable[availOrder] then
            --LOG("*AI DEBUG availOrder "..repr(availOrder).." not present in standardOrdersTable ")  --..repr(standardOrdersTable) )
            continue
        end
        if commonOrders[availOrder] then
            --LOG("*AI DEBUG Enabling common order "..repr(availOrder))
            local ck = orderCheckboxMap[availOrder]
            ck:Enable()
        end
    end
end

-- creates the buttons for the alt orders, placing them as possible
local function CreateAltOrders(availableOrders, availableToggles, units)

    --LOG("*AI DEBUG Creating ALT Orders")

    --TODO? it would indeed be easier if the alt orders slot was in the blueprint, but for now try
    --to determine where they go by using preferred slots

    --Look for units in the selection that have special ability buttons
    --If any are found, add the ability information to the standard order table
    if units and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, units) then

        for index, unit in units do

            local tempBP = UnitData[unit:GetEntityId()]

            if tempBP.Abilities then

                --LOG("*AI DEBUG Available Orders are "..repr(availableOrders) )
                
                for abilityIndex, ability in tempBP.Abilities do

                    if ability.Active != false then

                        --LOG("*AI DEBUG Adding Ability order "..repr(ability).." for index "..repr(abilityIndex) )

                        table.insert(availableOrders, abilityIndex)

                        -- if the preferred slot and the script were defined in the ability (from the bp)
                        -- we'll use those, if not, lets see if there is an entry in the abilitydefinitions
                        if (not ability.perferredSlot) and (not ability.script) then
                            standardOrdersTable[abilityIndex] = table.merged(ability, import('/lua/abilitydefinition.lua').abilities[abilityIndex])
                        else
                            standardOrdersTable[abilityIndex] = ability
                        end

                        --LOG("*AI DEBUG Added Ability order data is "..repr(standardOrdersTable[abilityIndex]))

                        standardOrdersTable[abilityIndex].behavior = AbilityButtonBehavior
                        
                    end
                end
            end
        end
    end

    local assitingUnitList = {}
    local podUnits = {}

    if table.getn(units) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units) or EntityCategoryFilterDown(categories.POD, units)) then

        --LOG("*AI DEBUG Adding Drone abilities")
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units)
        local Pods = EntityCategoryFilterDown(categories.POD, units)
        local assistingUnits = {}

        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end

        if assistingUnits[1] then
            table.insert(availableOrders, 'DroneL')
            assitingUnitList['DroneL'] = assistingUnits[1]
        end

        if assistingUnits[2] then
            table.insert(availableOrders, 'DroneR')
            assitingUnitList['DroneR'] = assistingUnits[2]
        end
    end
    
    -- determine what slots to put alt orders
    -- we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    local usedSpecials = {}

    if availableOrders[1] then
        --LOG("*AI DEBUG Examining Available Orders "..repr(availableOrders))
        for index, availOrder in availableOrders do
            if standardOrdersTable[availOrder] then 
                local preferredSlot = standardOrdersTable[availOrder].preferredSlot
                if not desiredSlot[preferredSlot] then
                    desiredSlot[preferredSlot] = {}
                end
                --LOG("*AI DEBUG Adding "..repr(availOrder).." to desired slot "..preferredSlot)
                table.insert(desiredSlot[preferredSlot], availOrder)
            else
                if specialOrdersTable[availOrder] != nil then
                    --LOG("*AI DEBUG Adding "..repr(availOrder).." to SpecialOrdersTable")
                    specialOrdersTable[availOrder].behavior()
                    usedSpecials[availOrder] = true
                end
            end
        end
    end

    if availableToggles[1] then
        --LOG("*AI DEBUG Examining Available Toggles "..repr(availableToggles))
        for index, availToggle in availableToggles do
            if standardOrdersTable[availToggle] then 
                local preferredSlot = standardOrdersTable[availToggle].preferredSlot
                if not desiredSlot[preferredSlot] then
                    desiredSlot[preferredSlot] = {}
                end
                --LOG("*AI DEBUG Adding "..repr(availToggle).." to desired slot "..preferredSlot)
                table.insert(desiredSlot[preferredSlot], availToggle)
            else
                if specialOrdersTable[availToggle] != nil then
                    --LOG("*AI DEBUG Adding "..repr(availToggle).." to SpecialOrdersTable")
                    specialOrdersTable[availToggle].behavior()
                    usedSpecials[availToggle] = true
                end
            end
        end
    end

    if specialOrdersTable[1] then
        --LOG("*AI DEBUG Examining SpecialOrders "..repr(specialOrdersTable) )
        for i, specialOrder in specialOrdersTable do
            if not usedSpecials[i] and specialOrder.notAvailableBehavior then
                specialOrder.notAvailableBehavior()
            end
        end
    end

    -- now go through that table and determine what doesn't fit and look for slots that are empty
    local orderInSlot = {}
    --LOG("*AI DEBUG Insert Orders into desired alt slots from "..Grid_Params.Grid.firstAltSlot.." to "..Grid_Params.Grid.numSlots)

    -- go through first time and add all the first entries to their preferred slot
    for slot = Grid_Params.Grid.firstAltSlot,Grid_Params.Grid.numSlots do
        --LOG("*AI DEBUG Examining Desired Slot "..repr(slot))
        if desiredSlot[slot] then
            --LOG("*AI DEBUG Slot "..repr(slot).." filled with order "..repr(desiredSlot[slot][1]))
            orderInSlot[slot] = desiredSlot[slot][1]
        end
    end

    -- now put any additional entries wherever they will fit
--[[
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = firstAltSlot, numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        WARN("No free slot for order: " .. item)
                        -- could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end
--]]

    for slot = Grid_Params.Grid.firstAltSlot,Grid_Params.Grid.numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = Grid_Params.Grid.firstAltSlot, Grid_Params.Grid.numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        WARN("No free slot for order: " .. item)
                        # could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end

    -- now map it the other direction so it's order to slot
    local slotForOrder = {}
    for slot, order in orderInSlot do
        slotForOrder[order] = slot
    end

    --LOG(repr(availableOrders), repr(orderInSlot), repr(slotForOrder))

    -- create the alt order buttons
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end -- skip any orders we don't have in our table
        if not commonOrders[availOrder] then

            local orderInfo = standardOrdersTable[availOrder] or AbilityInformation[availOrder]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availOrder], true)

            if not orderCheckbox then continue end
            orderCheckbox._order = availOrder

            if standardOrdersTable[availOrder].script then
                orderCheckbox._script = standardOrdersTable[availOrder].script
            end

            if assitingUnitList[availOrder] then
                orderCheckbox._unit = assitingUnitList[availOrder]
            end

            if podUnits[availOrder] then
                orderCheckbox._pod = podUnits[availOrder]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availOrder] = orderCheckbox
        end
    end

    for index, availToggle in availableToggles do
        if not standardOrdersTable[availToggle] then continue end -- skip any orders we don't have in our table
        if not commonOrders[availToggle] then
            local orderInfo = standardOrdersTable[availToggle] or AbilityInformation[availToggle]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availToggle], true)

            orderCheckbox._order = availToggle

            if standardOrdersTable[availToggle].script then
                orderCheckbox._script = standardOrdersTable[availToggle].script
            end

            if assitingUnitList[availToggle] then
                orderCheckbox._unit = assitingUnitList[availToggle]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availToggle] = orderCheckbox
        end
    end
end

-- called by gamemain when new orders are available, 
function SetAvailableOrders(availableOrders, availableToggles, newSelection)
    -- adopted from Domino Mod Support 
    if table.getn(newSelection) == 0 then
        if controls.bg.Mini then
            controls.bg.Mini(true)
        end
        currentSelection = false
        return
    end

	local AddedToggles = {}
	local SelectedUnits = newSelection

--[[
    -- this block removes stunned units from the selection block
    -- so they cannot click build or order buttons.. 
    for index, unit in SelectedUnits do
        local IsStunned = GetUnitParam(unit, 'IsStunned')
        if IsStunned then 
            table.removeByValue(newSelection, unit)		
        end
    end
--]]

    --reset our grid. important.
    ResetGrid()

    -- save new selection    
    currentSelection = newSelection

    -- clear existing orders
    orderCheckboxMap = {}
    controls.orderButtonGrid:DestroyAllItems(true)

    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)
    
    -- look in blueprints for any icon or tooltip overrides
    -- note that if multiple overrides are found for the same order, then the default is used
    -- the syntax of the override in the blueprint is as follows (the overrides use same naming as in the default table above):
    -- In General table
    -- OrderOverrides = {
    --     RULEUTC_IntelToggle = {
    --         bitmapId = 'custom',
    --         helpText = 'toggle_custom',
    --         prefferedslot = slotnumber
    --     },
    --  },
    local orderDiffs
    for index, unit in newSelection do
        local overrideTable = unit:GetBlueprint().General.OrderOverrides
        if overrideTable then
            for orderKey, override in overrideTable do
                if orderDiffs == nil then
                    orderDiffs = {}
                end
                if orderDiffs[orderKey] != nil and (orderDiffs[orderKey].bitmapId != override.bitmapId or orderDiffs[orderKey].helpText != override.helpText) then
                    -- found order diff already, so mark it false so it gets ignored when applying to table
                    orderDiffs[orderKey] = false
                else
                    orderDiffs[orderKey] = override
                end
            end
        end
    end

    -- apply overrides
    if orderDiffs != nil then
        for orderKey, override in orderDiffs do
            if override and override != false then
                if override.bitmapId then
                    standardOrdersTable[orderKey].bitmapId = override.bitmapId
                end
                if override.helpText then
                    standardOrdersTable[orderKey].helpText = override.helpText
                end
                if override.preferredSlot then
                    standardOrdersTable[orderKey].preferredSlot = override.preferredSlot
                end
            end
        end
    end

    SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)

    if table.getn(currentSelection) == 0 and controls.bg.Mini then
        controls.bg.Mini(true)
    elseif controls.bg.Mini then
        controls.bg.Mini(false)
    end
end


function SetAvailableOrdersMod(availableOrders, availableToggles, newSelection)
    --LOG("*AI DEBUG availableOrders now is "..repr(availableOrders))
    currentSelection = newSelection

    local TotalSlotsNeeded = 0
    local numValidOrders = 0
    local HighestSlot = 16
    local AddedAbilities = {}

--[[
    -- this block is here to support a DMS feature (not in use)
    if currentSelection then
        for index, Unit in currentSelection do
            local UnitId = Unit:GetEntityId()
            local UnitAbilities = GetUnitParamTable(Unit, 'Abilities')
            local UnitRallyPoints = UnitRallyPoints[UnitId]

            --Abilities....
            if UnitAbilities and table.getsize(UnitAbilities) > 0 then
                for AbilityName, Params in UnitAbilities do
                    if Params then 
                        local idenitfier = Params.identifier
                        if Params.active and not AddedAbilities[idenitfier] and Params.showtoggle then
                            AddedAbilities[idenitfier] = true
                            TotalSlotsNeeded = TotalSlotsNeeded + 1
                            if Params.preferredSlot > HighestSlot then 
                                HighestSlot = Params.preferredSlot
                            end
                        end
                    end
                end
            end

            --RallyPoints
            if UnitRallyPoints and table.getsize(UnitRallyPoints) > 0 then
                for RallyPointName, Params in UnitRallyPoints do
                    if Params then 
                        local idenitfier = Params.identifier
                        if Params.active and not AddedAbilities[idenitfier] and Params.showtoggle then
                            AddedAbilities[idenitfier] = true
                            TotalSlotsNeeded = TotalSlotsNeeded + 1
                            if Params.preferredSlot > HighestSlot then 
                                HighestSlot = Params.preferredSlot
                            end
                        end
                    end
                end
            end
        end
    end
--]]

    --clear ALL existing orders
    orderCheckboxMap = {}
    controls.orderButtonGrid:DestroyAllItems(true)

    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)

    -- look in blueprints for any icon or tooltip overrides
    -- note that if multiple overrides are found for the same order, then the default is used
    -- the syntax of the override in the blueprint is as follows (the overrides use same naming as in the default table above):
    -- In General table
    -- OrderOverrides = {
    --     RULEUTC_IntelToggle = {
    --         bitmapId = 'custom',
    --         helpText = 'toggle_custom',
    --     },
    --  },
    -- 
    local orderDiffs
    for index, unit in newSelection do
        local overrideTable = unit:GetBlueprint().General.OrderOverrides
        if overrideTable then
            for orderKey, override in overrideTable do
                if orderDiffs == nil then
                    orderDiffs = {}
                end
                if orderDiffs[orderKey] != nil and (orderDiffs[orderKey].bitmapId != override.bitmapId or orderDiffs[orderKey].helpText != override.helpText) then
                    -- found order diff already, so mark it false so it gets ignored when applying to table
                    orderDiffs[orderKey] = false
                else
                    orderDiffs[orderKey] = override
                end
            end
        end
    end

    -- apply overrides
    if orderDiffs != nil then
        for orderKey, override in orderDiffs do
            if override and override != false then
                if override.bitmapId then
                    standardOrdersTable[orderKey].bitmapId = override.bitmapId
                end
                if override.helpText then
                    standardOrdersTable[orderKey].helpText = override.helpText
                end
                
                if override.preferredSlot then
                    standardOrdersTable[orderKey].preferredSlot = override.preferredSlot
                end
            end
        end
    end

    --Lets see how many orders we have, and create our orders panel accordingly.	
    local AddedOrders = {}
    for i, v in availableOrders do
        if standardOrdersTable[v] and not AddedOrders[v] then
            AddedOrders[v] = true
            numValidOrders = numValidOrders + 1
            if standardOrdersTable[v].preferredSlot and standardOrdersTable[v].preferredSlot > HighestSlot then 
                HighestSlot = standardOrdersTable[v].preferredSlot
            end
        end
    end

    local availableTogglesMod = {}
    for i, v in availableToggles do
        if standardOrdersTable[v] and not AddedOrders[v] then
            AddedOrders[v] = true
            table.insert(availableTogglesMod, v)
            numValidOrders = numValidOrders + 1
            if standardOrdersTable[v].preferredSlot and standardOrdersTable[v].preferredSlot > HighestSlot then 
                HighestSlot = standardOrdersTable[v].preferredSlot
            end
        end
    end

	local assitingUnitList = {}
    local podUnits = {}
    if table.getn(currentSelection) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection) or EntityCategoryFilterDown(categories.POD, currentSelection)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, currentSelection)
        local Pods = EntityCategoryFilterDown(categories.POD, currentSelection)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
            TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
        if assistingUnits[2] then
            TotalSlotsNeeded = TotalSlotsNeeded + 1
        end
    end

    ---------------------------------------------------------------------------------------
    --count our disabled buttons.
    local common = table.getsize(commonOrders)
    local sub = 0
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end   # skip any orders we don't have in our table
        if commonOrders[availOrder] then
            sub = sub + 1
        end
    end

    local commonsub = common - sub

    ---------------------------------------------------------------------------------------
    TotalSlots = (numValidOrders + TotalSlotsNeeded + commonsub)

    --LOG('numValidOrders ' .. repr(numValidOrders))
    --LOG('commonsub ' .. repr(commonsub))
    --LOG('total needed ' .. repr(TotalSlotsNeeded))
    --LOG('TotalSlots ' .. repr(TotalSlots))
    --LOG('HighestSlot ' .. repr(HighestSlot))

    if HighestSlot > TotalSlots then 
        SetGridParams(HighestSlot, true)
    else
        SetGridParams(TotalSlots, true)
    end

    --Changed this, if there is enough slots for all orders show the orders else LOG a warning and just show an empty panel.
    --Were only going to populate the orders panel IF there is enough slots.
    if TotalSlots <= Grid_Params.Grid.numSlots then		
        CreateCommonOrders(availableOrders)
        CreateAltOrders(availableOrders, availableToggles, currentSelection)
        controls.orderButtonGrid:EndBatch()
    else
        WARN('ORDERS --> NOT ENOUGH SLOTS, REQUESTED:> ' .. repr(TotalSlots) .. ' MAX:> ' .. repr(Grid_Params.Grid.numSlots))
    end

    --not needed but kept in til the end. as i hide the panel in the SetAvailableOrders function if there is no selection
    if table.getn(currentSelection) == 0 and controls.bg.Mini then
        controls.bg.Mini(true)
    elseif controls.bg.Mini then
        controls.bg.Mini(false)
    end
end

function CreateControls()
    if controls.mouseoverDisplay then
        controls.mouseoverDisplay:Destroy()
        controls.mouseoverDisplay = false
    end
    if not controls.bg then
        controls.bg = Bitmap(controls.controlClusterGroup)
    end
    if not controls.orderButtonGrid then
        CreateOrderButtonGrid()
    end
    if not controls.bracket then
        controls.bracket = Bitmap(controls.bg)
        controls.bracket:DisableHitTest()
    end
    if not controls.bracketMax then
        controls.bracketMax = Bitmap(controls.bg)
        controls.bracketMax:DisableHitTest()
    end
    if not controls.bracketMid then
        controls.bracketMid = Bitmap(controls.bg)
        controls.bracketMid:DisableHitTest()
    end
    local count = 0
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg.OnFrame = function(self, delta)
        count = count + 1
        if count > 4 then
            self:SetNeedsFrameUpdate(false)
        end
        self:Hide()
    end
end

function SetLayout(layout)
    layoutVar = layout

    -- clear existing orders
    orderCheckboxMap = {}
    if controls and controls.orderButtonGrid then
        controls.orderButtonGrid:DeleteAndDestroyAll(true)
    end

    CreateControls()
    import(UIUtil.GetLayoutFilename('orders')).SetLayout()

    -- created greyed out orders on setup
    CreateCommonOrders({}, true)
end

-- called from gamemain to create control
function SetupOrdersControl(parent, mfd)
    controls.controlClusterGroup = parent
    controls.mfdControl = mfd

    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)

    SetLayout(UIUtil.currentLayout)

    -- setup command mode behaviors
    CommandMode.AddStartBehavior(
        function(commandMode, data)
            local orderCheckbox = orderCheckboxMap[data]
            if orderCheckbox then
                orderCheckbox:SetCheck(true)
            end
        end
    )
    CommandMode.AddEndBehavior(
        function(commandMode, data)
            local orderCheckbox = orderCheckboxMap[data]
            if orderCheckbox then
                orderCheckbox:SetCheck(false)
            end
        end
    )

    return controls.bg
end

function Contract()
    controls.bg:Hide()
end

function Expand()
    if GetSelectedUnits() then
        controls.bg:Show()
    else
        controls.bg:Hide()
    end
end

-- a DMS function to retrieve the various layout parameters
function Get_Grid_Params()
	return Grid_Params
end

--important function, it sets the icons and panel to the correct size for the amount of orders on the panel.
--ive added support for upto 24 order icons, i dont think we will ever need more than this.
function SetGridParams(NumOrders, update)
    OrderNum = NumOrders

    local params = {}

    if NumOrders <= 16 then 
        --WARN('SETTING SLOTS TO 16 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
        Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['16Slots'] or SlotIconsTable['bottom']['16Slots']
        params = SlotIconsTable[layoutVar]['16Slots'] or SlotIconsTable['bottom']['16Slots']

    elseif NumOrders > 18 and NumOrders <= 24 then 
        --WARN('SETTING SLOTS TO 24 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
        Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
        params = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']

    else
        --WARN('SETTING SLOTS TO 24 --> ' .. ' NumOrders ' .. repr(NumOrders) .. ' Layout ' .. repr(layoutVar))
        Grid_Params.Order_Slots = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
        params = SlotIconsTable[layoutVar]['24Slots'] or SlotIconsTable['bottom']['24Slots']
    end

    Grid_Params.Order_Slots.layout = layoutVar
    Grid_Params.Order_Slots.NumOrders = NumOrders

    if update then 

        --Lets resize the buttons and order panel.

        --buttons
        controls.orderButtonGrid._itemWidth = LayoutHelpers.ScaleNumber(params.iconsize.width)
        controls.orderButtonGrid._itemHeight = LayoutHelpers.ScaleNumber(params.iconsize.height)

        --panel
        LayoutHelpers.SetDimensions(controls.bg, params.panelsize.width, params.panelsize.height)

        controls.orderButtonGrid:_CalculateVisible()
    end
end

--move this table to the initialize file and merge it.. with other mods icons tables.. 
--so they can add there own layouts to this table to show the correct icon/panel sizes
--remove the things that are not needed.. 
SlotIconsTable = {
	bottom = { 
		['16Slots'] = { 
			numSlots = 16,
			firstAltSlot = 4,
			vertRows = 8,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 43,
				width = 40,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 346,        --265,
				height = 120,       --100,
			},
		},

		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 4,
			vertRows = 8,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 346,
				height = 120,
			},
		},
	},
	
	left = { 
		['16Slots'] = { 
			numSlots = 16,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 240,
				height = 70,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 240,
				height = 116, -- when this value is > 116 the construction bar doesnt close correctly in left layout.
			},
		},
	},
	
	right = { 
		['16Slots'] = { 
			numSlots = 16,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 40,
				width = 40,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 346,
				height = 120,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 346,
				height = 120,
			},
		},
	},
	
	dom_bottom = { 
		['16Slots'] = { 
			numSlots = 16,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 2,
		
			---------------------
			--colums & rows
			vertCols = 2,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 26,
				width = 26,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 80,
			},
		},
	
		['24Slots'] = { 
			numSlots = 24,
			firstAltSlot = 9,
			vertRows = 8,
			horzRows = 3,
		
			---------------------
			--colums & rows
			vertCols = 3,
			horzCols = 8,
		
			---------------------
			--icon size
			iconsize = { 
				height = 30,
				width = 30,
			},
			
			---------------------
			--panel size
			panelsize = { 
				width = 195,
				height = 140,
			},
		},
	},
}
