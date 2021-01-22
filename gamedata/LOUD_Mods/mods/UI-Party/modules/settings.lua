local Prefs = import('/lua/user/prefs.lua')

local LINQ = import('/mods/UI-Party/modules/linq.lua')
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local SettingsUi = import('/mods/UI-Party/modules/settingsUi.lua')

local savedPrefs = Prefs.GetFromCurrentProfile("Party-UI Settings")
local settingDescriptions

function getSettingDescriptions()
	return settingDescriptions
end

function init()
	-- Settings
	if not savedPrefs then
		savedPrefs = {}
	end

	settingDescriptions = {
		{ name = "Unit Split", settings = {
			{ key="resetKeys", type="custom", name="Set Unit Split Keybindings",
			  description="Splits the selection into even groups.\r\n\r\nTry just selecting a large amount of units and pressing [V] - you cycle through them. Then [Shift V] to select a few. Select a large group and hit [Ctrl-Alt-3] to divide them into three equal groups. The first group will be selected automatically. [V] Will cycle to the other groups or you can select the second one manually by pressing [Alt-2].\r\n\r\n[Ctrl-Alt-Number] - splits the selection into that many groups\r\n\r\n[Alt-Number] - selects that group\r\n\r\n[V] cycles between groups (hold shift to add to current selection)\r\n\r\n[Ctrl-Shift-Alt-V] = Reselect Split Units, goes back to the original selection before you split\r\n\r\n[Ctrl-Alt-V] = Reselect Ordered Split Units', reselects the part of the original selection that you actually used\r\n\r\nThe 'first' group is the one furtherest or closest to the mouse, depending on if you move the mouse between dragging and splitting.", control = SettingsUi.CreateResetKeysControl },
		}},
		{ name = "Zoom Pop", settings = {
			{ key="zoomPopOverride", type="bool", default=false, name="Fix Zoom Pop Accuracy", description="Reimplements zoom pop to be more accurate. To see the problem with old zoom pop, zoom out, hover a fac near a mex then pop in...you will be at some random place nearby. In the new implementation the hovering fac is pretty much in the same place as before you popped." },
			{ key="zoomPopSpeed", type="number", default=0.08, name="Zoom Pop Speed", description="Speed up/slow down the pop animation (Zero = disabled).", min=0, max=10, valMult=0.01  },
		}},
		{ name = "UI", settings = {
			{ key="showEcontrol", type="bool", default=false, name="Show ECOntrol (slow?)", description="Show a user interface with a summary of your economy." },
			{ indent = 1, key="showEcontrolResources", type="bool", default=false, name="Show Resource Summary", description="Shows what you are spending your mass/energy on." },
			{ key="rearrangeBottomPanes", type="bool", default=false, name="Move Bottom Panes", description="Reorders the selected-unit-info pane and the orders pane to take up less vertical space (for wide monitors)." },
			{ key="hideMenusOnStart", type="bool", default=false, name="Hide Misc. Menus", description="On startup, collapse the multifunction (pings) and tabs (main menu)." },
		}},
		{ name = "Analysis", settings = {
			{ key="watchUnits", type="bool", default=false, name="Watch Units (slow?)", description="Mod analyzes units." },
			{ indent = 1, key="showAdornments", type="bool", default=false, name="Show Adornments (slow?)", description="Display symbols if unit is being assisted, is locked, is repeating. Requires 'Watch Units'." },
			{ indent = 1, key="alertUpgradeFinished", type="bool", default=false, name="Alert when upgrade structure/ACU finished", description="Beeps and messages you whenever a structure (eg: mex/factory/radar) or ACU has finished upgrading. Requires 'Watch Units'. ACU upgrades also requires Notify mod." },
			{ indent = 1, key="setGroundFireOnAttack", type="bool", default=false, name="Start in Ground Fire mode", description="Sets it so all units are ground firing. This is because normal fire mode is useless and ground fire does the same except allows you to fire at ground as well." },
			{ indent = 1, key="factoriesStartWithRepeatOn", type="bool", default=false, name="Factories Always Repeat", description="Factories will repeat unless you assist another factory or manually turn it off (and even then it will be turned back on if you stop your factory).\r\n\r\nFactories start in repeat mode. Repeat mode is also turned on whenever the Stop command is issued. Repeat is turned OFF automatically when they assist another factory.\r\n\r\nThese changes include more exotic factories like Quantum Gateways and experimentals that can produce units like the Fatboy. Warning: Rebind your repeat key first ... otherwise you will be turning your facs OFF repeat out of habit." },
			{ indent = 1, key="alertIdleFac", type="bool", default=true, name="Highlight idle factory in avatars", description="Beeps and show big red marker on the avatars pane, whenever there is an idle fac." },
		}},
		{ name = "Selection", settings = {
			{ key="enableUnitLock", type="bool", default=false, name="Enable Unit Lock (slow?)", description="Pressing the Toggle Unit Lock key locks the unit so it will be filtered out of any selection that mixes locked and unlocked units. (Shift overrides this back to normal)." },
			{ key="doubleClickSelectsSimilarAssisters", type="bool", default=false, name="Double click assister selects similar assisters (slow?)", description="If the unit is assisting something, double clicking it will select everything else that assists the same target." },
		}},
		{ name = "Start Sequence", settings = {
			{ key="useAlternativeStartSequence", type="bool", default=false, name="Use Alternative Start Sequence", description="Different zoom in.\r\nACU is selected earlier.\r\nFirst fac placement started." },
			{ indent = 1, key="startSplitScreen", type="bool", default=false, name="Start Split Screen", description="The game starts in split screen mode.\r\nLeft screen zooms in.\r\nRight screen zooms out.\r\nUser can control ACU earlier.\r\nACU is automatically set in place-land-factory mode.\r\nRequires alternative start sequence." },
			{ key="playerColors", type="bool", default=false, name="Start with Team Colors on", description="Start in alternate player colour mode (allies = green, enemy = red, you = blue)." },
		}},
		{ name = "Split Screen", settings = {
			{ key="smallerContructionTabWhenSplitScreen", type="bool", default=false, name="Construction to left", description="Construction menu just spans left screen (not both)." },
			{ key="moveAvatarsToLeftSplitScreen", type="bool", default=false, name="Avatars to left", description="Move the avatars (idle engies pane) to the left screen." },
			{ key="moveMainMenuToRight", type="bool", default=false, name="Main Menu to right", description="Move the tabs (main menu) to the right screen." },
		}},
		{ name = "Mod", settings = {
			{ key="modEnabled", type="bool", default=true, name="Mod Enabled (disable mod if lag/bug)", description="Turns off the entire mod. This does not put windows in their original place, etc. It just stops doing anything at all." },
			{ key="logEnabled", type="bool", default=false, name="Mod Log Enabled", description="For diagnostic purposes.", min=0, max=10, valMult=0.01  },
		}},
		{ name = "Hidden", settings = {
			{ key="xOffset", default=345 },
			{ key="yOffset", default=50 },
		}},
	}

	local tooltips = import('/lua/ui/help/tooltips.lua').Tooltips

	if not savedPrefs.global then
		savedPrefs.global = {}
	end

	local keys = {}
	for _, kv in settingDescriptions do
		for _, sv in kv.settings do
			-- Make defaults
			table.insert(keys, sv.key)
			if savedPrefs.global[sv.key] == nil then
				UIPLOG("Setting default " .. sv.key)
				savedPrefs.global[sv.key] = sv.default
			end

			-- Add tooltips
			tooltips["UIP_"..sv.key] = {
				title = sv.name,
				description = sv.description,
				keyID = "UIP_"..sv.key,
			}
		end
	end

	-- Clear old stuff
	local g = savedPrefs.global
	for gk, _ in g do
		if not LINQ.Contains(keys, gk) then
			UIPLOG("Removing old key " .. gk)
			g[gk] = nil
		end
	end

	-- Correct x/y if outside the window
	if (savedPrefs.global.xOffset < 0 or savedPrefs.global.xOffset > GetFrame(0).Width()) then
		savedPrefs.global.xOffset = GetFrame(0).Width()/2
	end
	if (savedPrefs.global.yOffset < 0 or savedPrefs.global.yOffset > GetFrame(0).Height()) then
		savedPrefs.global.yOffset = GetFrame(0).Height()/2
	end

	savePreferences()
end

function savePreferences()
	Prefs.SetToCurrentProfile("Party-UI Settings", savedPrefs)
	Prefs.SavePreferences()
end

function getPreferences()
	return savedPrefs
end

function setAllGlobalValues(t)
	for id, value in t do
		savedPrefs.global[id] = value
	end
	savePreferences()
	import('/mods/UI-Party/modules/econtrol.lua').setEnabled(UIP.Enabled() and savedPrefs.global.showEcontrol)
end

function setXYvalues(posX, posY)
	savedPrefs.global.xOffset = posX
	savedPrefs.global.yOffset = posY
	savePreferences()
end
