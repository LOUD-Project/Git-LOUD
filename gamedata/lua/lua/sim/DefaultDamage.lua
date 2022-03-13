---  /lua/sim/defaultdamage.lua
---  A common way to do damage other than direct damage, ie: Dots, area dots, etc.

local WaitTicks = coroutine.yield
local BeenDestroyed = moho.entity_methods.BeenDestroyed


-- damage a unit X amount repeated over a period of time
UnitDoTThread = function(instigator, unit, pulses, pulseTime, damage, damType, friendly)

	local LOUDDAMAGE = Damage
	
	local unitpos = unit:GetPosition()
	
    for i = 1, pulses do
        if unit and not BeenDestroyed(unit) then
            LOUDDAMAGE(instigator, unitpos, unit, damage, damType )
        else
            break
        end
        WaitTicks(pulseTime * 10)
    end
end

-- damage everything in an area X amount over a period of time
AreaDoTThread = function(instigator, position, pulses, pulseTime, radius, damage, damType, friendly)
	
	local LOUDDAMAGEAREA = DamageArea
	
    for i = 1, pulses do
	
        LOUDDAMAGEAREA(instigator, position, radius, damage, damType, friendly)
		
        WaitTicks(pulseTime * 10)
		
    end
end


-- SCALABLE RADIUS AREA DOT
-- Allows for a scalable damage radius that begins with DamageStartRadius and ends
-- with DamageEndRadius, interpolates between based on frequency and duration.
function ScalableRadiusAreaDoT(entity)

	local LOUDDAMAGEAREA = DamageArea
	
    local spec = entity.Spec.Data

    -- FIX ME
    -- Change this to get position from the entity, once we have the tech to set the entity's position
    -- local position = entity:GetPosition()
    local position = entity.Spec.Position
    local radius = spec.StartRadius or 0
    local freq = spec.Frequency or 1
    local dur = spec.Duration or 1
	
    if dur != freq then
	
        local reductionScalar = (radius - (spec.EndRadius or 1) ) * freq / (dur - freq)
        local duration = math.floor(dur / freq)

        for i = 1, duration do
		
            LOUDDAMAGEAREA(entity, position, radius, spec.Damage, spec.Type, spec.DamageFriendly)
			
            radius = radius - reductionScalar
            WaitTicks(freq * 10)
			
        end
		
    end
	
    entity:Destroy()
	
end
