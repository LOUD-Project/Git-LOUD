function RunSeqUpgrades()
    local myUnits = import('/lua/ui/game/gamemain.lua').GetSeqUpgradeList()
    if not table.empty(myUnits) then
         ForkThread(UpgradeBuildings, myUnits)
    end
end