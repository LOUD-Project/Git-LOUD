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
--------------------------------------------------------------------------------

function MetalWorld(all_bps)

    for id, bp in all_bps do
    
        if bp.Physics.BuildRestriction == 'RULEUBR_OnMassDeposit' then

            bp.Physics.BuildRestriction = nil

            table.insert(bp.Categories, 'DRAGBUILD')
            
            if bp.General.CapCost then
                bp.General.CapCost = bp.General.CapCost * 5
            end
        end

    end
end

end
