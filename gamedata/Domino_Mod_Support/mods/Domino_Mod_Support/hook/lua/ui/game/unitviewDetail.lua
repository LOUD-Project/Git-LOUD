do
local __DMSI = import('/mods/Domino_Mod_Support/lua/initialize.lua')

local enhancementSlotNames = __DMSI.__DMod_EnhancementSlotNames
    
   
local OldShowEnhancement = ShowEnhancement
function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
	OldShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
    if CheckFormat() then
        # Name / Description
        View.UnitImg:SetTexture(UIUtil.UIFile(iconPrefix..'_btn_up.dds'))
        
        LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
        View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)

        local slotName = enhancementSlotNames[string.lower(bp.Slot)]
        slotName = slotName or bp.Slot

        if bp.Name != nil then
			View.UnitShortDesc:SetText(LOCF("%s: Slot:%s", bp.Name, slotName))
        else
            View.UnitShortDesc:SetText(LOC(slotName))
        end
        if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
            LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
            View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
        end
    else
        Hide()
    end
end
    







end