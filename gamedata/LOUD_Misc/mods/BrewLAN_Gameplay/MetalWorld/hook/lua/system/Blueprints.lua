--------------------------------------------------------------------------------
-- Hook File: /lua/system/blueprints.lua
--------------------------------------------------------------------------------
-- Modded By: Balthazar
--------------------------------------------------------------------------------
do

local OldModBlueprints = ModBlueprints

function ModBlueprints(all_blueprints)
    OldModBlueprints(all_blueprints)

    MetalWorld(all_blueprints.Unit)
end

--------------------------------------------------------------------------------
-- Removing build restrictions on mass extractors.
-- increasing cap cost * 5
-- increasing E consumption * 2

-- reducing cap bonus for SACU from 3 to 1

--------------------------------------------------------------------------------

function MetalWorld(all_bps)

    for id, bp in all_bps do
    
        if bp.General.CapCost == -3 then
            bp.General.CapCost = -1
        end
    
        if bp.Physics.BuildRestriction == 'RULEUBR_OnMassDeposit' then

            bp.Physics.BuildRestriction = nil

            table.insert(bp.Categories, 'DRAGBUILD')
            
            if bp.General.CapCost then
                bp.General.CapCost = bp.General.CapCost * 5
            end
            
            if bp.Economy.MaintenanceConsumptionPerSecondEnergy then
                bp.Economy.MaintenanceConsumptionPerSecondEnergy = bp.Economy.MaintenanceConsumptionPerSecondEnergy * 2
            end
        end

    end
end

end
