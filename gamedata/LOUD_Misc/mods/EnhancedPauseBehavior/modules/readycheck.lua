--[[
    Enhanced Pause Behavior - ready check and countdown before resuming a pause

    Clients sync only through SessionSendChatMessage (outside the simulation),
    so the mod cannot cause desyncs.
]]

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

local TAG = 'EnhancedPauseBehavior'
local COUNTDOWN_SECONDS = 5
local POLL_SECONDS = 0.5
local STALE_SECONDS = 3
local RETRY_SECONDS = 3

local registered = false
local originalResume = false
local originalRequestPause = false
local blockedResume = false

local check = false
local pendingReady = {}
local requestCounter = 0
local ui = false

local Handle
local Refresh

local function LocalClient()
    for index, client in ipairs(GetSessionClients()) do
        if client['local'] then
            return index
        end
    end
    return false
end

local function ClientName(index)
    local client = GetSessionClients()[index]
    if client and client.name then
        return client.name
    end
    return 'Client ' .. tostring(index)
end

local function Participants()
    local sources = {}
    for _, army in pairs(GetArmiesTable().armiesTable) do
        if army.human and not army.outOfGame then
            for _, src in pairs(army.authorizedCommandSources or {}) do
                sources[src] = true
            end
        end
    end
    local result = {}
    local count = 0
    for index, client in ipairs(GetSessionClients()) do
        if client.connected then
            for _, src in pairs(client.authorizedCommandSources or {}) do
                if sources[src] then
                    result[index] = true
                    count = count + 1
                    break
                end
            end
        end
    end
    return result, count
end

local function IsParticipant(index)
    if not index then
        return false
    end
    local set = Participants()
    return set[index] == true
end

local function Applicable()
    if SessionIsReplay() or SessionIsGameOver() or not SessionIsMultiplayer() then
        return false
    end
    if not SessionIsPaused() then
        return false
    end
    local _, count = Participants()
    return count > 1
end

local function Send(msg)
    local me = LocalClient()
    if not me then
        return
    end
    msg[TAG] = true
    msg.from = me
    SessionSendChatMessage(msg)
    Handle(me, msg)
end

local function DestroyUI()
    if ui then
        ui:Destroy()
        ui = false
    end
end

local function Close(note)
    check = false
    pendingReady = {}
    DestroyUI()
    if note then
        print(note)
    end
end

local function StartCountdown()
    check.phase = 'countdown'
    check.remaining = COUNTDOWN_SECONDS
    check.resumeAt = false
    check.countdownSet = Participants()
    check.note = false
end

local function StopCountdown(note)
    check.phase = 'check'
    check.remaining = 0
    check.resumeAt = false
    check.countdownSet = false
    check.note = note
end

local function Open(initiator, id)
    check = {
        id = id,
        initiator = initiator,
        ready = {},
        phase = 'check',
        remaining = 0,
        age = 0,
        poll = 0,
        resumeAt = false,
        countdownSet = false,
        note = false,
    }
    local pending = pendingReady[id]
    if pending then
        for client, value in pairs(pending) do
            check.ready[client] = value
        end
    end
    pendingReady = {}
    check.ready[initiator] = true
    PlaySound(Sound({Cue = 'UI_Main_Window_Open', Bank = 'Interface'}))
end

local function OnRequest(from, id)
    local me = LocalClient()
    local carryReady = false
    if check then
        if check.id == id then
            return
        end
        -- simultaneous requests: the one from the lowest client index wins on every machine
        if check.phase ~= 'check' or from >= check.initiator then
            return
        end
        carryReady = check.ready[me] == true and me ~= from
    end
    Open(from, id)
    if carryReady then
        Send({op = 'ready', id = id, value = true})
    end
end

local function OnReady(from, id, value)
    if check and check.id == id then
        check.ready[from] = value
        if not value and check.phase == 'countdown' then
            StopCountdown('Countdown stopped by ' .. ClientName(from))
        end
    else
        pendingReady[id] = pendingReady[id] or {}
        pendingReady[id][from] = value
    end
end

local function Evaluate()
    if not check or check.phase ~= 'check' then
        return
    end
    if check.initiator ~= LocalClient() then
        return
    end
    local set, count = Participants()
    if count == 0 then
        return
    end
    for client in pairs(set) do
        if not check.ready[client] then
            return
        end
    end
    Send({op = 'go', id = check.id})
end

Handle = function(from, msg)
    local id = msg.id
    if type(id) ~= 'string' then
        return
    end
    local op = msg.op
    if op == 'request' then
        OnRequest(from, id)
    elseif op == 'ready' then
        OnReady(from, id, msg.value == true)
    elseif op == 'go' then
        if check and check.id == id then
            StartCountdown()
        end
    elseif op == 'cancel' then
        if check and check.id == id then
            Close('Resume cancelled by ' .. ClientName(from) .. ' - game stays paused.')
            return
        end
    end
    Evaluate()
    Refresh()
end

local function Poll()
    if SessionIsGameOver() then
        Close()
        return
    end
    if not SessionIsPaused() and check.age > STALE_SECONDS then
        Close()
        return
    end
    local initiator = GetSessionClients()[check.initiator]
    if not initiator or not initiator.connected then
        Close('Lost connection to ' .. ClientName(check.initiator) .. ' - resume cancelled, game stays paused.')
        return
    end
    if check.phase == 'countdown' and check.countdownSet then
        local set = Participants()
        for client in pairs(check.countdownSet) do
            if not set[client] then
                StopCountdown(ClientName(client) .. ' left the game - countdown restarted')
                break
            end
        end
    end
    -- initiator: resume did not take effect (game still paused) - try again
    if check.resumeAt and SessionIsPaused() and check.age - check.resumeAt > RETRY_SECONDS then
        check.resumeAt = check.age
        originalResume()
    end
    Evaluate()
    Refresh()
end

local function Tick(delta)
    if not check then
        return
    end
    check.age = check.age + delta
    if check.phase == 'countdown' then
        check.remaining = check.remaining - delta
        if check.remaining <= 0 then
            check.remaining = 0
            if check.initiator == LocalClient() and not check.resumeAt then
                check.resumeAt = check.age
                originalResume()
            end
        end
        if ui then
            ui.countdown:SetText('Resuming in ' .. tostring(math.ceil(check.remaining)))
        end
    end
    check.poll = check.poll + delta
    if check.poll >= POLL_SECONDS then
        check.poll = 0
        Poll()
    end
end

local function OnReadyButton()
    if not check then
        return
    end
    local me = LocalClient()
    if not IsParticipant(me) then
        return
    end
    if check.phase == 'countdown' then
        Send({op = 'ready', id = check.id, value = false})
    else
        Send({op = 'ready', id = check.id, value = not check.ready[me]})
    end
end

local function OnCancelButton()
    if check then
        Send({op = 'cancel', id = check.id})
    end
end

-- pause button/key during the ready check or countdown: withdraw own ready state
local function Halt()
    if not check then
        return
    end
    local me = LocalClient()
    if IsParticipant(me) and (check.ready[me] or check.phase == 'countdown') then
        Send({op = 'ready', id = check.id, value = false})
    end
end

local function BuildUI()
    local parent = Group(GetFrame(0), 'EnhancedPauseBehaviorDialog')
    parent.Depth:Set(GetFrame(0):GetTopmostDepth() + 5)
    LayoutHelpers.SetDimensions(parent, 340, 150)
    LayoutHelpers.AtHorizontalCenterIn(parent, GetFrame(0))
    LayoutHelpers.AtTopIn(parent, GetFrame(0), 170)

    local bg = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_m.dds'))
    LayoutHelpers.FillParent(bg, parent)
    bg.border = import('/lua/ui/dialogs/disconnect.lua').CreateBorder(bg)
    parent.bg = bg

    parent.title = UIUtil.CreateText(bg, 'Resume Game?', 18)
    LayoutHelpers.AtTopIn(parent.title, bg, -52)
    LayoutHelpers.AtHorizontalCenterIn(parent.title, parent)

    parent.info = UIUtil.CreateText(bg, '', 14, UIUtil.bodyFont)
    LayoutHelpers.AtTopIn(parent.info, bg, 4)
    LayoutHelpers.AtHorizontalCenterIn(parent.info, parent)

    parent.countdown = UIUtil.CreateText(bg, '', 30, UIUtil.titleFont)
    LayoutHelpers.AtHorizontalCenterIn(parent.countdown, parent)

    parent.note = UIUtil.CreateText(bg, '', 12, UIUtil.bodyFont)
    parent.note:SetColor('FFe24f2d')
    LayoutHelpers.AtHorizontalCenterIn(parent.note, parent)

    parent.readyBtn = UIUtil.CreateButtonStd(bg, '/widgets02/small', 'Ready', 12, 0)
    LayoutHelpers.AtLeftIn(parent.readyBtn, bg, 10)
    LayoutHelpers.AtBottomIn(parent.readyBtn, bg, 2)
    parent.readyBtn.OnClick = function(self, modifiers) OnReadyButton() end

    parent.cancelBtn = UIUtil.CreateButtonStd(bg, '/widgets02/small', 'Cancel', 12, 0)
    LayoutHelpers.AtRightIn(parent.cancelBtn, bg, 10)
    LayoutHelpers.AtBottomIn(parent.cancelBtn, bg, 2)
    parent.cancelBtn.OnClick = function(self, modifiers) OnCancelButton() end

    parent.rows = {}
    parent.signature = false

    parent:SetNeedsFrameUpdate(true)
    parent.OnFrame = function(self, delta)
        Tick(delta)
    end
    return parent
end

local function BuildRows(list)
    for _, row in ipairs(ui.rows) do
        row:Destroy()
    end
    ui.rows = {}
    for i, client in ipairs(list) do
        local row = Group(ui.bg)
        LayoutHelpers.SetDimensions(row, 300, 20)
        LayoutHelpers.AtTopIn(row, ui.bg, 30 + (i - 1) * 20)
        LayoutHelpers.AtHorizontalCenterIn(row, ui)
        row.name = UIUtil.CreateText(row, ClientName(client), 14, UIUtil.bodyFont)
        row.name:SetColor('FFbadbdb')
        LayoutHelpers.AtLeftTopIn(row.name, row, 0, 0)
        if check.ready[client] then
            row.state = UIUtil.CreateText(row, 'ready', 14, UIUtil.bodyFont)
            row.state:SetColor('FF7fd97f')
        else
            row.state = UIUtil.CreateText(row, 'waiting', 14, UIUtil.bodyFont)
            row.state:SetColor('FFe2b42d')
        end
        LayoutHelpers.AtRightTopIn(row.state, row, 0, 0)
        row:DisableHitTest(true)
        ui.rows[i] = row
    end
    local n = table.getn(list)
    LayoutHelpers.AtTopIn(ui.countdown, ui.bg, 34 + n * 20)
    LayoutHelpers.AtTopIn(ui.note, ui.bg, 72 + n * 20)
    LayoutHelpers.SetHeight(ui, 130 + n * 20)
end

Refresh = function()
    if not check then
        DestroyUI()
        return
    end
    if not ui then
        ui = BuildUI()
    end
    local me = LocalClient()
    local set = Participants()
    local list = {}
    for client in pairs(set) do
        table.insert(list, client)
    end
    table.sort(list)
    local signature = check.phase
    for _, client in ipairs(list) do
        signature = signature .. '|' .. tostring(client) .. '=' .. tostring(check.ready[client] == true)
    end
    if signature ~= ui.signature then
        ui.signature = signature
        BuildRows(list)
    end
    ui.info:SetText('Requested by ' .. ClientName(check.initiator))
    if check.phase == 'countdown' then
        ui.countdown:SetText('Resuming in ' .. tostring(math.ceil(check.remaining)))
    else
        ui.countdown:SetText('')
    end
    ui.note:SetText(check.note or '')
    if set[me] then
        ui.readyBtn:Show()
        ui.cancelBtn:Show()
        if check.phase == 'countdown' then
            ui.readyBtn.label:SetText('Stop')
        elseif check.ready[me] then
            ui.readyBtn.label:SetText('Not Ready')
        else
            ui.readyBtn.label:SetText('Ready')
        end
    else
        ui.readyBtn:Hide()
        ui.cancelBtn:Hide()
    end
end

local function ResumeWrapper()
    if check then
        Halt()
        blockedResume = true
        return
    end
    local me = LocalClient()
    if not Applicable() or not IsParticipant(me) then
        return originalResume()
    end
    requestCounter = requestCounter + 1
    blockedResume = true
    Send({op = 'request', id = tostring(me) .. ':' .. tostring(requestCounter)})
end

local function RequestPauseWrapper()
    if check and SessionIsPaused() then
        Halt()
        return
    end
    return originalRequestPause()
end

function OnChat(sender, msg)
    if type(msg) ~= 'table' or type(msg.from) ~= 'number' or type(msg.op) ~= 'string' then
        return
    end
    if msg.from == LocalClient() then
        return
    end
    Handle(msg.from, msg)
end

-- used by the pause button (tabs.lua hook): was the last SessionResume intercepted?
function ClearBlocked()
    blockedResume = false
end

function TakeBlocked()
    local value = blockedResume
    blockedResume = false
    return value
end

function OnGameResumed()
    if check then
        Close()
    end
end

function Init()
    if registered then
        return
    end
    registered = true
    import('/lua/ui/game/gamemain.lua').RegisterChatFunc(OnChat, TAG)
    originalResume = _G.SessionResume
    originalRequestPause = _G.SessionRequestPause
    _G.SessionResume = ResumeWrapper
    _G.SessionRequestPause = RequestPauseWrapper
end
