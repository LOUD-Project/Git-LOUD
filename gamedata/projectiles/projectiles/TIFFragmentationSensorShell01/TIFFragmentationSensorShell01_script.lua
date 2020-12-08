--
-- Terran Fragmentation/Sensor Shells
--
local EffectTemplate = import('/lua/EffectTemplates.lua')
local TArtilleryProjectile = import('/lua/terranprojectiles.lua').TArtilleryProjectile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local CreateEmitterAtEntity = CreateEmitterAtEntity
local LOUDCOS = math.cos
local LOUDPI = math.pi
local LOUDSIN = math.sin


TIFFragmentationSensorShell01 = Class(TArtilleryProjectile) {

    OnImpact = function(self, TargetType, TargetEntity) 
        
        local FxFragEffect = EffectTemplate.TFragmentationSensorShellFrag 
        local ChildProjectileBP = '/projectiles/TIFFragmentationSensorShell02/TIFFragmentationSensorShell02_proj.bp'

		local CreateEmitterAtEntity = CreateEmitterAtEntity
		local LOUDCOS = math.cos
		local LOUDPI = math.pi
		local LOUDSIN = math.sin		
        
        -- Split effects
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

		-- original projectile will become 4
		local numProjectiles = 4
		
		-- weapon damage is split over the projectiles
		self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles
		
        local vx, vy, vz = self:GetVelocity()
        local velocity = 6
    
		-- One initial projectile following same directional path as the original
        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)
   		
		-- Create remainder in a dispersal pattern
        local angle = (2*LOUDPI) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )
        
        -- Randomization of the spread
        local angleVariation = angle * 0.35 	-- Adjusts angle variance spread
        local spreadMul = 0.5 					-- Adjusts the width of the dispersal        
        
        local xVec = 0 
        local yVec = vy
        local zVec = 0

        -- Launch projectiles at semi-random angles away from split location
        for i = 1, (numProjectiles -1) do
		
            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
            local proj = self:CreateChildProjectile(ChildProjectileBP)
			
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
            proj:PassDamageData(self.DamageData)
			
        end
		
		-- create the vision entity on the original projectile
        local pos = self:GetPosition()
		
        local spec = {
            X = pos[1],
            Z = pos[3],
            Radius = self.Data.Radius,
            LifeTime = self.Data.Lifetime,
            Army = self.Data.Army,
            Omni = false,
            WaterVision = false,
        }
		
        local vizEntity = VizMarker(spec)
		
		-- destroy the initial projectile
        self:Destroy()
    end,
    
    

}

TypeClass = TIFFragmentationSensorShell01