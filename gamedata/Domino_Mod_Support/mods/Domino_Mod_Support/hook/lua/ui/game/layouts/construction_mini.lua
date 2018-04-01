local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Grid = import('/lua/maui/grid.lua').Grid
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua')

do

function LayoutTabs(controls)
    local prevControl = false
	    
    local tabFiles = __DMSI.__Dmod_TabFiles
	local techFiles = __DMSI.__Dmod_TechFiles
	local CurrentSkin = UIUtil.DMod_Return_Skin()

    local function GetTabTextures(id)
        if tabFiles[id] then
            local pre = tabFiles[id]
            return UIUtil.UIFile(pre..'up_bmp.dds'), UIUtil.UIFile(pre..'sel_bmp.dds'),
                UIUtil.UIFile(pre..'over_bmp.dds'), UIUtil.UIFile(pre..'down_bmp.dds'), 
                UIUtil.UIFile(pre..'dis_bmp.dds'), UIUtil.UIFile(pre..'dis_bmp.dds')
        elseif techFiles[id] then
            local pre = techFiles[id]
            return UIUtil.UIFile(pre..'up.dds'), UIUtil.UIFile(pre..'selected.dds'),
                UIUtil.UIFile(pre..'over.dds'), UIUtil.UIFile(pre..'down.dds'), 
                UIUtil.UIFile(pre..'dis.dds'), UIUtil.UIFile(pre..'dis.dds')
        end
    end
    
    local function SetupTab(control)
	
		local TheTexture = CurrentSkin .. '_' .. 'mini' .. '_' .. control.ID
        
		control:SetNewTextures(GetTabTextures(TheTexture))
        control:UseAlphaHitTest(false)
               
        control.OnDisable = function(self)
            self.disabledGroup:Enable()
            Checkbox.OnDisable(self)
        end
        
        control.disabledGroup.Height:Set(25)
        control.disabledGroup.Width:Set(40)
        LayoutHelpers.AtCenterIn(control.disabledGroup, control)
        
        control.OnEnable = function(self)
            self.disabledGroup:Disable()
            Checkbox.OnEnable(self)
        end
    end
    
    if table.getsize(controls.tabs) > 0 then
        for id, control in controls.tabs do
            SetupTab(control)
             
            if not prevControl then
                LayoutHelpers.AtLeftTopIn(control, controls.minBG, 82, 0)
            else
                local offset = 0
                LayoutHelpers.RightOf(control, prevControl, offset)
            end
            
            prevControl = control
        end
        controls.midBG1:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_bmp_m1.dds'))
        controls.midBG1.Right:Set(prevControl.Right)
        controls.midBG2:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_bmp_m2.dds'))
        controls.midBG3:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_bmp_m3.dds'))
        controls.minBG:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_bmp_l.dds'))
        LayoutHelpers.AtLeftIn(controls.minBG, controls.constructionGroup, 67) --67
        LayoutHelpers.AtBottomIn(controls.maxBG, controls.minBG, 1) --1
        LayoutHelpers.AtBottomIn(controls.minBG, controls.constructionGroup, 4) --4
    else
        controls.midBG1:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_s_bmp_m.dds'))
        controls.midBG2:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_s_bmp_m.dds'))
        controls.midBG3:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_s_bmp_m.dds'))
        controls.minBG:SetTexture(UIUtil.UIFile('/game/construct-panel/construct-panel_s_bmp_l.dds'))
        LayoutHelpers.AtLeftIn(controls.minBG, controls.constructionGroup, 69) --69
        LayoutHelpers.AtBottomIn(controls.maxBG, controls.minBG, 0) --0
        LayoutHelpers.AtBottomIn(controls.minBG, controls.constructionGroup, 5) --5
    end
    
    SetupTab(controls.constructionTab)
    LayoutHelpers.AtLeftTopIn(controls.constructionTab, controls.constructionGroup, 0, 14)
    SetupTab(controls.selectionTab)
    LayoutHelpers.Below(controls.selectionTab, controls.constructionTab, -16)
    SetupTab(controls.enhancementTab)
    LayoutHelpers.Below(controls.enhancementTab, controls.selectionTab, -16)
    
end



end