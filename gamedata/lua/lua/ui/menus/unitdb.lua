-- unitdb.lua
-- Author: Rat Circus

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

allBlueprints = {}
curBlueprint = {}
countBPs = 0

function CreateUnitDB(over, inGame, callback)
	-- Must plug UnitBlueprint() into engine before running doscript on .bps
	doscript '/lua/ui/menus/unitdb_bps.lua'
	
	for _, file in DiskFindFiles('/units', '*_unit.bp') do
		safecall("UNIT DB: Loading BP "..file, doscript, file)
	end

	local parent = over
	local panel = Bitmap(over, UIUtil.UIFile('/scx_menu/eula/eula.dds'))
	LayoutHelpers.AtCenterIn(panel, parent)
	panel.brackets = UIUtil.CreateDialogBrackets(panel, 38, 24, 38, 24)
	local title = UIUtil.CreateText(panel, LOC("LOUD Unit Database"), 24)
	LayoutHelpers.AtTopIn(title, panel, 31)
	LayoutHelpers.AtHorizontalCenterIn(title, panel)
	panel.Depth:Set(GetFrame(over:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	local worldCover = nil
	if not inGame then
		worldCover = UIUtil.CreateWorldCover(panel)
	end

	local exitBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Exit", 16, 2)
	LayoutHelpers.AtRightTopIn(exitBtn, panel, 30, 505)
	exitBtn.OnClick = function(self, modifiers)
		if over then
			panel:Destroy()
		else
			parent:Destroy()
		end
		callback()
	end

	UIUtil.MakeInputModal(panel, function() exitBtn.OnClick(exitBtn) end)
end