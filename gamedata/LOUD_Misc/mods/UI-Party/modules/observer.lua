function QuickSwitch()

    local info = GetRolloverInfo()
    
    if info == nil then
        SetFocusArmy(-1)
    else
        SetFocusArmy(info.armyIndex + 1)
    end

end

