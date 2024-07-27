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

	-- This function takes a weapon's MaxRadius and MuzzleVelocity and returns a new MuzzleVelocity that ensures a weapon can fire at any target within their MaxRadius.
	local function checkMuzzleVelocity(aMaxRadius, aMuzzleVelocity, isHighArc)
		-- Muzzle Velocity may be measured in o-grids/second.
		-- A test with a Low Arc, 60 Radius weapon resulted in a Muzzle Velocity of 18 allowing the unit to fire for the full range. This was determined through manual testing of values.
		-- A similar test with a Low Arc, 114 Radius weapon resulted in a Muzzle Velocity of 38 allowing the unit to fire for the full range. This value was calculated from "MaxRadius / 3".
		
		-- Initialise our return to the given MuzzleVelocity.
		local newVelocity = aMuzzleVelocity
		
		if isHighArc ~= true then
			-- Ensure the weapon has enough MuzzleVelocity to fire at targets anywhere within the MaxRadius.
			if aMuzzleVelocity < (0.34 * aMaxRadius) then
				newVelocity = math.floor(0.34 * aMaxRadius)
			end
		else
			if aMuzzleVelocity < (2.5 * math.sqrt(aMaxRadius)) then
				newVelocity = math.floor(2.5 * math.sqrt(aMaxRadius))
			end
		end
		
		return newVelocity
	end
	
	function ModBlueprints(all_bps)
		oldModBlueprints(all_bps)
		
		-- Itterate through all units.
		for id, bp in all_bps.Unit do

			-- Check for weapons.
			if bp.Weapon then

				-- Itterate through all weapons on the unit.
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
									
									-- A Missile weapon's muzzle velocity isn't adjusted, as the Projectile over-rides the movement characteristics.
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
										local newValue = checkMuzzleVelocity(weapon.MaxRadius, weapon.MuzzleVelocity, false)
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
							local newValue = checkMuzzleVelocity(weapon.MaxRadius, weapon.MuzzleVelocity, false)
							weapon.MuzzleVelocity = newValue
						end
						
					end
					
					-- High Arcing weapons are most likely just found on Artillery units.
					if weapon.BallisticArc and weapon.BallisticArc == 'RULEUBA_HighArc' then
						local newValue = math.floor(sourceRadius * 3.5)
						weapon.MaxRadius = newValue
						
						-- Adjust the muzzle velocity.
						if weapon.MuzzleVelocity then
							local newValue = checkMuzzleVelocity(weapon.MaxRadius, weapon.MuzzleVelocity, true)
							weapon.MuzzleVelocity = newValue
							
							-- Allow Artillery to auto-adjust their muzzle velocity to units within the new range.
							weapon.MuzzleVelocityReduceDistance = weapon.MaxRadius
						end
						
						-- Adjust turret's maximum firing angle. Might look janky but it's necessary for some weapons to fire at their new range.
						weapon.TurretPitchRange = 90
					end
					
					-- Projectile Lifetime gets a bump too, in-case projectiles can't make it in the weapon's new range.
					-- Projectile Lifetime is measured in seconds, and the ProjectileLifetimeUsesMultiplier field on a weapon will use the calculation Multiplier * (Max Radius/Muzzle Velocity).
					-- A Lifetime of 0 (on the weapon) reverts the projectile to using the lifetime specified in the Projectile blueprint.
					if weapon.ProjectileLifetime and weapon.ProjectileLifetime ~= 0 then

						local newValue = math.floor(weapon.ProjectileLifetime * 3)
						weapon.ProjectileLifetime = newValue

						-- If the ProjectileLifetime isn't high enough to cover MaxRadius/MuzzleVelocity, then we set ProjectileLifetimeUsesMultiplier.
						if weapon.MuzzleVelocity and weapon.ProjectileLifetime < (weapon.MaxRadius / weapon.MuzzleVelocity) then
							-- Using ProjectileLifetimeUsesMultiplier causes ProjectileLifetime to be ignored in favor of the calculation.
							weapon.ProjectileLifetimeUsesMultiplier = 1
						end
					end
				end
			end
			
			-- Check this unit has Intel.
			if bp.Intel then
				-- Store the original vision and radar radii.
				local sourceVision = bp.Intel.VisionRadius or 10
				local sourceRadar = bp.Intel.RadarRadius or nil
				
				-- We adjust the radii depending on the unit's category, to put an emphasis on scouting.
				for i, cat in bp.Categories do
					-- Vision
					if cat == 'AIR' or cat == 'SCOUT' then
						local newValue = math.floor(sourceVision * 2.5)
						bp.Intel.VisionRadius = newValue
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
							local newValue = math.floor(sourceRadar * 2.5)
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