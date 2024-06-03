local TArtilleryProjectile = import('/lua/terranprojectiles.lua').TArtilleryProjectile

local EffectTemplate = import('/lua/EffectTemplates.lua')

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local CreateEmitterAtEntity = CreateEmitterAtEntity

local LOUDCOS = math.cos
local LOUDSIN = math.sin

TIFFragmentationSensorShell01 = Class(TArtilleryProjectile) {

    OnImpact = function(self, TargetType, TargetEntity) 
        
        local FxFragEffect = EffectTemplate.TFragmentationSensorShellFrag 
        local ChildProjectileBP = '/projectiles/TIFFragmentationSensorShell02/TIFFragmentationSensorShell02_proj.bp'

		local CreateEmitterAtEntity = CreateEmitterAtEntity
		local LOUDCOS = LOUDCOS
		local LOUDSIN = LOUDSIN
        
        for k, v in FxFragEffect do
            CreateEmitterAtEntity( self, self.Army, v )
        end

		local numProjectiles = 4
		
		self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles
		
        local vx, vy, vz = self:GetVelocity()
        local velocity = 6
    
        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)
   		
        local angle = 6.28 / numProjectiles
        local angleInitial = RandomFloat( 0, angle )
        

        local angleVariation = angle * 0.35 	-- Adjusts angle variance spread
        local spreadMul = 0.5 					-- Adjusts the width of the dispersal        
        
        local xVec = 0 
        local yVec = vy
        local zVec = 0

        for i = 1, (numProjectiles -1) do
		
            xVec = vx + (LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
			
            local proj = self:CreateChildProjectile(ChildProjectileBP)
			
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
            proj:PassDamageData(self.DamageData)
			
        end
		
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
		
        self:Destroy()
    end,

}

TypeClass = TIFFragmentationSensorShell01