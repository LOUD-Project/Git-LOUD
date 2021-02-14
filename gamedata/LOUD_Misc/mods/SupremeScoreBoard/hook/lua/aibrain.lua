function SyncTeamEconomy()
    while true do
        local me = GetFocusArmy()
        local my_brain = me ~= -1 and ArmyBrains[me]
        local defeated = my_brain and my_brain:IsDefeated()
        local team_eco = {allies={}, overflow={MASS=0, ENERGY=0}, 
							          reclaim={}}
        local n_allies = 0 

        for index, brain in ArmyBrains do
		    
			local massReclaim = brain:GetArmyStat("Economy_Reclaimed_Mass", 0.0).Value or 0
			--local enryReclaim = brain:GetArmyStat("Economy_Reclaimed_Energy", 0.0).Value or 0
            team_eco['reclaim'][index] = {}
			team_eco['reclaim'][index].mass = massReclaim
              
            if me ~= -1 and IsAlly(me, index) then
                for _, t in {'ENERGY', 'MASS'} do 
                    local eco = {}
				    eco.stored = brain:GetEconomyStored(t)
                    eco.ratio = brain:GetEconomyStoredRatio(t)
                    eco.max = eco.stored / math.max(eco.ratio, 0.001)
                    eco.net = brain:GetEconomyIncome(t) - brain:GetEconomyRequested(t)
                    if eco.stored + eco.net > eco.max then
                        eco.overflow = eco.net - (eco.max - eco.stored)
                    else
                        eco.overflow = 0
                    end

                    if not team_eco['allies'][index] then
                        team_eco['allies'][index] = {}
                    end
                
                    team_eco['allies'][index][t] = eco
                    if me ~= index then
                      team_eco['overflow'][t] = (team_eco['overflow'][t] or 0) + eco.overflow
                    end
                end
            end
        end

        local n_allies = table.getsize(team_eco['allies']) - 1 -- not yourself
        if n_allies > 0 then
            team_eco['overflow']['MASS'] = team_eco['overflow']['MASS'] / n_allies
            team_eco['overflow']['ENERGY'] = team_eco['overflow']['ENERGY'] / n_allies
        end
        
        Sync.TeamEco = team_eco
        
        WaitTicks(5)    
    end
end
function UpdateReclaimStat()

	LOG("*XDEBUG: " .. " AIbrain forking SyncTeamEconomy... "  )
								
    ForkThread(SyncTeamEconomy)
    # this function update the reclaim income stat.
    while true do
        for index, brain in ArmyBrains do
            local reclaimedMass     = brain:GetArmyStat("Economy_Reclaimed_Mass", 0.0).Value
            local oldReclaimedMass  = brain:GetArmyStat("Economy_old_Reclaimed_Mass", 0.0).Value
            brain:SetArmyStat("Economy_income_reclaimed_Mass", reclaimedMass - oldReclaimedMass)
            brain:SetArmyStat("Economy_old_Reclaimed_Mass", reclaimedMass)

            local reclaimedEnergy     = brain:GetArmyStat("Economy_Reclaimed_Energy", 0.0).Value
            local oldReclaimedEnergy  = brain:GetArmyStat("Economy_old_Reclaimed_Energy", 0.0).Value
            brain:SetArmyStat("Economy_income_reclaimed_Energy", reclaimedEnergy - oldReclaimedEnergy)
            brain:SetArmyStat("Economy_old_Reclaimed_Energy", reclaimedEnergy)
        end
        
        WaitSeconds(.1)  -- update the stat every tick
    end
end
