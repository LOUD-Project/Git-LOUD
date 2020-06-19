-- Helper Functions by PhoenixMT
local PhxLib ={
    _VERSION = '0.3',
    _DESCRIPTION = 'General Helper Functions',
}

function PhxLib.canTargetHighAir(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Air") and
            not string.find((weapon.TargetRestrictDisallow or "None"),
                           "HIGHALTAIR") and
            not string.find((weapon.TargetRestrictOnlyAllow or "None"),
                           "TACTICAL") and
            not string.find((weapon.TargetRestrictOnlyAllow or "None"),
                           "MISSILE")
        ) then
            return true
        end
    end

    return false
end

function PhxLib.canTargetLand(weapon)
    local completeTargetLayerList = ''
--    for curLayerID,curLayerList in ipairs(weapon.FireTargetLayerCapsTable) do
--        completeTargetLayerList = completeTargetLayerList .. curLayerList
--    end
    if(weapon.FireTargetLayerCapsTable) then
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(string.find(completeTargetLayerList,"Land") or
           string.find(completeTargetLayerList,"Water")
        ) then
            return true
        end
    end

    return false
end

function PhxLib.canTargetSubs(weapon)
    if(weapon.AboveWaterTargetsOnly) then return false end
    if(weapon.FireTargetLayerCapsTable) then
        local completeTargetLayerList = ''
        for curKey,curLayerList in pairs(weapon.FireTargetLayerCapsTable) do
            completeTargetLayerList = completeTargetLayerList .. curLayerList
        end
        if(
            string.find(completeTargetLayerList,"Sub") 
            --or string.find(completeTargetLayerList,"Seabed") 
        ) then
            return true
        end
    end

    return false
end

function PhxLib.cleanUnitName(bp)
    --<LOC ual0402_name>Overlord
    local UnitBaseName = "None"
    -- General.UnitName is usually better, but doesn't always exist.
    if(bp.General and bp.General.UnitName) then
        UnitBaseName = bp.General.UnitName
        local strStrt = string.find(UnitBaseName,">")
        local strStop = string.len(UnitBaseName)
        if (strStrt and strStop) then
            UnitBaseName = string.sub(UnitBaseName,strStrt+1,strStop)
        end
    -- Fall back to Description if needed
    elseif(bp.Description) then
        UnitBaseName = bp.Description
        local strStrt = string.find(UnitBaseName,">")
        local strStop = string.len(UnitBaseName)
        if (strStrt and strStop) then
            UnitBaseName = string.sub(UnitBaseName,strStrt+1,strStop)
        end
    else
        --UnitBaseName = "None"
    end

    return UnitBaseName
end

function PhxLib.getTechLevel(bp)
    if(bp.Categories) then
        local completeCategoriesList = ''
        for curKey,curCategory in pairs(bp.Categories) do
            completeCategoriesList = completeCategoriesList .. curCategory
        end
        if string.find(completeCategoriesList,"EXPERIMENTAL")
            then return 4
        elseif string.find(completeCategoriesList,"TECH3")
            then return 3
        elseif string.find(completeCategoriesList,"TECH2")
            then return 2
        elseif string.find(completeCategoriesList,"TECH1")
            then return 1
        else 
            return 0
        end
    else
        if bp.General and 
            bp.General.TechLevel == 'RULEUTL_Basic'
        then Tier = 1
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Advanced'
        then Tier = 2
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Secret'
        then Tier = 3
        elseif bp.General and 
            bp.General.TechLevel == 'RULEUTL_Experimental'
        then Tier = 4
        end

        return 0
    end
end


return PhxLib