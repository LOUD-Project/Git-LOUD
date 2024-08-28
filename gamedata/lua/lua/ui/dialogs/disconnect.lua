--* File: lua/modules/ui/dialogs/disconnect.lua
--* Author: Chris Blackwell
--* Summary: handles multiplayer disconnects
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group

local parent = false
local tequal = table.equal
local tsorted = table.sorted


function DestroyDialog()
    if parent then
        parent:Destroy()
        parent = false
    end
end

local function CreateDialog(clients)

    import('/lua/ui/game/worldview.lua').UnlockInput()
    import('/lua/ui/game/gamemain.lua').KillWaitingDialog()

    GetCursor():Show()
    DestroyDialog()

    parent = Group(GetFrame(0), "diconnectDialogParentGroup")
    parent.Depth:Set(GetFrame(0):GetTopmostDepth() + 10)
    parent:SetNeedsFrameUpdate(true)
    parent.time = 0

    bg = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_m.dds'))
    LayoutHelpers.FillParent(bg, parent)

    bg.border = CreateBorder(bg)

    local dlgTitle = UIUtil.CreateText(bg, "<LOC UI_Disco0000>Connectivity", 18)

    LayoutHelpers.AtTopIn(dlgTitle, bg, -52)
    LayoutHelpers.AtHorizontalCenterIn(dlgTitle, parent)

    local slots = {}
    local previous = false

    for i,client in clients do

        local slot = Bitmap(bg, UIUtil.UIFile('/scx_menu/panel-brd/conn-bg.dds'),"clientSlotGroup " .. tostring(i))
        slots[i] = slot

        slot.index = i

        if previous then
            LayoutHelpers.Below(slot, previous)
        else
            LayoutHelpers.AtTopIn(slot, parent)
            LayoutHelpers.AtHorizontalCenterIn(slot, parent)
        end

        previous = slot

        slot.id = UIUtil.CreateText(slot, slot.index, 20, UIUtil.fixedFont)
        slot.id:SetColor('ffffffff')
        LayoutHelpers.AtLeftTopIn(slot.id, slot, 5, 1)

        slot.name = UIUtil.CreateText(slot, client.name, 16, UIUtil.fixedFont)
        slot.name:SetColor('FFbadbdb')
        LayoutHelpers.AtLeftTopIn(slot.name, slot, 20, 4)

        slot.ping = UIUtil.CreateText(slot, "", 14, UIUtil.fixedFont)
        LayoutHelpers.AtLeftTopIn(slot.ping, slot, 5, 32)

        slot.quiet = UIUtil.CreateText(slot, "", 14, UIUtil.fixedFont)
        LayoutHelpers.AtLeftTopIn(slot.quiet, slot, 120, 32)

        slot.ejectedBy = UIUtil.CreateText(slot, '', 16, UIUtil.fixedFont)
        slot.ejectedBy:SetColor('FFbadbdb')
        LayoutHelpers.AtRightTopIn(slot.ejectedBy, slot, 5, 4)

        slot.eject = UIUtil.CreateButtonStd(slot, '/widgets02/small', "<LOC UI_Disco0005>Eject From Game", 12, 0)
        slot.eject.label:SetFont(UIUtil.bodyFont, 12)

        LayoutHelpers.AtLeftTopIn(slot.eject, slot, 248, 24)

        slot.eject.OnClick = function(self, modifiers) EjectSessionClient(slot.index) end
        slot.eject:Disable()    -- disable all temporarily so they can't be misclicked, then unlock a few seconds later
    end

    local canEject = false

    parent.OnFrame = function(self, delta)

        self.time = self.time + delta

        if self.time > 15 then
            canEject = true
        end
    end

    parent.Width:Set(function() return slots[1].Width() - LayoutHelpers.ScaleNumber(100) end)
    parent.Height:Set(function() return slots[1].Height() * table.getsize(slots) - LayoutHelpers.ScaleNumber(34) end)

    LayoutHelpers.AtCenterIn(parent, GetFrame(0))

    function parent.Update(self, clients)

        for index, client in clients do

            local slot = slots[index]

            if client.connected then

                if client.quiet < 5000 then

                    if canEject then
                        slot.eject:Disable()
                    end

                    slot.ping:SetText(LOCF("%s: %d", "<LOC UI_Disco0003>Ping (ms)", client.ping))
                    slot.quiet:SetText('')
                    slot.ping:SetColor('FFbadbdb')
                    slot.quiet:SetColor('FFbadbdb')

                else

                    if canEject then
                        slot.eject:Enable()
                    end

                    slot.ping:SetText(LOCF("%s: ---", "<LOC UI_Disco0003>Ping (ms)"))
                    slot.ping:SetColor('FFe24f2d')
                    slot.quiet:SetColor('FFe24f2d')

                    local min = client.quiet / (1000 * 60)
                    local sec = math.mod(client.quiet / 1000, 60)

                    slot.quiet:SetText(LOCF("%s: %d:%02d", "<LOC UI_Disco0004>Quiet (m:s)",min,sec))
                end

            else
                slot.ping:SetText('')
                slot.quiet:SetText('')
            end

            local ejectedBy = ''

            for k, v in client.ejectedBy do
                if ejectedBy != '' then
                    ejectedBy = ejectedBy .. ', ' .. tostring(v)
                else
                    ejectedBy = LOC('<LOC UI_Disco0006>Ejected by')..': '..tostring(v)
                end
            end

            slot.ejectedBy:SetText(ejectedBy)

            if client.connected and not client['local'] then
                if slot.eject:IsHidden() then slot.eject:Show() end
            else
                if not slot.eject:IsHidden() then slot.eject:Hide() end
            end
        end
    end
end


-- this function gets run on EVERY tick
function Update()

    local needDialog = false

    local clients = GetSessionClients()

    local stillin = {}
    local counter = 0

    for index,client in clients do

        if client.connected then
            stillin[counter+1] = index
            counter = counter + 1
        end
    end

    for index,client in clients do

        if client.quiet > 5000 then
            needDialog = true
        end

        if client.connected then
            if not tequal(client.ejectedBy, {}) then
                needDialog = true
            end
        else
            if not tequal(tsorted(client.ejectedBy), stillin) then
                needDialog = true
            end
        end
    end

    if needDialog then

        if not parent then
            CreateDialog(clients)
        end

        parent:Update(clients)
    else
        if parent then DestroyDialog() end
    end

end


function CreateBorder(parent)
    local tbl = {}
    tbl.tl = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_ul.dds'))
    tbl.tm = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_horz_um.dds'))
    tbl.tr = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_ur.dds'))
    tbl.l = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_vert_l.dds'))
    tbl.r = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_vert_r.dds'))
    tbl.bl = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_ll.dds'))
    tbl.bm = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_lm.dds'))
    tbl.br = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_lr.dds'))

    tbl.tl.Bottom:Set(parent.Top)
    tbl.tl.Right:Set(parent.Left)

    tbl.tr.Bottom:Set(parent.Top)
    tbl.tr.Left:Set(parent.Right)

    tbl.tm.Bottom:Set(parent.Top)
    tbl.tm.Right:Set(parent.Right)
    tbl.tm.Left:Set(parent.Left)

    tbl.l.Bottom:Set(parent.Bottom)
    tbl.l.Top:Set(parent.Top)
    tbl.l.Right:Set(parent.Left)

    tbl.r.Bottom:Set(parent.Bottom)
    tbl.r.Top:Set(parent.Top)
    tbl.r.Left:Set(parent.Right)

    tbl.bl.Top:Set(parent.Bottom)
    tbl.bl.Right:Set(parent.Left)

    tbl.br.Top:Set(parent.Bottom)
    tbl.br.Left:Set(parent.Right)

    tbl.bm.Top:Set(parent.Bottom)
    tbl.bm.Right:Set(parent.Right)
    tbl.bm.Left:Set(parent.Left)

    tbl.tl.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.tm.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.tr.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.l.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.r.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.bl.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.bm.Depth:Set(function() return parent.Depth() - 1 end)
    tbl.br.Depth:Set(function() return parent.Depth() - 1 end)

    return tbl
end