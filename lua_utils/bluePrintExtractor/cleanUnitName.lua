local function cleanUnitName(bp)
    --<LOC ual0402_name>Overlord
    local UnitBaseName = "None"
    if(bp.General and bp.General.UnitName) then
        UnitBaseName = bp.General.UnitName
        local strStrt = string.find(UnitBaseName,">")
        local strStop = string.len(UnitBaseName)
        if (strStrt and strStop) then
            UnitBaseName = string.sub(UnitBaseName,strStrt+1,strStop)
        end
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

return cleanUnitName