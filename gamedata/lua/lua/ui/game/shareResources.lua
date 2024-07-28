--* File: lua/modules/ui/game/shareResources.lua
--* Summary: UI for Sharing (and giving) Resources

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Slider = import('/lua/maui/Slider.lua').Slider
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local Edit = import('/lua/maui/edit.lua').Edit

local radWidth, radHeight = GetTextureDimensions(UIUtil.UIFile('/widgets/large-h_scr/bar-mid_scr_up.dds'))
local lradWidth, lradHeight = GetTextureDimensions(UIUtil.UIFile('/widgets/large-h_scr/bar-left_scr_up.dds'))
local rradWidth, rradHeight = GetTextureDimensions(UIUtil.UIFile('/widgets/large-h_scr/bar-right_scr_up.dds'))

-- creates the actual dialog
--- parent is the calling window
function createShareResourcesDialog(parent, targetPlayer, targetPlayerName)

    local massVal = 0
    local energyVal = 0

    local worldView = import('/lua/ui/game/worldview.lua').view
    local dialog = Bitmap(parent, UIUtil.UIFile('/dialogs/diplomacy-resources_options/diplomacy-panel_bmp.dds'))
    dialog:SetRenderPass(UIUtil.UIRP_PostGlow)  -- just in case our parent is the map
    dialog:SetName("Share Resources Window")
    LayoutHelpers.AtCenterIn(dialog, worldView)

    local chatTitle = UIUtil.CreateText(dialog, LOC("<LOC SHARERES_0000>Send Resources to ") .. targetPlayerName, 16, UIUtil.bodyFont)
    LayoutHelpers.AtLeftIn(chatTitle, dialog, 30)
    LayoutHelpers.AtTopIn(chatTitle, dialog, 25)
    
    local massIcon = Bitmap(dialog, UIUtil.UIFile('/dialogs/diplomacy-resources_options/mass_btn_up.dds'))
    LayoutHelpers.AtLeftTopIn(massIcon, dialog, 27, 60)

    local massInputContainer = Group(dialog)
    LayoutHelpers.AtRightTopIn(massInputContainer, massIcon, 40, 12)
    LayoutHelpers.SetDimensions(massInputContainer, 80, 16)
    
    local massInput = UIUtil.CreateText(dialog, "0%", 12, UIUtil.bodyFont)
    LayoutHelpers.AtCenterIn(massInput, massInputContainer)

    local massStatus = StatusBar(dialog, 0, 100, false, false,
        UIUtil.UIFile('/dialogs/diplomacy-resources_options/mass-bar-back_bmp.dds'),
        UIUtil.UIFile('/dialogs/diplomacy-resources_options/mass-bar_bmp.dds'), false)

    local massSlider = Slider(dialog, false, 0, 100,
        UIUtil.UIFile('/dialogs/slider_btn/mass-bar-edge_btn_up.dds'), 
        UIUtil.UIFile('/dialogs/slider_btn/mass-bar-edge_btn_up.dds'),
        UIUtil.UIFile('/dialogs/slider_btn/mass-bar-edge_btn_up.dds'))
    LayoutHelpers.AtRightTopIn(massSlider, massIcon, 1, 25)
    LayoutHelpers.AnchorToLeft(massSlider, massInputContainer, 10)
    massSlider:SetValue( massVal )
    massSlider.OnValueChanged = function(self, newValue)
        massInput:SetText(string.format("%d%%", math.max(math.min(math.floor(newValue), 100), 0)))
        massStatus:SetValue(math.floor(newValue))
    end
    
    LayoutHelpers.AtTopIn(massStatus, massIcon, 12)
    massStatus.Left:Set(function() return massIcon.Right()  end)
    LayoutHelpers.AnchorToLeft(massStatus, massInputContainer, 12)
    massStatus.Depth:Set(function() return massSlider.Depth() - 1 end)
    local masswidth = massStatus.Width()
    massStatus:SetMinimumSlidePercentage(7/masswidth)
    massStatus:SetRange(0, 100)
    massStatus:SetValue( massVal )

    local energyIcon = Bitmap(dialog, UIUtil.UIFile('/dialogs/diplomacy-resources_options/energy_btn_up.dds'))
    LayoutHelpers.AtLeftTopIn(energyIcon, dialog, 27, 140)

    local energyInputContainer = Group(dialog)
    LayoutHelpers.AtTopIn(energyInputContainer, energyIcon, 12)
    LayoutHelpers.AtRightIn(energyInputContainer, dialog, 40)
    LayoutHelpers.SetDimensions(energyInputContainer, 80, 16)
    
    local energyInput = UIUtil.CreateText(dialog, "0%", 12, UIUtil.bodyFont)
    LayoutHelpers.AtCenterIn(energyInput, energyInputContainer)

    local energyStatus = StatusBar(dialog, 0, 100, false, false,
        UIUtil.UIFile('/dialogs/diplomacy-resources_options/energy-bar-back_bmp.dds'),
        UIUtil.UIFile('/dialogs/diplomacy-resources_options/energy-bar_bmp.dds'), false)

    local energySlider = Slider(dialog, false, 0, 100,
        UIUtil.UIFile('/dialogs/slider_btn/energy-bar-edge_btn_up.dds'),
        UIUtil.UIFile('/dialogs/slider_btn/energy-bar-edge_btn_up.dds'),
        UIUtil.UIFile('/dialogs/slider_btn/energy-bar-edge_btn_up.dds'))
    LayoutHelpers.AtTopIn(energySlider, energyIcon, 25)
    LayoutHelpers.AnchorToRight(energySlider, energyIcon, -1 end)
    LayoutHelpers.AnchorToLeft(energySlider, energyInputContainer, 10)
    energySlider:SetValue( energyVal )
    energySlider.OnValueChanged = function(self, newValue)
        energyInput:SetText(string.format("%d%%", math.max(math.min(math.floor(newValue), 100), 0)))
        energyStatus:SetValue(math.floor(newValue))
    end

    LayoutHelpers.AtTopIn(energyStatus, energyIcon, 12)
    energyStatus.Left:Set(function() return energyIcon.Right()  end)
    LayoutHelpers.AnchorToLeft(energyStatus, energyInputContainer, 12)
    energyStatus.Depth:Set(function() return energySlider.Depth() - 1 end)
    energyStatus:SetMinimumSlidePercentage(7/masswidth)
    energyStatus:SetRange(0, 100)
    energyStatus:SetValue( energyVal )

    # overriden by caller
    dialog.OnOk = function(mass,energy)
        
    end

    # overriden by caller
    dialog.OnCancel = function()
        dialog:Destroy()
    end

    local cancelButton = UIUtil.CreateButtonStd(dialog, "/dialogs/standard_btn/standard", "<LOC _Cancel>", 12)
    LayoutHelpers.AtBottomIn(cancelButton, dialog, 20)
    LayoutHelpers.AtRightIn(cancelButton, dialog, 24)
    cancelButton.OnClick = function(self, modifiers)
        dialog.OnCancel()
    end

    local okButton = UIUtil.CreateButtonStd(dialog, "/dialogs/standard_btn/standard", "<LOC _OK>", 12)
    LayoutHelpers.LeftOf(okButton, cancelButton, 3)
    okButton.OnClick = function(self, modifiers)
        dialog.OnOk( massSlider:GetValue() / 100.0, energySlider:GetValue() / 100.0 )
    end
    
    dialog:Show()
    
    -- note this will only get called when the bg has input mode
    dialog.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            if event.KeyCode == UIUtil.VK_ESCAPE then
                cancelButton.OnClick(dialog.okButton)
            elseif event.KeyCode == UIUtil.VK_ENTER or event.KeyCode == 345 then
                okButton.OnClick(dialog.okButton)
            end
        end
    end
    AddInputCapture(dialog)
    dialog.OnDestroy = function(self)
        RemoveInputCapture(dialog)
    end
    
    return dialog
end