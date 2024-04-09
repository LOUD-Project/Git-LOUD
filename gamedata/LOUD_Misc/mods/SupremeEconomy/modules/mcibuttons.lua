local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Group = import('/lua/maui/group.lua').Group
local UIUtil = import('/lua/ui/uiutil.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local ToolTip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua').Tooltips
local AvatarsClickFunc = import('/lua/ui/game/avatars.lua').ClickFunc
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar

local modFolder = 'SupremeEconomy'

local GetScore = import('/mods/' .. modFolder .. '/modules/mciscore.lua').GetScore
local UpdateAllUnits = import('/mods/' .. modFolder .. '/modules/mciallunits.lua').UpdateAllUnits
local GetAllUnits = import('/mods/' .. modFolder .. '/modules/mciallunits.lua').GetAllUnits

function PrintUnitDebugInfo(unit)

	LOG("GetArmy " .. repr(unit:GetArmy()))
	--LOG("GetBlueprint " .. repr(unit:GetBlueprint())
	LOG("GetBuildRate " .. repr(unit:GetBuildRate()))
	LOG("GetCommandQueue " .. repr(unit:GetCommandQueue()))
	LOG("GetCreator " .. repr(unit:GetCreator()))
	LOG("GetEconData " .. repr(unit:GetEconData()))
	LOG("GetEntityId " .. repr(unit:GetEntityId()))
	LOG("GetFocus " .. repr(unit:GetFocus()))
	LOG("GetFootPrintSize " .. repr(unit:GetFootPrintSize()))
	LOG("GetFuelRatio " .. repr(unit:GetFuelRatio()))
	LOG("GetGuardedEntity " .. repr(unit:GetGuardedEntity()))
	LOG("GetHealth " .. repr(unit:GetHealth()))
	LOG("GetMaxHealth " .. repr(unit:GetMaxHealth()))
	LOG("GetMissileInfo " .. repr(unit:GetMissileInfo()))
	LOG("GetPosition " .. repr(unit:GetPosition()))
	LOG("GetMissileInfo " .. repr(unit:GetMissileInfo()))
	LOG("GetSelectionSets " .. repr(unit:GetSelectionSets()))
	LOG("GetShieldRatio " .. repr(unit:GetShieldRatio()))
	LOG("GetUnitId " .. repr(unit:GetUnitId()))
	LOG("GetWorkProgress " .. repr(unit:GetWorkProgress()))
	LOG("IsRepeatQueue " .. repr(unit:IsRepeatQueue()))
	LOG("IsStunned " .. repr(unit:IsStunned()))

	LOG("IsAutoMode " .. repr(unit:IsAutoMode()))
	LOG("IsAutoSurfaceMode " .. repr(unit:IsAutoSurfaceMode()))
	LOG("IsDead " .. repr(unit:IsDead()))

end

function CreateGrid(parent, x, y, cols, rows, CreateFunc)

	local grid = {}

	for col = 1,cols do

		grid[col] = {}

		for row = 1,rows do

			grid[col][row] = CreateFunc(parent)

			if row > 1 then
				LayoutHelpers.Below(grid[col][row], grid[col][row-1], 0)
			else
				LayoutHelpers.AtTopIn(grid[col][row], parent, y)
			end

			if col > 1 then
				LayoutHelpers.RightOf(grid[col][row], grid[col-1][row], 0)
			else
				LayoutHelpers.AtLeftIn(grid[col][row], parent, x)
			end

		end

	end

	return grid

end

function CreateTextBG(parent, control, color)

	background = Bitmap(control)
	background:SetSolidColor(color)
	background.Top:Set(control.Top)
	background.Left:Set(control.Left)
	background.Right:Set(control.Right)
	background.Bottom:Set(control.Bottom)
	background.Depth:Set(function() return parent.Depth() + 1 end)

end

function CreateGenericButton(parent)

	local buttonBackgroundName = UIUtil.SkinnableFile('/game/avatar-factory-panel/avatar-s-e-f_bmp.dds')

	local bg = Bitmap(parent, buttonBackgroundName)

    bg.Height:Set(44)
    bg.Width:Set(44)

	bg.units = {}
	bg.HandleEvent = AvatarsClickFunc

	bg.marker = Bitmap(bg)
	bg.marker:SetTexture(UIUtil.UIFile('/game/avatar/pulse-bars_bmp.dds'))
	bg.marker.Height:Set(54)
	bg.marker.Width:Set(54)

	LayoutHelpers.AtLeftTopIn(bg.marker, bg, -5, -5)

	bg.icon = Bitmap(bg)
    bg.icon.Height:Set(34)
    bg.icon.Width:Set(34)

	LayoutHelpers.AtLeftTopIn(bg.icon, bg, 5, 5)

	bg.progress = StatusBar(bg, 0, 1, false, false,
							UIUtil.UIFile('/game/unit-over/health-bars-back-1_bmp.dds'),
							UIUtil.UIFile('/game/unit-over/bar01_bmp.dds'), true, "Unit RO Health Status Bar")

	bg.progress.Width:Set(32)
    bg.progress.Height:Set(0)

    LayoutHelpers.AtLeftTopIn(bg.progress, bg, 6, 2)


    bg.income = UIUtil.CreateText(bg.icon, '', 13, UIUtil.bodyFont)
	bg.income:SetColor('ffff8f00')
    --bg.income:SetDropShadow(true)

	LayoutHelpers.AtTopIn(bg.income, bg.icon, 0)
    LayoutHelpers.AtRightIn(bg.income, bg.icon, 1)

	CreateTextBG(bg, bg.income, '77000000')

	bg.count = UIUtil.CreateText(bg.icon, '', 11, UIUtil.bodyFont)
	bg.count:SetColor('ffffffff')
    --bg.count:SetDropShadow(true)

	LayoutHelpers.AtBottomIn(bg.count, bg.icon, 0)
    LayoutHelpers.AtRightIn(bg.count, bg.icon, 2)

	CreateTextBG(bg, bg.count, '77000000')

	return bg

end