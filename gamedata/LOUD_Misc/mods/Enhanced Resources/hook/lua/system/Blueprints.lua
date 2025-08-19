--this function is called already in game. This gives us a hook for the 
--blueprint values of the units

--== THIS IS RESOURCE RICH NORMAL ==--

do
    local oldModBlueprints = ModBlueprints

    function ModBlueprints(all_bps)
	
		oldModBlueprints(all_bps)

        local econScale = 1.15
		local buildScale = .9
        
        LOG("LOUD Enhanced Resources being applied")
        
        --loop through the blueprints and adjust resource production.
        for id,bp in all_bps.Unit do
		
            if bp.Economy.ProductionPerSecondMass then
			
               bp.Economy.ProductionPerSecondMass = bp.Economy.ProductionPerSecondMass * econScale
			   
            end
			
            if bp.Economy.ProductionPerSecondEnergy then
			
               bp.Economy.ProductionPerSecondEnergy = bp.Economy.ProductionPerSecondEnergy * econScale
			   
            end
			
			if bp.Economy.StorageEnergy then
				
				bp.Economy.StorageEnergy = bp.Economy.StorageEnergy * econScale
				
			end

			if bp.Economy.StorageMass then
			
				bp.Economy.StorageMass = bp.Economy.StorageMass * econScale
			
			end
			
			if bp.Economy.BuildTime then
			
				bp.Economy.BuildTime = bp.Economy.BuildTime * buildScale
				
			end
			
			if bp.Economy.BuildCostEnergy then
			
				bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy * buildScale
				
			end
			
			if bp.Economy.BuildCostMass then
			
				bp.Economy.BuildCostMass = bp.Economy.BuildCostMass * buildScale
				
			end

		end
		
    end
	
end
