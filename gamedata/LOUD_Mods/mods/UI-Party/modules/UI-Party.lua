local settings = import('/mods/UI-Party/modules/settings.lua')
local UnitWatcher = import('/mods/UI-Party/modules/unitWatcher.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
test = {}

function Init()
	InitKeys()

	_G.UIPLOG = function(a)
		LOG("UIP: "..a)
	end

	UnitWatcher.Init()

	GameMain.AddBeatFunction(OnBeat)

	-- if GetSetting("playerColors") then
	-- 	TeamColorMode(true)
	-- end

end

local wasWatching = false
local tick = 0
function OnBeat()
	if (Enabled) then
		tick = tick + 1
		if tick == 10 then
			local isWatching = GetSetting("watchUnits")
			if isWatching then
				UnitWatcher.OnBeat()
			end
			if wasWatching and not isWatching then
				UnitWatcher.Shutdown()
			end
			wasWatching = isWatching

			import('/mods/UI-Party/modules/test.lua')
			tick = 0
		end
	end
end

function PlayErrorSound()
    local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
    PlaySound(sound)
end

function CreateUI(isReplay)
	import('/mods/UI-Party/modules/settings.lua').init()
	import('/mods/UI-Party/modules/ui.lua').init()
	import('/mods/UI-Party/modules/econtrol.lua').setEnabled(Enabled() and GetSetting("showEcontrol"))
end

function OnFirstUpdate()
end

function ToggleEnabled()
	GetSettings().global.modEnabled = not GetSettings().global.modEnabled
end

function InitKeys()
	local KeyMapper = import('/lua/keymap/keymapper.lua')
	local keyDescriptions = import('/lua/keymap/keydescriptions.lua').keyDescriptions
	local order = 1
	local cat = "uip"

	KeyMapper.SetUserKeyAction('uip_disable', {action = "UI_Lua import('/mods/UI-Party/modules/UI-Party.lua').ToggleEnabled()", category = cat, order = order,})
	keyDescriptions['uip_disable'] = 'UIP: Disable UI Party'

	for i = 2, 10 do
		order = order + 1
		-- KeyMapper.SetUserKeyAction('Split selection into '..i..' groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups("..i..")", category = cat, order = order,})
		KeyMapper.SetUserKeyAction('uip_split_sel_to_'..i..'_grps', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups("..i..")", category = cat, order = order,})
		keyDescriptions['uip_split_sel_to_'..i..'_grps'] = 'UIP: Split Selection into '..i..' Groups'
	end

	for i = 1, 10 do
		order = order + 1
		KeyMapper.SetUserKeyAction('uip_sel_split_grp_'..i, {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup("..i..")", category = cat, order = order,})
		keyDescriptions['uip_sel_split_grp_'..i] = 'UIP: Select Split Group '..i
	end

	order = order + 1
	KeyMapper.SetUserKeyAction('uip_sel_next_split_grp', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	keyDescriptions['uip_sel_next_split_grp'] = 'UIP: Select Next Split Group'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_sel_prev_split_grp', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	keyDescriptions['uip_sel_prev_split_grp'] = 'UIP: Select Previous Split Group'
	order = order + 1

	KeyMapper.SetUserKeyAction('uip_sel_next_split_grp_shift', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	keyDescriptions['uip_sel_prev_split_grp'] = 'UIP: Select Previous Split Group (Shift)'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_sel_prev_split_grp_shift', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	keyDescriptions['uip_sel_prev_split_grp'] = 'UIP: Select Previous Split Group (Shift)'
	order = order + 1

	KeyMapper.SetUserKeyAction('uip_resel_split_units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectSplitUnits()", category = cat, order = order,})
	keyDescriptions['uip_resel_split_units'] = 'UIP: Reselect Split Units'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_resel_ordered_split_units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectOrderedSplitUnits()", category = cat, order = order,})
	keyDescriptions['uip_resel_ordered_split_units'] = 'UIP: Reselect Ordered Split Units'
	order = order + 1

	KeyMapper.SetUserKeyAction('uip_clear_q_except_cur_prod', {action = "UI_Lua import('/lua/ui/game/construction.lua').StopAllExceptCurrentProduction()", category = cat, order = order,})
	keyDescriptions['uip_clear_q_except_cur_prod'] = 'UIP: Clear Queue Except For Current Production'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_undo_last_q_order', {action = "UI_Lua import('/lua/ui/game/construction.lua').UndoLastQueueOrder()", category = cat, order = order,})
	keyDescriptions['uip_undo_last_q_order'] = 'UIP: Undo Last Queued Order'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_undo_last_q_order_shift', {action = "UI_Lua import('/lua/ui/game/construction.lua').UndoLastQueueOrder()", category = cat, order = order,})
	keyDescriptions['uip_undo_last_q_order_shift'] = 'UIP: Undo Last Queued Order (Shift)'
	order = order + 1

	KeyMapper.SetUserKeyAction('uip_select_similar_onscreen_units', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectSimilarOnscreenUnits()", category = cat, order = order,})
	keyDescriptions['uip_select_similar_onscreen_units'] = 'UIP: Select Similar Onscreen Units'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_toggle_unit_lock', {action = "UI_Lua import('/mods/UI-Party/modules/unitlock.lua').ToggleSelectedUnitsLock()", category = cat, order = order,})
	keyDescriptions['uip_toggle_unit_lock'] = 'UIP: Toggle Unit Lock'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_sel_all_locked', {action = "UI_Lua import('/mods/UI-Party/modules/unitlock.lua').SelectAllLockedUnits()", category = cat, order = order,})
	keyDescriptions['uip_sel_all_locked'] = 'UIP: Select All Locked'
	order = order + 1
	--KeyMapper.SetUserKeyAction('Select onscreen directfire land units', {action = "UI_Lua import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT')", category = cat, order = order,})
	KeyMapper.SetUserKeyAction('uip_sel_onscreen_directfire_land', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectOnScreenDirectFireLandUnits()", category = cat, order = order,})
	keyDescriptions['uip_sel_onscreen_directfire_land'] = 'UIP: Select All Onscreen Directfire Land Units'
	order = order + 1
	--KeyMapper.SetUserKeyAction('Select onscreen support land units', {action = "UI_Lua import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND -DIRECTFIRE -ENGINEER')", category = cat, order = order,})
	KeyMapper.SetUserKeyAction('uip_sel_onscreen_support_land', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectOnScreenSupportLandUnits()", category = cat, order = order,})
	keyDescriptions['uip_sel_onscreen_support_land'] = 'UIP: Select All Onscreen Support Land Units'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_split_land_by_role', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextLandUnitsGroupByRole()", category = cat, order = order,})
	keyDescriptions['uip_split_land_by_role'] = 'UIP: Split Land Units by Role'
	order = order + 1
	KeyMapper.SetUserKeyAction('uip_quick_switch_observer_mode', {action = "UI_Lua import('/mods/UI-Party/modules/observer.lua').QuickSwitch()", category = cat, order = order,})
	keyDescriptions['uip_quick_switch_observer_mode'] = 'UIP: Quick Switch Observer Mode'
	order = order + 1
end

function GetSettings()
	return settings.getPreferences()
end

function GetSetting(key)
	local val = GetSettings().global[key]
	if val == nil then
		UIPLOG("Setting not found: " .. key)
		UIPLOG("Settings are: " .. repr(GetSettings()))
	end
	return  val
end

function Enabled()
	return GetSettings().global.modEnabled
end
