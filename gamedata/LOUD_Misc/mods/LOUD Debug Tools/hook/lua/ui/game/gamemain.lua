-- Author: Rat Circus
-- Brief: Creates the LOUD AI Debug Menu.

do

	local Group = import('/lua/maui/group.lua').Group
	local Prefs = import('/lua/user/prefs.lua')
    
    __debugprefs = Prefs.GetFromCurrentProfile('loud_ai_debug') or {}
    
	local DebugPrefs = __debugprefs  
    
	if not DebugPrefs.intel then DebugPrefs.intel = {} end

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
        'NukeDialog',
		'DisplayIntelPoints',
	}

	local SWITCHES_RIGHT = {
		"* BASES & DISTRESS ALERTS *",
		'DisplayBaseNames',
		'BaseMonitorDialog',
		'DisplayBaseMonitors',
		'BaseDistressResponseDialog',
		'DeadBaseMonitorDialog',
		'DisplayPingAlerts',
		"* PLATOONS *",
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
		Commander = '90ffffff', -- White
		Land = '9000ff00', -- Green
		Air = 'ff76bdff',
		Naval = 'ff0060ff', -- Dark Blue
		AntiAir = 'e0ff0000', -- Bright Red
		Economy = '90ff7000', -- Gold
		StructuresNotMex = '90ffff00', -- Yellow
        
		-- Artillery = '60ffff00', --Yellow        
		-- Experimental = 'ff00fec3', -- Cyan
		-- AntiSurface = 'ffaf000ff', -- Pink
		-- AntiSub = 'ff0000ff', -- Light Blue        
	}

	-- ThreatType = { ARGB value }
	local THREAT_COLOR_2 = {
		Air = 'ff76bdff',
		Land = '9000ff00', -- Purple
		Naval = 'ff0060ff', -- Blueish (again)
		Commander = '90ffffff', -- Cyan
		Economy = '90ff7000', -- White
		StructuresNotMex = '90ffff00', -- Green
		AntiAir = 'e0ff0000', -- Red
        
		-- Artillery = '60ffff00', -- Yellow        
		-- Experimental = 'ff00fec3', -- Red
	}

	local INTEL_CHECKS = {
		'Air',
		'Land',
		'Naval',
		-- 'Experimental',
		'Commander',
		'Economy',
		'StructuresNotMex',
		-- 'Artillery',
        'AntiAir',
       	-- 'AntiSurface',
       	-- 'AntiSub',
	}

	local INTEL_CHECKS_COLORS = {
		'ff76bdff',
		'9000ff00',
		'ff0060ff',
		-- 'ff00fec3',
		'90ffffff',
		'90ff7000',
		'90ffff00',
		-- '60ffff00',
		'e0ff0000',
		-- 'ffaf00ff',
		-- 'ff0000ff'
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
				
				DebugPrefs[SWITCHES[index]] = checked
                
				Prefs.SetToCurrentProfile('loud_ai_debug', DebugPrefs)
			end

			SimCallback({
				Func = 'SetAIDebug',
				Args = { Switch = SWITCHES[index], Active = DebugPrefs[SWITCHES[index]] or false }
			})

			return grp
		end
		
		listSwitches[1] = CreateSwitchToggleGroup(1, SWITCHES_LEFT)
		LayoutHelpers.AtLeftTopIn(listSwitches[1], container, 4, 4)

		local i = 2
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
				
				DebugPrefs.intel[self:GetParent().key] = checked
                
				Prefs.SetToCurrentProfile('loud_ai_debug', DebugPrefs)
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
