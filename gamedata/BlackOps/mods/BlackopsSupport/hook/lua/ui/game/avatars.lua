do
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
local Group = import('/lua/maui/group.lua').Group
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua').Tooltips
local Prefs = import('/lua/user/prefs.lua')
local Factions = import('/lua/factions.lua').Factions

controls = {
    avatars = {},
    idleEngineers = false,
    idleFactories = false,
}

local recievingBeatUpdate = false
local currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction
local expandedCheck = false
local currentIndex = 1

local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')

function CreateAvatar(unit)
    local bg = Bitmap(controls.avatarGroup, UIUtil.SkinnableFile('/game/avatar/avatar_bmp.dds'))
    bg.ID = unit:GetEntityId()
    bg.Blueprint = unit:GetBlueprint()
    bg.tooltipKey = 'avatar_Avatar_ACU'
    
    bg.units = {unit}
    
    bg.icon = Bitmap(bg)
    LayoutHelpers.AtLeftTopIn(bg.icon, bg, 5, 5)
    local path = '/textures/ui/common/icons/units/'..bg.Blueprint.BlueprintId..'_icon.dds'
	--####################
	--Exavier Code Block +
	--####################
	local EXunitID = unit:GetBlueprint().BlueprintId
	if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
		-- Check manually assigned overwrite table
		local expath = EXunitID..'_icon.dds'
		bg.icon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath)
	elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
		-- Check modded icon hun table
		local expath = EXunitID..'_icon.dds'
		bg.icon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID) .. expath)
	else
		-- Check default GPG directories
		if DiskGetFileInfo(path) then
			bg.icon:SetTexture(path)
		else 
			-- Sets placeholder because no other icon was found
			bg.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
			if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
				-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
				WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
				BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
			end
		end
	end
	--####################
	--Exavier Code Block -
	--####################
    bg.icon.Height:Set(44)
    bg.icon.Width:Set(44)
    bg.icon:DisableHitTest()
    
    bg.healthbar = StatusBar(bg, 0, 1, false, false,
        UIUtil.SkinnableFile('/game/avatar/health-bar-back_bmp.dds'),
        UIUtil.SkinnableFile('/game/avatar/health-bar-green.dds'),
        true, "avatar RO Health Status Bar")
    bg.healthbar.Left:Set(function() return bg.Left() + 8 end)
    bg.healthbar.Right:Set(function() return bg.Right() - 14 end)
    bg.healthbar.Bottom:Set(function() return bg.Bottom() - 5 end)
    bg.healthbar.Top:Set(function() return bg.healthbar.Bottom() - 10 end)
    bg.healthbar.Height:Set(function() return bg.healthbar.Bottom() - bg.healthbar.Top() end)
    bg.healthbar.Width:Set(function() return bg.healthbar.Right() - bg.healthbar.Left() end)
    bg.healthbar:DisableHitTest(true)
    
    
    bg.curIndex = 1
    bg.HandleEvent = ClickFunc
    bg.idleAnnounced = true
    bg.lastAlert = 0
    
    bg.Update = function(self)
        if bg.units[1]:IsIdle() and not bg.idle then
            if not bg.idle then
                bg.idle = Bitmap(bg.icon, UIUtil.SkinnableFile('/game/idle_mini_icon/idle_icon.dds'))
                LayoutHelpers.AtLeftTopIn(bg.idle, bg.icon, -2, -2)
                bg.idle:DisableHitTest()
                bg.idle.cycles = 0
                bg.idle.dir = 1
                bg.idle:SetNeedsFrameUpdate(true)
                bg.idle:SetAlpha(0)
                bg.idle.OnFrame = function(self, delta)
                    local newAlpha = self:GetAlpha() + (delta * 3 * self.dir)
                    if newAlpha > 1 then
                        newAlpha = 1
                        self.dir = -1
                        self.cycles = self.cycles + 1
                        if self.cycles >= 5 then
                            self:SetNeedsFrameUpdate(false)
                        end
                    elseif newAlpha < 0 then
                        newAlpha = 0
                        self.dir = 1
                    end
                    self:SetAlpha(newAlpha)
                end
            end
        elseif not bg.units[1]:IsIdle() then
            if bg.idle then
                bg.idle:Destroy()
                bg.idle = false
            end
        end
        local tempPrevHealth = bg.healthbar._value()
        local tempHealth = self.units[1]:GetHealth()
        bg.healthbar:SetRange(0, self.units[1]:GetMaxHealth())
        bg.healthbar:SetValue(tempHealth)
        if tempPrevHealth != tempHealth then
            SetHealthbarColor(bg.healthbar, self.units[1]:GetHealth() / self.units[1]:GetMaxHealth())
        end
    end
    
    return bg
end

end