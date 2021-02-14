-- Author: Rat Circus
-- Brief: Creates the LOUD AI Debug Menu.

do

	local Group = import('/lua/maui/group.lua').Group

	local OrigCreateUI = CreateUI

	local SWITCHES_LEFT = {
		"* ENGINEER and FACTORY DEBUGS *",
		'NameEngineers',
		'EngineerDialog',
		'DisplayFactoryBuilds',
		"* ENGI, FAC, STRUCT UPGRADES *",
		'ACUEnhanceDialog',
		'SCUEnhanceDialog',
		'FactoryEnhanceDialog',
		'StructureUpgradeDialog',
		"* ATTACK PLANS, STRENGTH RATIOS *",
		'DisplayAttackPlans',
		'AttackPlanDialog',
		'ReportRatios',
		"* INTEL/THREAT *",
		'IntelDialog',
		'DisplayIntelPoints',
	}

	local SWITCHES_RIGHT = {
		"* BASES/BASE THREAT *",
		'DisplayBaseNames',
		'BaseMonitorDialog',
		'DisplayBaseMonitors',
		'BaseDistressResponseDialog',
		'DeadBaseMonitorDialog',
		'DisplayPingAlerts',
		"* BASE/PLATOON FORMATION, BEHAVIOURS *",
		'PlatoonDialog',
		'DisplayPlatoonMembership',
		'DisplayPlatoonPlans',
		'DistressResponseDialog',
		'PlatoonMergeDialog',
		'TransportDialog',
		'PathFindingDialog',
		"* HARDCORE NERD DATA *",
		'PriorityDialog',
		'InstanceDialog',
		'BuffDialog',
		'ProjectileDialog',
		'ShieldDialog',
		'WeaponDialog',
	}

	-- ThreatType = { ARGB value }
	local THREAT_COLOR = {
		Commander = 'a0ffffff', -- White
		Land = 'ff00ff00', -- Green
		Air = 'ffff0000', -- Red 
		Naval = 'ff00a0ff', -- Dark Blue
		Artillery = 'ffffff00', --Yellow
		AntiAir = 'ffff00ff', -- Bright Red
		AntiSurface = 'ffff00ff', -- Bright Pink
		AntiSub = 'ff0000ff', -- Light Blue
		Economy = '90ff7000', -- Gold
		StructuresNotMex = 'c0ffff00', -- Yellow
		Experimental = 'ff00fec3', -- Cyan
	}

	-- ThreatType = { ARGB value }
	local THREAT_COLOR_2 = {
		Commander = 'ff00ffff', -- Cyan
		Land = 'ffa000ff', -- Purple
		Air = 'a0ff0096', -- Pink
		Naval = 'ff0000a0', -- Blueish (again)
		Artillery = 'fffffc00', -- Yellow
		Economy = 'a0ffffff', -- White
		StructuresNotMex = 'ff00ff00', -- Green
		AntiAir = 'ffff0000', -- Red
		Experimental = 'ffff0000', -- Red
	}

	local INTEL_CHECKS = {
		'Air',
		'Land',
		'Naval',
		'Experimental',
		'Commander',
		'Economy',
		'StructuresNotMex',
		'Artillery',
        'AntiAir',
        'AntiSurface',
        'AntiSub',
	}

	local INTEL_CHECKS_COLORS = {
		'ffff0000',
		'ff00ff00',
		'ff00a0ff',
		'ff00fec3',
		'ffffffff',
		'90ff7000',
		'c0ffff00',
		'ffffff00',
		'ffff00ff',
		'ffff00ff',
		'ff0000ff'
	}

	function CreateUI(isReplay)
		OrigCreateUI(isReplay)

		local bg = Bitmap(GetFrame(0))
		bg.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
		LayoutHelpers.AtCenterIn(bg, GetFrame(0))
		bg.Width:Set(800)
		bg.Height:Set(448)
		bg:SetSolidColor('AA111111')

		local title = UIUtil.CreateText(bg, "LOUD AI Debug Menu", 16, UIUtil.titleFont)
		LayoutHelpers.AtTopIn(title, bg, 4)
		LayoutHelpers.AtHorizontalCenterIn(title, bg)

		local container = Group(bg)
		container.Height:Set(bg.Height())
		container.Width:Set(bg.Width())
		container.Depth:Set(bg.Depth() + 1)
		LayoutHelpers.AtLeftTopIn(container, bg, 2, 20)
		
		local listSwitches = {}
		local listIntel = {}
		
		-- Only for SWITCHES, not for intel colours
		local function CreateSwitchToggleGroup(index, SWITCHES)
			local grp = Group(container)
			grp.Width:Set(256)
			grp.Height:Set(18)
			
			local label = UIUtil.CreateText(grp, SWITCHES[index], 12, UIUtil.bodyFont)
			LayoutHelpers.AtLeftIn(label, grp)
			LayoutHelpers.AtVerticalCenterIn(label, grp)
			label:DisableHitTest()
			
			-- Just a header
			if string.find(SWITCHES[index], "*") then
				grp.Height:Set(24)
				return grp
			end
			
			local check = UIUtil.CreateCheckboxStd(grp, '/dialogs/check-box_btn/radio')
			LayoutHelpers.AtRightIn(check, grp)
			LayoutHelpers.AtVerticalCenterIn(check, grp)
			check.OnCheck = function(self, checked)
				SimCallback({
					Func = 'SetAIDebug', 
					Args = { Switch = SWITCHES[index], Active = checked }
				})
			end
			
			return grp
		end
		
		listSwitches[1] = CreateSwitchToggleGroup(1, SWITCHES_LEFT)
		LayoutHelpers.AtLeftTopIn(listSwitches[1], container, 4, 4)

		i = 2
		for j = 2, table.getn(SWITCHES_LEFT) do
			listSwitches[i] = CreateSwitchToggleGroup(j, SWITCHES_LEFT)
			LayoutHelpers.Below(listSwitches[i], listSwitches[i - 1])
			i = i + 1
		end

		listSwitches[i] = CreateSwitchToggleGroup(i, SWITCHES_RIGHT)
		LayoutHelpers.CenteredRightOf(listSwitches[i], listSwitches[1], 4)
		i = i + 1

-- Create intel header next to first header of right-side switches
-- while it's easy to do so

		listIntel[1] = Group(container)
		listIntel[1].Width:Set(256)
		listIntel[1].Height:Set(24)

		local intelHeaderLabel1 = UIUtil.CreateText(listIntel[1], "* TOGGLE INTEL THREAT COLORS *", 12, UIUtil.bodyFont)
		LayoutHelpers.AtLeftIn(intelHeaderLabel1, listIntel[1])
		LayoutHelpers.AtVerticalCenterIn(intelHeaderLabel1, listIntel[1])
		intelHeaderLabel1:DisableHitTest()

		LayoutHelpers.CenteredRightOf(listIntel[1], listSwitches[i - 1], 16)

-- Populate remainder of right-side switches

		for j = 2, table.getn(SWITCHES_RIGHT) do
			listSwitches[i] = CreateSwitchToggleGroup(j, SWITCHES_RIGHT)
			LayoutHelpers.Below(listSwitches[i], listSwitches[i - 1])
			i = i + 1
		end

-- Intel blitting settings

--[[

		local function CreateIntelToggleGroup(index, table, key, value)
			local grp = Group(container)
			grp.Width:Set(256)
			grp.Height:Set(18)

			local label = UIUtil.CreateText(grp, key, 12, UIUtil.bodyFont)
			LayoutHelpers.AtLeftIn(label, grp)
			LayoutHelpers.AtVerticalCenterIn(label, grp)
			label:DisableHitTest()

			local check = UIUtil.CreateCheckboxStd(grp, '/dialogs/check-box_btn/radio')
			LayoutHelpers.AtRightIn(check, grp)
			LayoutHelpers.AtVerticalCenterIn(check, grp)
			check.OnCheck = function(self, checked)
				SimCallback({
					Func = 'SetAIDebug',
					Args = { 
						ThreatType = key, 
						Table = table, 
						Color = value, 
						Active = checked 
					}
				})
			end

			return grp
		end

		local k = 2

		for key, value in THREAT_COLOR do
			listIntel[k] = CreateIntelToggleGroup(k, 1, key, value)
			LayoutHelpers.Below(listIntel[k], listIntel[k - 1])
			k = k + 1
		end

		listIntel[k] = Group(container)
		listIntel[k].Width:Set(256)
		listIntel[k].Height:Set(24)

		local intelHeaderLabel2 = UIUtil.CreateText(listIntel[k], "* TOGGLE INTEL THREAT COLORS (RAW) *", 12, UIUtil.bodyFont)
		LayoutHelpers.AtLeftIn(intelHeaderLabel2, listIntel[k])
		LayoutHelpers.AtVerticalCenterIn(intelHeaderLabel2, listIntel[k])
		intelHeaderLabel2:DisableHitTest()

		LayoutHelpers.Below(listIntel[k], listIntel[k - 1])

		k = k + 1

		for key, value in THREAT_COLOR_2 do
			listIntel[k] = CreateIntelToggleGroup(k, 2, key, value)
			LayoutHelpers.Below(listIntel[k], listIntel[k - 1])
			k = k + 1
		end

]]

		local k = 2

		for idx, key in INTEL_CHECKS do
			listIntel[k] = Group(container)
			listIntel[k].Width:Set(256)
			listIntel[k].Height:Set(18)
			LayoutHelpers.Below(listIntel[k], listIntel[k - 1])
			listIntel[k].key = key

			local label = UIUtil.CreateText(listIntel[k], key, 12, UIUtil.bodyFont)
			LayoutHelpers.AtLeftIn(label, listIntel[k])
			LayoutHelpers.AtVerticalCenterIn(label, listIntel[k])
			label:DisableHitTest()

			local check = UIUtil.CreateCheckboxStd(listIntel[k], '/dialogs/check-box_btn/radio')
			LayoutHelpers.AtRightIn(check, listIntel[k])
			LayoutHelpers.AtVerticalCenterIn(check, listIntel[k])
			check.OnCheck = function(self, checked)
				if checked then
					self:GetParent().color:SetAlpha(1)
				else
					self:GetParent().color:SetAlpha(0)
				end
				-- self:GetParent().color:SetHidden(not checked)
				SimCallback({
					Func = 'SetAIDebug',
					Args = { 
						ThreatType = self:GetParent().key, 
						Active = checked
					}
				})
			end

			listIntel[k].color = Bitmap(listIntel[k])
			listIntel[k].color.Width:Set(12)
			listIntel[k].color.Height:Set(12)
			LayoutHelpers.CenteredLeftOf(listIntel[k].color, check, 64)
			listIntel[k].color:SetSolidColor(INTEL_CHECKS_COLORS[idx])
			listIntel[k].color:DisableHitTest()
			listIntel[k].color:SetAlpha(0)

			k = k + 1
		end
		
-- Close button for dialog itself
		
		local closeBtn = UIUtil.CreateButtonStd(
			bg, '/lobby/lan-game-lobby/smalltoggle', "Close",
			12, 2, 0,
			"UI_Menu_MouseDown", "UI_Menu_Rollover")
		LayoutHelpers.AtRightTopIn(closeBtn, bg)
		closeBtn.OnClick = function(self, modifiers)
			bg:Hide()
		end
		
-- Hide dialog, create button left of main menu to toggle it
		
		bg:Hide()

		local globalToggle = UIUtil.CreateButtonStd(
			GetFrame(0), '/widgets/toggle', "AI Debug Menu", 
			12, 2, 0, 
			"UI_Menu_MouseDown", "UI_Menu_Rollover")
		LayoutHelpers.AtLeftTopIn(globalToggle, GetFrame(0), 680, 8)
		globalToggle.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
		globalToggle.OnClick = function(self, modifiers)
			if bg:IsHidden() then
				bg:Show()
			else
				bg:Hide()
			end
		end
		
	end -- function

end -- do
