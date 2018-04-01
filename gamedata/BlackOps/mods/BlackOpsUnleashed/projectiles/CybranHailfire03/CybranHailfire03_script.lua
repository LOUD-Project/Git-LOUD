
local CybranHailfire03Projectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').CybranHailfire03Projectile

local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

CAANanoDart02 = Class(CybranHailfire03Projectile) {

    OnCreate = function(self)
        CybranHailfire03Projectile.OnCreate(self)
        for k, v in self.FxTrails do
            CreateEmitterOnEntity(self,self:GetArmy(),v )
        end

    end,
   
    MovementThread = function(self)        
        self.WaitTime = 0.1
        --self:SetTurnRate(8)
        WaitSeconds(0.1)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        --local dist = self:GetDistanceToTarget()
		local dist = VDist3(self:GetPosition(), self:GetCurrentTargetPosition())
		--LOG('Distance : ', dist)
		if dist > 0 and dist <= 15 then
			# Further increase check intervals            
            --self:SetTurnRate(360)   
			WaitSeconds(0.1)
			--LOG('Distance Split : ', dist)
			--ForkThread(self.OnImpact)
            --KillThread(self.MoveThread)         

			local FxFragEffect = EffectTemplate.SThunderStormCannonProjectileSplitFx 
			local ChildProjectileBP = '/mods/BlackOpsUnleashed/projectiles/CybranHailfire01child/CybranHailfire01child_proj.bp'  
              
			### Split effects
			for k, v in FxFragEffect do
			    CreateEmitterAtEntity( self, self:GetArmy(), v )
			end
			
			local vx, vy, vz = self:GetVelocity()
			local velocity = 20
		
			# One initial projectile following same directional path as the original
			#self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.ChildDamageData)
   		
			# Create several other projectiles in a dispersal pattern
			local numProjectiles = 5
			
			local angle = (2*math.pi) / numProjectiles
			local angleInitial = RandomFloat( 0, angle )
			
			# Randomization of the spread
			local angleVariation = angle * 3 # Adjusts angle variance spread
			local spreadMul = 1.75 # Adjusts the width of the dispersal        
        
			--vy= -0.8
        
			local xVec = 0
			local yVec = vy
			local zVec = 0
    
			# Launch projectiles at semi-random angles away from split location
			for i = 0, (numProjectiles -1) do
				xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
				zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
				local proj = self:CreateChildProjectile(ChildProjectileBP)
				proj:SetVelocity(xVec,yVec,zVec)
				proj:SetVelocity(velocity)
				proj:PassDamageData(self.ChildDamageData)                        
			end
        
			self:Destroy()

			end
    end,     
    PassDamageData = function(self, damageData)
        CybranHailfire03Projectile.PassDamageData(self,damageData)
        local launcherbp = self:GetLauncher():GetBlueprint()  
        self.ChildDamageData = table.copy(self.DamageData)
        self.ChildDamageData.DamageAmount = launcherbp.SplitDamage.DamageAmount or 0
        self.ChildDamageData.DamageRadius = launcherbp.SplitDamage.DamageRadius or 1   
    end,      
}

TypeClass = CAANanoDart02
