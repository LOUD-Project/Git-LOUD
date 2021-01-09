
-- harvested from unitview.lua
function GetUnitName(u)
		local bp = u:GetBlueprint()
		local techLevel = false
        local levels = {TECH1 = 1,TECH2 = 2,TECH3 = 3}
        for i, v in bp.Categories do
            if levels[v] then
                techLevel = levels[v]
                break
            end
        end
        local description = LOC(bp.Description)
        if techLevel then
            description = LOCF("Tech %d %s", techLevel, bp.Description)
        end
      
        if bp.General.UnitName then
            description =(LOCF('%s: %s', bp.General.UnitName, description))
        else        
		    description =(LOCF('%s', description))
        end
		return description
end
