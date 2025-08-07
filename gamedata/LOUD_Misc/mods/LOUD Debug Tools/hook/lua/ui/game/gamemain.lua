-- Author: Rat Circus
-- Brief: Creates the LOUD AI Debug Menu.

do
    --LOG("*AI DEBUG LOADING AI DEBUG")
    
	local Group = import('/lua/maui/group.lua').Group
	local Prefs = import('/lua/user/prefs.lua')
    
    __debugprefs = Prefs.GetFromCurrentProfile('loud_ai_debug') or {}
    
	local DebugPrefs = __debugprefs
    
	if not DebugPrefs.intel then DebugPrefs.intel = {} end

	local OrigCreateUI = CreateUI

	local SWITCHES_LEFT = {
		"* ENGINEER & FACTORY DEBUGS *",
		'NameEngineers',
		'EngineerDialog',
		'DisplayFactoryBuilds',

		"* ENGI, FAC, STRUCT UPGRADES *",
		'ACUEnhanceDialog',
		'SCUEnhanceDialog',
		'FactoryEnhanceDialog',
		'StructureUpgradeDialog',

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
        'DisplayTransportPaths',
		'PathFindingDialog',
	}

	local SWITCHES_RIGHT = {
		"* INTEL & THREAT DEBUGS *",
		'IntelDialog',
		'DisplayIntelPoints',

		"* ATTACK PLANS, STRENGTH RATIOS *",
		'DisplayAttackPlans',
		'AttackPlanDialog',
		'ReportRatios',

		"* BEHAVIOR DIALOG *",
        'AirForceDialog',
        'AmphibForceDialog',
        'GuardPointDialog',
        'LandForceDialog',
        'NavalForceDialog',
        'NavalBombardDialog',
        'NukeDialog',

        "* HARDCORE NERD DATA *",
		'BuffDialog',
		'InstanceDialog',
		'PriorityDialog',
		'ProjectileDialog',
        'ProjectileTrackingDialog',
		'ShieldDialog',
        'UnitDialog',
		'WeaponDialog',
        'WeaponStateDialog',
	}

	__INTEL_CHECKS = {
		'Air',
        'AntiAir',
		'Commander',
		'Economy',
		'Land',
		'Naval',
		'StructuresNotMex',

		-- 'Artillery',
       	-- 'AntiSurface',
       	-- 'AntiSub',
		-- 'Experimental',
	}
    
	__INTEL_CHECKS_COLORS = {
		'ff76bdff',
		'e0ff0000',
		'90ffffff',
		'90ff7000',
		'9000ff00',
		'ff0060ff',
		'90ffff00',

		-- 'ff00fec3',
		-- '60ffff00',
		-- 'ffaf00ff',
		-- 'ff0000ff'
	}
    
	function CreateUI(isReplay)

		OrigCreateUI(isReplay)

		local bg = Bitmap(GetFrame(0))
		bg.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
		LayoutHelpers.AtCenterIn(bg, GetFrame(0))
		LayoutHelpers.SetDimensions(bg, 830, 560)
		bg:SetSolidColor('FF111111')

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
        -- this function creates the switch - and the function which fires when the switch is changed
		local function CreateSwitchToggleGroup(index, SWITCHES)
        
			local grp = Group(container)
			LayoutHelpers.SetDimensions(grp, 255, 18)
			
			local label = UIUtil.CreateText(grp, SWITCHES[index], 12, UIUtil.bodyFont)
            
			LayoutHelpers.AtLeftIn(label, grp)
			LayoutHelpers.AtVerticalCenterIn(label, grp)
			label:DisableHitTest()
			
			-- Just a header
			if string.find(SWITCHES[index], "*") then
				LayoutHelpers.SetHeight(grp, 28)
				return grp
			end
			
			local check = UIUtil.CreateCheckboxStd(grp, '/dialogs/check-box_btn/radio')

            -- set the switch to the status that comes from the prefs
            check:SetCheck(DebugPrefs[SWITCHES[index]] or false)

			LayoutHelpers.AtRightIn(check, grp)
			LayoutHelpers.AtVerticalCenterIn(check, grp)

			check.OnCheck = function(self, checked)
            
                if not isReplay then

                    SimCallback( { Func = 'SetAIDebug', Args = { Switch = SWITCHES[index], Active = checked } } )
				
                    DebugPrefs[SWITCHES[index]] = checked
                
                    Prefs.SetToCurrentProfile('loud_ai_debug', DebugPrefs)
                    
                else
                    LOG("SETAIDEBUG Cannot change option during replay")
                end
			end

			SimCallback( { Func = 'SetAIDebug',	Args = { Switch = SWITCHES[index], Active = DebugPrefs[SWITCHES[index]] or false } } )

			return grp
		end

		
		listSwitches[1] = CreateSwitchToggleGroup(1, SWITCHES_LEFT)
		LayoutHelpers.AtLeftTopIn(listSwitches[1], container, 4, 4)

		local i = 2

        --LOG("*AI DEBUG Populating LEFT SWITCHES "..repr(SWITCHES_LEFT))
        
		for j = 2, table.getn(SWITCHES_LEFT) do

			listSwitches[i] = CreateSwitchToggleGroup(j, SWITCHES_LEFT)
			LayoutHelpers.Below(listSwitches[i], listSwitches[i - 1])
			i = i + 1
		end


		listSwitches[i] = CreateSwitchToggleGroup( 1, SWITCHES_RIGHT)
		LayoutHelpers.CenteredRightOf(listSwitches[i], listSwitches[1], 35)

		i = i + 1

        -- Create intel header next to first header of right-side switches
        -- while it's easy to do so
		listIntel[1] = Group(container)
		LayoutHelpers.SetDimensions(listIntel[1], 220, 18)

		local intelHeaderLabel1 = UIUtil.CreateText(listIntel[1], "* TOGGLE INTEL THREAT COLORS *", 12, UIUtil.bodyFont)
        
		LayoutHelpers.AtLeftIn(intelHeaderLabel1, listIntel[1])
		LayoutHelpers.AtVerticalCenterIn(intelHeaderLabel1, listIntel[1])
		intelHeaderLabel1:DisableHitTest()

		LayoutHelpers.CenteredRightOf(listIntel[1], listSwitches[i - 1], 35)

        -- Populate remainder of right-side switches

        --LOG("*AI DEBUG Populating RIGHT SWITCHES "..repr(SWITCHES_RIGHT))
        
		for j = 2, table.getn(SWITCHES_RIGHT) do
			listSwitches[i] = CreateSwitchToggleGroup(j, SWITCHES_RIGHT)
			LayoutHelpers.Below(listSwitches[i], listSwitches[i - 1])
			i = i + 1
		end

        -- Intel blitting settings

		local k = 2

		for idx, key in __INTEL_CHECKS do
        
			listIntel[k] = Group(container)
			LayoutHelpers.SetDimensions(listIntel[k], 220, 18)

			listIntel[k].color = Bitmap(listIntel[k])
			LayoutHelpers.SetDimensions(listIntel[k].color, 12, 12)

			LayoutHelpers.Below(listIntel[k], listIntel[k - 1])

			listIntel[k].key = key
            listIntel[k].index = idx

			local label = UIUtil.CreateText(listIntel[k], key, 12, UIUtil.bodyFont)
            
			LayoutHelpers.AtLeftIn(label, listIntel[k])
			LayoutHelpers.AtVerticalCenterIn(label, listIntel[k])
			label:DisableHitTest()

			local check = UIUtil.CreateCheckboxStd(listIntel[k], '/dialogs/check-box_btn/radio')
            
            check:SetCheck( DebugPrefs.intel[listIntel[k].key] or false )
    
			LayoutHelpers.CenteredLeftOf(listIntel[k].color, check, 64)

			listIntel[k].color:SetSolidColor(__INTEL_CHECKS_COLORS[idx])
			listIntel[k].color:DisableHitTest()
            listIntel[k].color:SetAlpha(1)
        
			LayoutHelpers.AtRightIn(check, listIntel[k])
			LayoutHelpers.AtVerticalCenterIn(check, listIntel[k])
            
			check.OnCheck = function(self, checked)

                SimCallback( { Func = 'SetAIDebug', Args = { ThreatType = self:GetParent().key, Active = checked, Color = __INTEL_CHECKS_COLORS[self:GetParent().index] } } )
				
                DebugPrefs.intel[self:GetParent().key] = checked
                
                Prefs.SetToCurrentProfile('loud_ai_debug', DebugPrefs)

			end

            SimCallback( { Func = 'SetAIDebug', Args = { ThreatType = key, Active = DebugPrefs.intel[key] or false, Color = __INTEL_CHECKS_COLORS[idx] } } )

			k = k + 1
		end
		
        -- Close button for dialog itself
		
		local closeBtn = UIUtil.CreateButtonStd( bg, '/lobby/lan-game-lobby/smalltoggle', "Close", 12, 2, 0,	"UI_Menu_MouseDown", "UI_Menu_Rollover")

		LayoutHelpers.AtRightTopIn(closeBtn, bg)
        
		closeBtn.OnClick = function(self, modifiers)
			bg:Hide()
		end

        --LOG("*AI DEBUG listSwitches are "..repr(listSwitches) )        
        
		bg:Hide()

		local globalToggle = UIUtil.CreateButtonStd( GetFrame(0), '/widgets/toggle', "AI Debug Menu", 12, 2, 0, "UI_Menu_MouseDown", "UI_Menu_Rollover")

		LayoutHelpers.AtHorizontalCenterIn(globalToggle, GetFrame(0), 160)
		LayoutHelpers.AtTopIn(globalToggle, GetFrame(0), 8)

		globalToggle.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)

		globalToggle.OnClick = function(self, modifiers)
        
            --LOG("*AI DEBUG Debugprefs are "..repr(DebugPrefs))
        
			if bg:IsHidden() then
				bg:Show()
			else
				bg:Hide()
			end
            
		end
		
	end

end
