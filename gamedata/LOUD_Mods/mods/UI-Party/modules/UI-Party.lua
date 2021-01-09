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
	local order = 1
	local cat = "UI Party"
	KeyMapper.SetUserKeyAction('Disable UI-Party', {action = "UI_Lua import('/mods/UI-Party/modules/UI-Party.lua').ToggleEnabled()", category = cat, order = order,})

	for i = 2, 10 do
		order = order + 1
		KeyMapper.SetUserKeyAction('Split selection into '..i..' groups', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SplitGroups("..i..")", category = cat, order = order,})
	end

	for i = 1, 10 do
		order = order + 1
		KeyMapper.SetUserKeyAction('Select split group '..i, {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectGroup("..i..")", category = cat, order = order,})
	end

	order = order + 1
	KeyMapper.SetUserKeyAction('Select next split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select prev split group', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select next split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select prev split group (shift)', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectPrevGroup()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Reselect Split Units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectSplitUnits()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Reselect Ordered Split Units', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').ReselectOrderedSplitUnits()", category = cat, order = order,})

	order = order + 1
	KeyMapper.SetUserKeyAction('Clear queue except for current production', {action = "UI_Lua import('/lua/ui/game/construction.lua').StopAllExceptCurrentProduction()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Undo last queue order', {action = "UI_Lua import('/lua/ui/game/construction.lua').UndoLastQueueOrder()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Undo last queue order (shift)', {action = "UI_Lua import('/lua/ui/game/construction.lua').UndoLastQueueOrder()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select similar onscreen units', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectSimilarOnscreenUnits()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Toggle Unit Lock', {action = "UI_Lua import('/mods/UI-Party/modules/unitlock.lua').ToggleSelectedUnitsLock()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Select all locked units', {action = "UI_Lua import('/mods/UI-Party/modules/unitlock.lua').SelectAllLockedUnits()", category = cat, order = order,})
	order = order + 1
	--KeyMapper.SetUserKeyAction('Select onscreen directfire land units', {action = "UI_Lua import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT')", category = cat, order = order,})
	KeyMapper.SetUserKeyAction('Select onscreen directfire land units', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectOnScreenDirectFireLandUnits()", category = cat, order = order,})
	--order = order + 1
	--KeyMapper.SetUserKeyAction('Select onscreen support land units', {action = "UI_Lua import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND -DIRECTFIRE -ENGINEER')", category = cat, order = order,})
	KeyMapper.SetUserKeyAction('Select onscreen support land units', {action = "UI_Lua import('/mods/UI-Party/modules/selection.lua').SelectOnScreenSupportLandUnits()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Split land units by role', {action = "UI_Lua import('/mods/UI-Party/modules/unitsplit.lua').SelectNextLandUnitsGroupByRole()", category = cat, order = order,})
	order = order + 1
	KeyMapper.SetUserKeyAction('Quick switch observer mode', {action = "UI_Lua import('/mods/UI-Party/modules/observer.lua').QuickSwitch()", category = cat, order = order,})
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
