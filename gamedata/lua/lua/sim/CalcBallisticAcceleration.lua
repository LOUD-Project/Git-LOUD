--**  File     :  /lua/sim/CalcBallisticAcceleration.lua
--**  Author(s):  Kaskouy, Brute51
--**
--**  Summary  :  Calculates bomb drop ballistic acceleration values

-- This script was done by Kaskouy and is based on my 'static' first bomb
-- bug fix. Kaskouy's code is more flexible and should work in (almost) any 
-- case wheras mine only does when the bomber flies at default height at 
-- default speed. The script below takes all that into account (speed, 
-- height, etc) and calculates the proper value to feed to the bomb adjust 
-- function. [152]

-- This is a fraction between 0 and 1, indicating which part of the target we want to hit
-- 0 : on feet ; 1 : on head
-- I personally think that 0 is better, but if you want to try, feel free to play with this...

local alpha = 0

-- This table stores the acceleration previously calculated.
-- This serves for bombers carrying several bombs: acceleration is calculated
-- for first bomb, then stored in this table and reused for the next bombs
-- format : bomber_table[entityId] = {acc, remaining_bombs}

local bomber_table = {}

-- This is the default value returned by the function if a problem occured in the calculation...
-- But normally that may never happen

local default_value = 4.9


--- this module is designed to calculate a more precise vertical velocity to insure
--- an accurate hit - originally implemented for bombs, it can apply to any projectile
--- that requires a downward velocity adjustment over basic gravity (which is the default_value)
CalculateBallisticAcceleration = function (weapon, proj)

    local Projectiles = weapon.CBFP_CalcBallAcc.ProjectilesPerOnFire or 1
    
	local launcher = proj:GetLauncher()
   
	if not launcher then return default_value end

	local LOUDSQRT  = math.sqrt
    local LOUDPOW   = math.pow

	local acc = default_value
   
	local entityId = launcher:GetEntityId()
 
	if bomber_table[entityId] then
	
		-- acceleration yet calculated
		acc = bomber_table[entityId].acc
		
		bomber_table[entityId].remaining_bombs = bomber_table[entityId].remaining_bombs - 1
      
		if bomber_table[entityId].remaining_bombs <= 0 then
			bomber_table[entityId] = nil
		end
		
	else
	
		local pos_target = {0, 0, 0}
		local wx, wy, wz = 0, 0, 0

		-- Get projectile position
		local pos_proj = proj:GetPosition()

		-- Get the target (if it's a entity)
		local target = launcher:GetTargetEntity()

        --- resolve position if it's an entity or ground fire
		if target then

			pos_target = target:GetPosition()
      
			--- Get target speed
			wx, wy, wz = target:GetVelocity()
			wx = wx * 10
			wy = wy * 10
			wz = wz * 10

		else
        
            if not weapon:BeenDestroyed() then

                pos_target = weapon:GetCurrentTargetPos()
                
            end

			--- Set alpha to 0 so we don't overshoot because of this variable
			alpha = 0
			
		end

		--- sometimes one of these is nil
		if not pos_target[1] or not pos_target[2] or not pos_target[3] then
			return default_value
		end

		--- Get height
		local unit_height = pos_target[2] - GetSurfaceHeight( pos_target[1], pos_target[3] )
      
		--- decide where we hit the target
		pos_target[2] = GetSurfaceHeight( pos_target[1], pos_target[3] ) + alpha * unit_height
      
		--- Get launcher speed; As the projectile is just dropped, this also gives the projectile speed
		local ux, uy, uz = launcher:GetVelocity()

        --- if the launcher is not moving use the projectile 
        --- of course, this may not work out as the projectile velocity may alter over the flight line
        --- however, it works well when this is calculated at some proximity to the target point
        if ux == 0 and uy == 0 and uz == 0 then
            ux, uy, uz = proj:GetVelocity()
        end

		ux = ux * 10
		uy = uy * 10
		uz = uz * 10
      
		local v_launcher = LOUDSQRT( LOUDPOW(ux,2) + LOUDPOW(uy,2) + LOUDPOW(uz,2) )
		local vhorz_launcher = LOUDSQRT( LOUDPOW(ux,2) + LOUDPOW(uz,2) )
      
		if vhorz_launcher == 0 then return default_value end
      
		--- calculate bomb speed; Don't ask me why, but it seems this is how it is calculated!
		local vx = ux * v_launcher / vhorz_launcher
		local vz = uz * v_launcher / vhorz_launcher

		--- calculate distance between projectile and target
		local dist = LOUDSQRT( LOUDPOW(pos_target[1] -  pos_proj[1], 2) +  LOUDPOW(pos_target[3] -  pos_proj[3], 2) )
      
		--- calculate the offset : this is for planes carrying several bombs. We are calculating
		--- the trajectory of first bomb, but as the result may be a carpet bomb, we try to have
		--- the target in the center of the flames, so the first bomb must fall before the target
		--- (0.1 is the delay between 2 drops) and subsequent bombs will impact just afterwards
		local offset = (Projectiles - 1) * 0.1 * (vhorz_launcher * 0.5)
      
		dist = dist - offset  --- this is not exact in some cases, but that should be good enough
      
		--- calculate height between projectile and target
		local height = pos_proj[2] - pos_target[2]
      
		--- calculate horizontal speed between projectile and target
		local vhorz = LOUDSQRT( LOUDPOW(vx-wx, 2) + LOUDPOW(vz-wz, 2) )
		
		if vhorz == 0 then return default_value end
      
		--- calculate the time after which the bomb will hit the target
		local t = dist / vhorz
		if t == 0 then return default_value end
      
		--- calculate the position of target at time t
		local pos_target_t = {0,0,0}

		pos_target_t[1] = pos_target[1] + wx * t
		pos_target_t[3] = pos_target[3] + wz * t
      
		--- because of the terrain, we don't rely on vertical speed to get the altitude...
		pos_target_t[2] = GetSurfaceHeight(pos_target_t[1], pos_target_t[3]) + alpha * unit_height
      
		--- calculate the average vertical speed
		vvert = (pos_target_t[2] - pos_target[2]) / t
      
		--- calculate ballistic acceleration so that the projectile hits the target
		acc = 2 * LOUDPOW(1/t , 2) * (height - t * vvert)
      
		--- fill bomber_table if several bombs must be dropped
		if Projectiles > 1 then
			bomber_table[entityId] = {}
			bomber_table[entityId].acc = acc
			bomber_table[entityId].remaining_bombs = Projectiles - 1
		end
	end
   
	return acc
end 