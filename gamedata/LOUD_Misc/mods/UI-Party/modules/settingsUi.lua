local modpath = '/mods/UI-Party'
local uiPartyUi = import(modpath..'/modules/ui.lua')

local KeyMapper = import('/lua/keymap/keymapper.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local IntegerSlider = import('/lua/maui/slider.lua').IntegerSlider
local Tooltip = import('/lua/ui/game/tooltip.lua')

local settings = import(modpath..'/modules/settings.lua')
local savedPrefs = nil
local curPrefs = nil
local curY = 0
local curX = 30

local uiPanel = {
	main = nil,
	okButton = nil,
	cancelButton = nil,
}

local uiPanelSettings = {
	width = 500,
	textSize = {
		headline = 20,
		section = 16,
		option = 12,
	},
}

function CreateResetKeysControl(sv)
	local btn = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'Set', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
    Tooltip.AddButtonTooltip(btn, 'UIP_' .. sv.key)
	btn.OnClick = function(self)
		UIUtil.QuickDialog(uiPanel.main, "Really set key bindings?",
           	"Yes", ResetKeys,
            "No", nil,
            nil, nil,
            true,
            {escapeButton = 2, enterButton = 1, worldCover = false})
	end
	return btn
end

function ResetKeys()
	local keys = {
		['V'] = 'Select next split group',
		['Shift-V'] = 'Select next split group (shift)',
        ['Ctrl-Shift-Alt-V'] = 'Reselect Split Units',
        ['Ctrl-Alt-V'] = 'Reselect Ordered Split Units',
	}

	for i = 2, 10 do
		local v = i
		local action = 'Split selection into '..v..' groups'
		if v == 10 then v = 0 end
		local key = 'Ctrl-Alt-'..v
		keys[key] = action
	end

	for i = 1, 10 do
		local v = i
		local action = 'Select split group '..v
		if v == 10 then v = 0 end
		local key = 'Alt-'..v
		keys[key] = action
	end

	for k, v in keys do
	    KeyMapper.SetUserKeyMapping(k, nil, v)
	end

	UIUtil.ShowInfoDialog(uiPanel.main, "Bindings set", "Ok", nil, true)
end

function CreatePrefsUI()
	if uiPanel.main then
		uiPanel.main:Destroy()
		uiPanel.main = nil
		return
	end

	-- Copy configs to local, to not mess with the original ones until they should save
	savedPrefs = settings.getPreferences()
	curPrefs = table.deepcopy(savedPrefs, {})

	-- Make UI
	CreateMainPanel()
	curY = 0

	LayoutHelpers.CenteredAbove(UIUtil.CreateText(uiPanel.main, "UI Party", uiPanelSettings.textSize.headline, UIUtil.bodyFont), uiPanel.main, curY - 30)
	curY = curY + 30
	CreateOptions(curY)

	curY = curY + 10

	CreateOkCancelButtons()
	LayoutHelpers.SetHeight(uiPanel.main, curY + 30)
end

---------------------------------------------------------------------

function CreateMainPanel()
	local posX = 100
	local posY = 100

	uiPanel.main = Bitmap(GetFrame(0))
	uiPanel.main.Depth:Set(1199)
	LayoutHelpers.AtLeftTopIn(uiPanel.main, GetFrame(0), posX, posY)
	uiPanel.main:InternalSetSolidColor('dd000000')
	LayoutHelpers.SetWidth(uiPanel.main, uiPanelSettings.width)
	uiPanel.main:Show()
end

function CreateOptions()
	---- Left side options

	local settingGroups = settings.getSettingDescriptions()

	for _, group in settingGroups do
		if group.name ~= "Hidden" then

			curY = curY + 5
			LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, group.name, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX, curY)
			curY = curY + 20

			for _, v in group.settings do
				local indent = 5 + (v.indent or 0) * 15

				if v.type == "bool" then
					CreateSettingCheckbox(curX + indent, curY, 13, {"global", v.key}, v.name, v.key)
				elseif v.type == "number" then
					CreateSettingsSliderWithText(curX + indent, curY, v.name, v.min, v.max, v.valMult, {"global", v.key}, v.key)
				elseif v.type == "custom" then
					-- RAT: Only one custom control: resetKeys
					-- Closure scoping problems prevents use of a callback here
					-- So I'm just sending it to the actual function
					local ctrl = CreateResetKeysControl(v)
					LayoutHelpers.AtLeftTopIn(ctrl, uiPanel.main, curX + indent, curY)
					LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, v.name, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX + 100 + indent, curY + 7)
					curY = curY + 30
				else
					UIPLOG("Unknown settings type: " .. v.type)
				end
			end
		end
	end
end

function CreateOkCancelButtons()

	local btnOk = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'OK', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
	LayoutHelpers.AtLeftTopIn(btnOk, uiPanel.main, curX, curY)
	btnOk.OnClick = function(self)
		settings.setAllGlobalValues(curPrefs.global)
		uiPartyUi.ReloadAndApplyGlobalConfigs()
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end

	local btnCancel = UIUtil.CreateButtonStd(uiPanel.main, '/dialogs/standard-small_btn/standard-small', 'Cancel', 12, 2, 0, "UI_Opt_Mini_Button_Click", "UI_Opt_Mini_Button_Over")
	LayoutHelpers.AtLeftTopIn(btnCancel, uiPanel.main, curX + 100, curY)
	btnCancel.OnClick = function(self)
		uiPanel.main:Destroy()
		uiPanel.main = nil
	end

	curY = curY + 30
end

---------------------------------------------------------------------

function CreateSettingCheckbox(posX, posY, size, args, text, key)
	local value = curPrefs
	local argsCopy = args
	for _,v in args do
		value = value[v]
	end

	local box = UIUtil.CreateCheckboxStd(uiPanel.main, '/dialogs/check-box_btn/radio')
    Tooltip.AddCheckboxTooltip(box, 'UIP_' .. key)
	LayoutHelpers.SetDimensions(box, size, size)
	box:SetCheck(value, true)

	box.OnClick = function(self)
		if(box:IsChecked()) then
			setCurPrefByArgs(argsCopy, false)
			value = false
			box:SetCheck(false, true)
		else
			setCurPrefByArgs(argsCopy, true)
			value = true
			box:SetCheck(true, true)
		end
	end

	LayoutHelpers.AtLeftTopIn(box, uiPanel.main, posX, posY+1)
	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, text, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, posX+15, curY)
	curY = curY + 20
end

function CreateSettingsSliderWithText(posX, posY, text, minVal, maxVal, valMult, args, key)
	-- Value
	local value = curPrefs
	for i, v in args do
		value = value[v]
	end
	if value < minVal * valMult then
		value = minVal * valMult
	elseif value > maxVal * valMult then
		value = maxVal * valMult
	end

	-- Value text
	local valueText = UIUtil.CreateText(uiPanel.main, string.format("%g",value), uiPanelSettings.textSize.option, UIUtil.bodyFont)
	LayoutHelpers.AtLeftTopIn(valueText, uiPanel.main, posX + 350, posY)

	local slider = IntegerSlider(uiPanel.main, false, minVal, maxVal, 1, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds'))
	LayoutHelpers.AtLeftTopIn(slider, uiPanel.main, posX + 150, posY)
	slider:SetValue(value / valMult)
	slider.OnValueChanged = function(self, newValue)
		valueText:SetText(string.format("%g", newValue * valMult))
		setCurPrefByArgs(args, newValue*valMult)
	end
    Tooltip.AddCheckboxTooltip(slider, 'UIP_' .. key)

	LayoutHelpers.AtLeftTopIn(UIUtil.CreateText(uiPanel.main, text, uiPanelSettings.textSize.option, UIUtil.bodyFont), uiPanel.main, curX+20, curY)

	curY = curY + 20
end

function setCurPrefByArgs(args, value)
	num = table.getn(args)
	if num == 2 then
		curPrefs[args[1]][args[2]] = value
	end
	if num == 4 then
		curPrefs[args[1]][args[2]][args[3]][args[4]] = value
	end
end