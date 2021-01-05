do
	local oldModBlueprints = ModBlueprints
	
	function table.contains(table, element)
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
		return false
	end

	
	function ModBlueprints(all_bps)
		oldModBlueprints(all_bps)
		
		-- This test is to experiment with blanket unit changes.
		
		-- Itterate through all units.
		for id, bp in all_bps.Unit do
			-- Itterate through all weapons on the unit.
			if bp.Weapon then
				for i, weapon in bp.Weapon do
					local sourceRadius = weapon.MaxRadius

					-- Low Arc, Indirect-Fire weapons can function as High Arc weapons.
					if weapon.BallisticArc and weapon.BallisticArc == 'RULEUBA_LowArc' then
						if weapon.RangeCategory and weapon.RangeCategory == 'UWRC_IndirectFire' then
							weapon.BallisticArc = 'RULEUBA_HighArc'
							weapon.TurretPitchRange = 90
						end
					end
					
					-- We need to diffirentiate between the various weapon types that all have no ballistic arc.
					if weapon.BallisticArc and weapon.BallisticArc == 'RULEUBA_None' then
						-- Check if this is a Beam weapon or not.
						if weapon.BeamLifetime then
							-- Give beam weapons a small range bump.
							local newValue = math.floor(sourceRadius * 1.75)
							weapon.MaxRadius = newValue
							
						-- Weapons must have BeamLifetime defined, or else they aren't beams.
						else
							-- We only care about weapons with defined range categories. (This should skip Bombs/Torpedos, which don't)
							if weapon.RangeCategory then
								-- Check if this weapon is likely a Missile. (No Arc, No Beam, Indirect Fire)
								if weapon.RangeCategory == 'UWRC_IndirectFire' then
									-- Missile weapons are given a large range bump.
									local newValue = math.floor(sourceRadius * 3.5)
									weapon.MaxRadius = newValue
									
									-- Speed up the muzzle velocity of missiles to be launched faster.
									-- NOTE: This doesn't affect the missile's overall speed as that is handled by the projectile itself.
									if weapon.MuzzleVelocity then
										local newValue = math.floor(weapon.MuzzleVelocity * 3)
										weapon.MuzzleVelocity = newValue
									end
								end
								
								-- Check if the weapon could be Low Arc. (No Arc, No Beam, Direct Fire)
								if weapon.RangeCategory == 'UWRC_DirectFire' then
									-- This weapon has no arc, so give it one.
									weapon.BallisticArc = 'RULEUBA_LowArc'
								end
								
								-- Check if the weapon is Anti Air.
								if weapon.RangeCategory == 'UWRC_AntiAir' then
									-- Give AA weapons a small range bump.
									local newValue = math.floor(sourceRadius * 2)
									weapon.MaxRadius = newValue
									
									-- Adjust the muzzle velocity.
									if weapon.MuzzleVelocity then
										local newValue = math.floor(weapon.MuzzleVelocity * 2)
										weapon.MuzzleVelocity = newValue
									end
								end
								
								-- Countermeasure weapons should get a small range buff, so they aren't too powerful but can keep up with faster missiles.
								if weapon.RangeCategory == 'UWRC_Countermeasure' then
									local newValue = math.floor(sourceRadius * 1.5)
									weapon.MaxRadius = newValue
								end
							end
						end
					end
					
					-- Low Arcing weapons should, by this point, include all Direct Fire weapons not including Beams.
					if weapon.BallisticArc and weapon.BallisticArc == 'RULEUBA_LowArc' then
						local newValue = math.floor(sourceRadius * 3)
						weapon.MaxRadius = newValue
						
						-- Adjust the muzzle velocity.
						if weapon.MuzzleVelocity then
							local newValue = math.floor(weapon.MuzzleVelocity * 2.5)
							weapon.MuzzleVelocity = newValue
						end
					end
					
					-- High Arcing weapons are most likely just found on Artillery units.
					if weapon.BallisticArc and weapon.BallisticArc == 'RULEUBA_HighArc' then
						local newValue = math.floor(sourceRadius * 3.5)
						weapon.MaxRadius = newValue
						
						-- Projectiles can be unbelievably slow, this should bump their speeds up and also allow artillery pieces to reach their larger ranges.
						if weapon.MuzzleVelocity then
							local newValue = math.floor(weapon.MuzzleVelocity * 2)
							weapon.MuzzleVelocity = newValue
							-- Allow Artillery to auto-adjust their muzzle velocity to units within the new range.
							weapon.MuzzleVelocityReduceDistance = weapon.MaxRadius
						end
					end
					
					-- Projectile Lifetime gets a bump too, in-case projectiles can't make it in the weapon's new range.
					-- TODO: Work out what ProjectileLifetime is measured in and try to adjust it according to a MaxRadius vs MuzzleVelocity calculation.
					if weapon.ProjectileLifetime and weapon.ProjectileLifetime > 0 then
						local newValue = math.floor(weapon.ProjectileLifetime * 2)
						weapon.ProjectileLifetime = newValue
					end
				end
			end
			
			-- Check this unit has Intel.
			if bp.Intel then
				-- Store the original vision and radar radii.
				local sourceVision = bp.Intel.VisionRadius or 10
				local sourceRadar = bp.Intel.RadarRadius
				
				-- We adjust the radii depending on the unit's category, with Scouts having the highest adjustment.
				for i, cat in bp.Categories do
					-- Vision
					if sourceVision ~= nil then
						if cat == 'LAND' or cat == 'STRUCTURE' then
							local newValue = math.floor(sourceVision * 1.75)
							bp.Intel.VisionRadius = newValue
						end
						if cat == 'AIR' or cat == 'NAVAL' then
							local newValue = math.floor(sourceVision * 2.25)
							bp.Intel.VisionRadius = newValue
						end
						if cat == 'SCOUT' then
							local newValue = math.floor(sourceVision * 2.75)
							bp.Intel.VisionRadius = newValue
						end
					end
					-- Radar
					if sourceRadar ~= nil then
						if cat == 'LAND' or cat == 'AIR' then
							local newValue = math.floor(sourceRadar * 1.75)
							bp.Intel.RadarRadius = newValue
						end
						if cat == 'STRUCTURE' or cat == 'NAVAL' then
							local newValue = math.floor(sourceRadar * 2.25)
							bp.Intel.RadarRadius = newValue
						end
						if cat == 'SCOUT' then
							local newValue = math.floor(sourceRadar * 2.75)
							bp.Intel.RadarRadius = newValue
						end
					end
				end
			end
		end
		
		-- Itterate through all Projectiles.
		for pid, bp in all_bps.Projectile do
			-- Check the projectile has defined Categories.
			if bp.Categories then
				-- We're specifically looking for Tactical Missiles.
				if table.contains(bp.Categories, 'TACTICAL') and table.contains(bp.Categories, 'MISSILE') then
					-- Check the missile has physics properties and alter the them to be faster.
					if bp.Physics then
						if bp.Physics.Acceleration then
							local newValue = bp.Physics.Acceleration * 2
							bp.Physics.Acceleration = newValue
						end
						if bp.Physics.InitialSpeed then
							local newValue = bp.Physics.InitialSpeed * 3
							bp.Physics.InitialSpeed = newValue
						end
						if bp.Physics.MaxSpeed then
							local newValue = bp.Physics.MaxSpeed * 3
							bp.Physics.MaxSpeed = newValue
						end
						if bp.Physics.Lifetime then
							local newValue = bp.Physics.Lifetime * 2
							bp.Physics.Lifetime = newValue
						end
						if bp.Physics.TurnRate then
							local newValue = bp.Physics.TurnRate * 3
							bp.Physics.TurnRate = newValue
						end
					end
				end
			end
		end
	end
end