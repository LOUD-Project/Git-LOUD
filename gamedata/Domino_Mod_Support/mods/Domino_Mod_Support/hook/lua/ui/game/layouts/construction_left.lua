local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Grid = import('/lua/maui/grid.lua').Grid
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua')

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
        local TheTexture = CurrentSkin .. '_' .. 'left' .. '_' .. control.ID
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
                LayoutHelpers.AtLeftTopIn(control, controls.minBG, 134, 60)
            else
                local offset = 0
                LayoutHelpers.Below(control, prevControl, offset)
            end
            
            prevControl = control
        end
    end
    
    SetupTab(controls.constructionTab)
    LayoutHelpers.AtLeftTopIn(controls.constructionTab, controls.constructionGroup, 20, 7)
    SetupTab(controls.selectionTab)
    LayoutHelpers.RightOf(controls.selectionTab, controls.constructionTab, 0)
    SetupTab(controls.enhancementTab)
    LayoutHelpers.RightOf(controls.enhancementTab, controls.selectionTab, 0)
end
