do

    local oldModBlueprints = ModBlueprints

    function ModBlueprints(all_bps)

        if oldModBlueprints then
            oldModBlueprints(all_bps)
        end

        -- log all changes
        local show_log = false

		-- this controls the buildpower of factories and the buildtime of the units they build
		-- by multiplying the buildpower AND the time of the units they build, the overall impact
		-- of 'assisting' is divided - which helps to curb 'engineer spam'

		-- this effectively divides the buildpower of factories so their buildpower is NOT 1 to 1 like the engineers
		-- and is the factor which controls the difference in resource usage between factories and engineers
		-- if you reduce this value, the factories will build faster

		local factory_buildpower_ratio = 4


		-- the result of the above effectively divides the buildpower of the factorys by 4
		-- this means that a factory with a buildpower of 40 will be able to utilize 40/4 or 10 mass per tick


		--- Here is where we will try and equalize BUILD POWER for engineers building STRUCTURES
		-- using the current mass and energy costs, we calc a new buildtime using the max mass and energy
		-- we'll use the buildtime that is the longest which means we cap mass or energy at the max rate

        --loop through the blueprints and adjust as desired.
        for id,bp in pairs(all_bps.Unit) do

			if bp.Categories then

				local max_mass, max_energy
				local alt_mass, alt_energy

				for i, cat in ipairs(bp.Categories) do

					local reportflag = false

                    local oldtime = 0

                    -- structures --
					if cat == 'STRUCTURE' then

						for j, catj in ipairs(bp.Categories) do

							if catj == 'TECH1' then

								max_mass = 5
								max_energy = 50

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass * 5
									alt_energy = bp.Economy.BuildCostEnergy/max_energy * 5

									local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

									if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime
										bp.Economy.BuildTime = best_adjust
										reportflag = true
									end
								end
							end

							if catj == 'TECH2' then

								max_mass = 10
								max_energy = 100

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass * 10
									alt_energy = bp.Economy.BuildCostEnergy/max_energy * 10

									local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

									if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime
										bp.Economy.BuildTime = best_adjust
										reportflag = true
									end
								end
							end

							if catj == 'TECH3' then

								max_mass = 15
								max_energy = 150

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass * 15
									alt_energy = bp.Economy.BuildCostEnergy/max_energy * 15

									local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

									if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime
										bp.Economy.BuildTime = best_adjust
										reportflag = true
									end
								end
							end

							if catj == 'EXPERIMENTAL' then

								max_mass = 60
								max_energy = 600

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass * 60
									alt_energy = bp.Economy.BuildCostEnergy/max_energy * 60

									local best_adjust = math.ceil(math.max( 1, alt_mass, alt_energy))

									if best_adjust ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime
										bp.Economy.BuildTime = best_adjust
										reportflag = true
									end
								end
							end

                            -- factories would have immense self-upgrade speeds without this
                            if catj == 'FACTORY' then

                                -- this is not the best solution for factory upgrades since it doesn't
                                -- quite follow the rules for factory built units - but it's close enough
                                -- and reasonably balanced across the factory types

                                if bp.General.UpgradesFrom ~= nil then
                                    bp.Economy.BuildTime = bp.Economy.BuildTime * 2.75
                                end

                            end

						end

                        -- this covers MOBILE Factories - namely Cybran Eggs - which are structures themselves that produce mobile units
                        if bp.Economy.BuildUnit then
                            bp.Economy.BuildTime = bp.Economy.BuildTime * (1/2) * factory_buildpower_ratio
                        end

					end

                    -- units --
					if cat == 'MOBILE' then		-- ok lets handle all the factory built mobile units and mobile experimentals

						-- You'll notice that I allow factory built units to build with higher energy limits (scales up thru tiers - 20,30,45)
						-- this compensates somewhat for the division of their buildpower (in particular for the energy heavy air factories)
						for j, catj in ipairs(bp.Categories) do

							if catj == 'TECH1' then

								local buildpower = 40	-- default T1 factory buildpower

								max_mass = buildpower / factory_buildpower_ratio
								max_energy = (buildpower * 20) / factory_buildpower_ratio

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass		-- about 10 mass/second
									alt_energy = bp.Economy.BuildCostEnergy/max_energy	-- about 200 energy/second

									-- regardless of the mass & energy, a minimum build time of 1 second is required
									-- or else you get very wierd economy results when building the unit
									local best_adjust = math.max( 1, alt_mass, alt_energy)

									--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

									if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime

										--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

										bp.Economy.BuildTime = best_adjust

										bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

										reportflag = true
									end
                                end
							end

							if catj == 'TECH2' then

								local buildpower = 70	-- default T2 factory buildpower

								max_mass = buildpower / factory_buildpower_ratio
								max_energy = (buildpower * 30) / factory_buildpower_ratio

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass       -- about 17.5 mass/second
									alt_energy = bp.Economy.BuildCostEnergy/max_energy  -- about 525 energy/second

									local best_adjust = math.max( 1, alt_mass, alt_energy)

									if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime

										--LOG("*AI DEBUG id is "..repr(catj).." "..id.."  alt_mass is "..alt_mass.."  alt_energy is "..alt_energy.." Adjusting Buildtime from "..repr(bp.Economy.BuildTime).." to "..( best_adjust * buildpower ) )

										bp.Economy.BuildTime = best_adjust

										bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

										reportflag = true
									end
								end
							end

							if catj == 'TECH3' then

								local buildpower = 100	-- default T3 factory buildpower

								max_mass = buildpower / factory_buildpower_ratio            -- about 25 mass/second
								max_energy = (buildpower * 45) / factory_buildpower_ratio   -- about 1125 energy/second

								if bp.Economy.BuildTime then

									alt_mass =  bp.Economy.BuildCostMass/max_mass
									alt_energy = bp.Economy.BuildCostEnergy/max_energy

									local best_adjust = math.max( 1, alt_mass, alt_energy)

									if math.ceil( best_adjust * buildpower ) ~= math.ceil(bp.Economy.BuildTime) then

                                        oldtime = bp.Economy.BuildTime

										bp.Economy.BuildTime = best_adjust

										bp.Economy.BuildTime = math.ceil(bp.Economy.BuildTime * buildpower)

										reportflag = true
									end
								end
							end

							-- OK - a small problem here - No factory built experimentals - these will be the SACU built MOBILE units
                            -- as engineers they have remarkable bulidpower rates for mass compared to factories - but lower energy rates
                            -- that are only slightly improved over a T2 factory
							if catj == 'EXPERIMENTAL' then

								max_mass = 60
								max_energy = 600

								if bp.Economy.BuildTime then

									-- experimental units are not factory built so factory_buildpower_ratio is NO applied (we just use the default SACU buildpower (60)
									alt_mass =  (bp.Economy.BuildCostMass/max_mass) * 60
									alt_energy = (bp.Economy.BuildCostEnergy/max_energy) * 60

									local best_adjust = math.max( 1, alt_mass, alt_energy)

									if math.ceil( best_adjust ) ~= math.ceil(bp.Economy.BuildTime) then

										oldtime = bp.Economy.BuildTime

                                        bp.Economy.BuildTime = math.ceil(best_adjust)

										reportflag = true
									end
								end
							end
						end
					end

					if reportflag then

                        if show_log then

                            LOG("*AI DEBUG class is "..cat.." "..id.." "..bp.Description.."  alt_mass is "..repr(alt_mass).."  alt_energy is "..repr(alt_energy).." Buildtime set to "..repr(bp.Economy.BuildTime).." was "..oldtime)

                        end

						break   -- onto next unit
					end
				end
			end
        end
	end

    WikiBlueprints = ModBlueprints
end
