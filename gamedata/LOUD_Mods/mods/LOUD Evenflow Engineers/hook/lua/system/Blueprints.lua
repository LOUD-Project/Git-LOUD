do

    local oldModBlueprints = ModBlueprints
	
    function ModBlueprints(all_bps)
	
	    oldModBlueprints(all_bps)
		
		-- this controls the buildpower of factories and the buildtime of the units they build
		-- by multiplying the buildpower AND the time of the units they build, the overall impact
		-- of 'assisting' is divided - which helps to curb 'engineer spam'
		local buildratemod = 2
		
		-- this effectively divides the buildpower of factories so their buildpower is NOT 1 to 1 like the engineers
		-- and is the factor which controls the difference in resource usage between factories and engineers 
		-- if you reduce this value, the factories will build faster
		local factory_buildpower_ratio = 2.5
		
		-- the result of the above 2 numbers (2 * 2.5) effectively divides the buildpower of the factorys by 5
		-- this means that a factory with a buildpower of 40 (ie. T1 is 20 but doubled by the buildratemod) will be able
		-- to utilize 40/5 or 8 mass per tick

		
		--- Here is where we will try and equalize BUILD POWER for engineers building STRUCTURES 
		-- using the current mass and energy costs, we calc a new buildtime using the max mass and energy
		-- we'll use the buildtime that is the longest which means we cap mass or energy at the max rate
		
        --loop through the blueprints and adjust as desired.
        for id,bp in all_bps.Unit do
		
			if bp.Categories then
		
				for i, cat in bp.Categories do
			
					if cat == 'STRUCTURE' then
			
						for j, catj in bp.Categories do
					
							if catj == 'TECH1' then
						
								local max_mass = 5
								local max_energy = 50
				
								if bp.Economy.BuildTime then

									local alt_mass =  bp.Economy.BuildCostMass/max_mass * 5
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy * 5
								
									local best_adjust = math.max(alt_mass, alt_energy)
								
									bp.Economy.BuildTime = math.floor(best_adjust)
								end
							end
					
							if catj == 'TECH2' then
						
								local max_mass = 10
								local max_energy = 100
							
								if bp.Economy.BuildTime then

									local alt_mass =  bp.Economy.BuildCostMass/max_mass * 10
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy * 10									
								
									local best_adjust = math.max(alt_mass, alt_energy)

									bp.Economy.BuildTime = math.floor(best_adjust)						
								end
							end
						
							if catj == 'TECH3' then
						
								local max_mass = 15
								local max_energy = 150
							
								if bp.Economy.BuildTime then

									local alt_mass =  bp.Economy.BuildCostMass/max_mass * 15
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy * 15
								
									local best_adjust = math.max(alt_mass, alt_energy)

									bp.Economy.BuildTime = math.floor(best_adjust)
								end
							end

							if catj == 'EXPERIMENTAL' then
						
								local max_mass = 60
								local max_energy = 600

								if bp.Economy.BuildTime then
								
									local alt_mass =  bp.Economy.BuildCostMass/max_mass * 60
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy * 60

									local best_adjust = math.max(alt_mass, alt_energy)

									bp.Economy.BuildTime = math.floor(best_adjust)
								end
							end
						end
						
						-- modify any FACTORY STRUCTURE build power and the time required to upgrade (so that upgrades remain constant)
						-- the only one this doesn't properly catch is T3 factories directly built by SUBCOMMANDERS but that's not so bad
						if table.find(bp.Categories, 'FACTORY') then
					
							for j, catj in bp.Categories do
						
								if catj == 'TECH1' then
							
									if bp.Economy.BuildRate then
										bp.Economy.BuildRate = bp.Economy.BuildRate * buildratemod
										break
									end
							
								elseif catj == 'TECH2' or catj == 'TECH3' then
							
									if bp.Economy.BuildRate then
										bp.Economy.BuildRate = bp.Economy.BuildRate * buildratemod
										bp.Economy.BuildTime = bp.Economy.BuildTime * buildratemod
										break
									end
								end
							end
						end
					end
					
					
					

					if cat == 'MOBILE' then		-- ok lets handle all the factory built units and mobile experimentals
					
						-- You'll notice that I allow factory built units to build with higher energy limits (scales up thru tiers - 20,28,36)
						-- this compensates somewhat for the division of their buildpower (in particular for the energy heavy air factories)
						for j, catj in bp.Categories do
					
							if catj == 'TECH1' then
								
								local buildpower = 20	-- default T1 factory buildpower
								local max_mass = buildpower / factory_buildpower_ratio
								local max_energy = (buildpower * 20) / factory_buildpower_ratio
				
								if bp.Economy.BuildTime then

									local alt_mass =  bp.Economy.BuildCostMass/max_mass
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy
								
									local best_adjust = math.max(alt_mass, alt_energy)

									bp.Economy.BuildTime = math.floor(best_adjust)
									
									bp.Economy.BuildTime = bp.Economy.BuildTime * buildpower * buildratemod
								end
							end
					
							if catj == 'TECH2' then
								
								local buildpower = 35	-- default T2 factory buildpower
								local max_mass = buildpower / factory_buildpower_ratio
								local max_energy = (buildpower * 28) / factory_buildpower_ratio
							
								if bp.Economy.BuildTime then
									
									local alt_mass =  bp.Economy.BuildCostMass/max_mass
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy
								
									local best_adjust = math.max(alt_mass, alt_energy)
									
									bp.Economy.BuildTime = math.floor(best_adjust)
									
									bp.Economy.BuildTime = bp.Economy.BuildTime * buildpower * buildratemod
								end
							end
						
							if catj == 'TECH3' then
								
								local buildpower = 50	-- default T3 factory buildpower
								local max_mass = buildpower / factory_buildpower_ratio
								local max_energy = (buildpower * 36) / factory_buildpower_ratio
							
								if bp.Economy.BuildTime then

									local alt_mass =  bp.Economy.BuildCostMass/max_mass
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy
								
									local best_adjust = math.max(alt_mass, alt_energy)
								
									bp.Economy.BuildTime = math.floor(best_adjust)
									
									bp.Economy.BuildTime = bp.Economy.BuildTime * buildpower * buildratemod
								end
							end
							
							-- OK - a small problem here - No factory built experimentals - so why do I allow MOBILE EXPERIMENTALS to be built with
							-- higher caps than STRUCTURE EXPERIMENTALS ?
							-- Technically I should be using the SUBCOMMANDER limits from the STRUCTURE section of this mod which would be
							-- 48 and 600 - so I do
							if catj == 'EXPERIMENTAL' then
						
								local max_mass = 60
								local max_energy = 600

								if bp.Economy.BuildTime then
									
									-- experimental units are not factory built so no buildratemod is applied (we just use the default SUBCOM build power (60)
									local alt_mass =  bp.Economy.BuildCostMass/max_mass * 60
									local alt_energy = bp.Economy.BuildCostEnergy/max_energy * 60									
								
									local best_adjust = math.max(alt_mass, alt_energy)

									bp.Economy.BuildTime = math.floor(best_adjust)
								end
							end
						end
					end
				end
			end
        end
	end
end
