local UIUtil = import('/lua/ui/uiutil.lua')

local a, b = pcall(function()
	local CommonUnits = import('/mods/CommonModTools/units.lua')
end)

if a == false then
	LOG("Crashed. UI Party requires another UI mod to work: Common Mod Tools v1")

	UIUtil.CreateText(GetFrame(0), "Crashed. UI Party requires another ui mod to work: Common Mod Tools v1", 20, UIUtil.bodyFont)
	return 0
end

local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local UnitSplit = import('/mods/UI-Party/modules/UnitSplit.lua')
local UnitLock = import('/mods/ui-party/modules/unitlock.lua')

UIP.Init()

local oldCreateUI = CreateUI
function CreateUI(isReplay)

	oldCreateUI(isReplay)

	UIP.CreateUI(isReplay)

	if UIP.Enabled() then

		ForkThread(function()

			local tabs = import('/lua/ui/game/tabs.lua')
			local mf = import('/lua/ui/game/multifunction.lua')

			if UIP.GetSetting("moveMainMenuToRight") then
				tabs.controls.parent.Left:Set(function() return GetFrame(0).Width() - LayoutHelpers.ScaleNumber(600) end)
			end

			WaitSeconds(4)

			if UIP.GetSetting("hideMenusOnStart") then
				tabs.ToggleTabDisplay(false)
				mf.ToggleMFDPanel(false)
			end

		end)
	end
end

local oldOnFirstUpdate = OnFirstUpdate
function OnFirstUpdate()

	if not UIP.Enabled() then
		oldOnFirstUpdate()
		return
	end

	if UIP.GetSetting("useAlternativeStartSequence") then
		AlternateStartSequence()
	else

		if UIP.GetSetting("zoomPopOverride") then
			ForkThread(function()
				import('/lua/GAZ_UI/modules/zoompopper.lua').Init()
				local cam = GetCamera('WorldCamera')
				cam:Reset()
			end)
		end

		oldOnFirstUpdate()
	end

	local prefs = import('/mods/UI-Party/modules/settings.lua').getPreferences()
	if prefs.global['playerColors'] then
		TeamColorMode(true)
	end

	UIP.OnFirstUpdate()
end

function AlternateStartSequence()

	-- Normal stuff
	import('/lua/hotbuild/hotbuild.lua').init()
	EnableWorldSounds()
	local avatars = GetArmyAvatars()
	if avatars and avatars[1]:IsInCategory("COMMAND") then
		local armiesInfo = GetArmiesTable()
		local focusArmy = armiesInfo.focusArmy
		local playerName = armiesInfo.armiesTable[focusArmy].nickname
		avatars[1]:SetCustomName(playerName)
	end
	import('/lua/UserMusic.lua').StartPeaceMusic()
	if not import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
		import('/lua/ui/game/score.lua').CreateScoreUI()
	end

	PlaySound( Sound { Bank='AmbientTest', Cue='AMB_Planet_Rumble_zoom'} )

	ForkThread(function()

		-- earlier unlock input
		if not IsNISMode() then
			import('/lua/ui/game/worldview.lua').UnlockInput()
		end

		-- split screen
		if UIP.GetSetting("startSplitScreen") then
			local Borders = import('/lua/ui/game/borders.lua')
			Borders.SplitMapGroup(true, true)
			import('/lua/ui/game/worldview.lua').Expand() -- required to initialize something else there is a crash
		end

		-- required else just zoom into middle all the time
		if UIP.GetSetting("zoomPopOverride") then
			WaitSeconds(0)
			import('/lua/GAZ_UI/modules/zoompopper.lua').Init()
		end

		-- 1nd cam zoom out
		local cam1 = GetCamera("WorldCamera")
		cam1:SetZoom(cam1:GetMaxZoom(),0)
		cam1:RevertRotation() -- UIZoomTo does something funny

		-- 2nd cam zoom out
		if UIP.GetSetting("startSplitScreen") then
			local cam2 = GetCamera("WorldCamera2")
			cam2:SetZoom(cam2:GetMaxZoom(),0)
			cam2:RevertRotation() -- UIZoomTo does something funny
		end

		-- need to wait before ui can hide, so slip in artistic camera transition
		WaitSeconds(1)

		if not GetReplayState() then
			-- left cam glides towards acu
			UIZoomTo(avatars, 1.2)

			WaitSeconds(1)
			cam1:SetZoom(import('/lua/GAZ_UI/modules/zoompopper.lua').GetPopLevel(),0.1) -- different zoom level to usual, not as close
			WaitSeconds(0)
			cam1:RevertRotation() -- UIZoomTo does something funny
		end

		-- select acu & start placing fac
		-- RAT: This building table doesn't exist in our hotbuild
		-- WaitSeconds(0)
		-- AddSelectUnits(avatars)
		-- import('/lua/hotbuild/hotbuild.lua').buildAction('Builders')

	end)

	-- normal stuff
	if Prefs.GetOption('skin_change_on_start') ~= 'no' then
		local focusarmy = GetFocusArmy()
		local armyInfo = GetArmiesTable()
		if focusarmy >= 1 then
			local factions = import('/lua/factions.lua').Factions
			if factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin then
				UIUtil.SetCurrentSkin(factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin)
			end
		end
	end

end

local oldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
	--if not SelectHelper.IsAutoSelection() then
		UnitSplit.SelectionChanged()

		local selectionChanged = UnitLock.OnSelectionChanged(oldSelection, newSelection, added, removed)
		if not selectionChanged then
			oldOnSelectionChanged(oldSelection, newSelection, added, removed)
		end
	--end
end

local oldOnQueueChanged = OnQueueChanged
function OnQueueChanged(newQueue)
    oldOnQueueChanged(newQueue)
end
