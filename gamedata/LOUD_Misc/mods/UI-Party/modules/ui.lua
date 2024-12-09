local modpath = '/mods/ui-party'
local settings = import(modpath..'/modules/settings.lua')

local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Dragger = import('/lua/maui/dragger.lua').Dragger

local savedPrefs = nil
local mainPanel = nil

local panelConst = {
	height = 60,
	width = 300,
	distance = 4,
	buttonSize = 15,
	buttonDistance = 3,
	buttonXOffset = 0
}

buttons = {
	dragButton = nil,
	configButton = nil
}

function init()
	-- settings
	savedPrefs = settings.getPreferences()

	mainPanel = Bitmap(GetFrame(0))
	mainPanel.Depth:Set(99)
	LayoutHelpers.AtLeftTopIn(mainPanel, GetFrame(0), savedPrefs.global.xOffset, savedPrefs.global.yOffset)
	mainPanel.Height:Set(panelConst.buttonSize)
	mainPanel.Width:Set(panelConst.buttonSize)

	AddMainPanelButtons()
end

-----------------------------------------------------------------------

function ReloadAndApplyGlobalConfigs()
end

function AddMainPanelButtons()
	buttons.dragButton = Button(mainPanel, modpath..'/textures/drag_up.dds', modpath..'/textures/drag_down.dds', modpath..'/textures/drag_over.dds', modpath..'/textures/drag_up.dds')
	LayoutHelpers.AtLeftTopIn(buttons.dragButton, mainPanel, panelConst.buttonXOffset, 0)

	buttons.configButton = Button(mainPanel, modpath..'/textures/options_up.dds', modpath..'/textures/options_down.dds', modpath..'/textures/options_over.dds', modpath..'/textures/options_up.dds')
	LayoutHelpers.AtLeftTopIn(buttons.configButton, mainPanel, panelConst.buttonXOffset + (panelConst.buttonSize+40)*1, 0)

	buttons.dragButton.HandleEvent = function(self, event)
		if event.Type == 'ButtonPress' then
			local drag = Dragger()
			local offX = event.MouseX - self.Left()
			local offY = event.MouseY - self.Top()
			drag.OnMove = function(dragself, x, y)
				mainPanel.Left:Set(x - offX + (mainPanel.Left() - buttons.dragButton.Left()))
				mainPanel.Top:Set(y - offY)
				GetCursor():SetTexture(UIUtil.GetCursor('MOVE_WINDOW'))
			end
			drag.OnRelease = function(dragself)
				settings.setXYvalues(LayoutHelpers.InvScaleNumber(self.Left()), LayoutHelpers.InvScaleNumber(self.Top()))
				GetCursor():Reset()
				drag:Destroy()
			end
			PostDragger(self:GetRootFrame(), event.KeyCode, drag)
		end
	end

	buttons.configButton:EnableHitTest(true)
	buttons.configButton.OnClick = function(self, event)
		import(modpath..'/modules/settingsUi.lua').CreatePrefsUI()
	end

end

function moveMainpanelButtons(s)
	helpDistance = panelConst.buttonSize + panelConst.buttonDistance
	helpOffsetX = 0

	if s == "right" then
		helpOffsetX = panelConst.width - 3*helpDistance + panelConst.buttonDistance
	end

	LayoutHelpers.AtLeftTopIn(buttons.dragButton, mainPanel, helpOffsetX + helpDistance*0, 0)
	LayoutHelpers.AtLeftTopIn(buttons.configButton, mainPanel, helpOffsetX + helpDistance*1, 0)
end

