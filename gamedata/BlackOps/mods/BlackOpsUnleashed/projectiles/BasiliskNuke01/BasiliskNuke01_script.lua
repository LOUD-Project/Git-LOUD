local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local RandomInt = import('/lua/utilities.lua').GetRandomInt
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local Util = import('/lua/utilities.lua')

local BasiliskNukeEffect04 = '/mods/BlackOpsUnleashed/projectiles/MGQAIPlasmaArty01/MGQAIPlasmaArty01_proj.bp' 
local BasiliskNukeEffect05 = '/mods/BlackOpsUnleashed/effects/Entities/BasiliskNukeEffect05/BasiliskNukeEffect05_proj.bp'


BasiliskNukeEffectController01 = Class(NullShell) {
    NukeInnerRingDamage = 0,
    NukeInnerRingRadius = 0,
    NukeInnerRingTicks = 0,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 0,
    NukeOuterRingRadius = 0,
    NukeOuterRingTicks = 0,
    NukeOuterRingTotalTime = 0,
    
    PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end
  
        self:CreateNuclearExplosion()
    end,

    CreateNuclearExplosion = function(self)
        local bp = self:GetBlueprint()
		local army = self:GetArmy()		

		# Create thread that spawns and controls effects
        self:ForkThread(self.EffectThread)
        self:ForkThread(self.CreateEffectInnerPlasma)
		--self:ForkThread(self.ForceThread)
    end,    
	
    OuterRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeOuterRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeOuterRingRadius / self.NukeOuterRingTicks )
            local tickLength = ( self.NukeOuterRingTotalTime / self.NukeOuterRingTicks )

            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeOuterRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)

            for i = 2, self.NukeOuterRingTicks do
                --print('Outer Damage Ring: MaxRadius:' .. 2*i)
                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeOuterRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,

    InnerRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeInnerRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeInnerRingRadius / self.NukeInnerRingTicks )
            local tickLength = ( self.NukeInnerRingTotalTime / self.NukeInnerRingTicks )

            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeInnerRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)
            for i = 2, self.NukeInnerRingTicks do
                #LOG('Inner Damage Ring: MaxRadius:' .. ringWidth * i)
                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,   
	
    CreateEffectInnerPlasma = function(self)
		#LOG('inner plasma')
        local vx, vy, vz = self:GetVelocity()
        local num_projectiles = 20        
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, zVec
        local offsetMultiple = 5
        local px, pz

		--WaitSeconds( 10 )
        for i = 0, (num_projectiles -1) do            
            xVec = (math.sin(angleInitial + (i*horizontal_angle)))
            zVec = (math.cos(angleInitial + (i*horizontal_angle)))
            px = 0--(offsetMultiple*xVec)
            pz = 0--(offsetMultiple*zVec)
            
            local proj = self:CreateProjectile( BasiliskNukeEffect05, px, -4, pz, xVec, 0, zVec )
            proj:SetLifetime(2.0)
            proj:SetVelocity(12.0)
            proj:SetAcceleration(-0.9)            
        end
	end,
    
    EffectThread = function(self)
        local army = self:GetArmy()
        local position = self:GetPosition()
		
		WaitSeconds(1)
		
		CreateLightParticle(self, -1, self:GetArmy(), 50, 100, 'beam_white_01', 'ramp_blue_16')
        self:ShakeCamera( 75, 3, 0, 10 )

		if (self.NukeInnerRingDamage != 0) then
			self:ForkThread(self.InnerRingDamage)
		end
        if (self.NukeOuterRingDamage != 0) then
			self:ForkThread(self.OuterRingDamage)
		end
		
        DamageRing(self, position, 0.1, 22, 1, 'Force', true)
        WaitSeconds(0.8)
        DamageRing(self, position, 0.1, 22, 1, 'Force', true)
		
        local FireballDomeYOffset = -15

        self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/BasiliskNukeEffect01/BasiliskNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        
        WaitSeconds( 1 )

        local num_projectiles = 1        
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.1        
        local px, pz       
		local py = -5
		
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 

            px = RandomFloat( 0.5, 1.0 ) * xVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )

            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end        
		
		WaitSeconds(0.1)

        local num_projectiles = 2        
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.3        
        local px, pz       
		local py = -5     
     
        for i = 0, (num_projectiles -1) do            

            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 

            px = RandomFloat( 0.5, 1.0 ) * xVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end  
		
		WaitSeconds(.5)
		
        local num_projectiles = 2       
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.5        
        local px, pz       
		local py = -5     
     
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 

            px = RandomFloat( 0.5, 1.0 ) * xVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end  
		
		WaitSeconds(0.2)

        local num_projectiles = 1        
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.7        
        local px, pz       
		local py = -5      
     
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 

            px = RandomFloat( 0.5, 1.0 ) * xVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end  
		
		WaitSeconds(0.5)
		
        local num_projectiles = 1        
        local horizontal_angle = 6.28 / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.2        
        local px, pz       
		local py = -5      
     
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.5, 1.7 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 

            px = RandomFloat( 0.5, 1.0 ) * xVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 20  ))
            proj:SetBallisticAcceleration(-9.8)            
        end  
		
		WaitSeconds(0.5)
		
		local army = self:GetArmy()
        CreateDecal(self:GetPosition(), RandomFloat(0,6.28), 'nuke_scorch_001_albedo', '', 'Albedo', 30, 30, 500, 0, army)
		
        self:ForkThread(self.CreateHeadConvectionSpinners)
    end,
    
    CreateHeadConvectionSpinners = function(self)
        local sides = 8
        local angle = 6.28 / sides
        local HeightOffset = -10
        local velocity = 1
        local OffsetMod = 10
        local projectiles = {}        

        for i = 0, (sides-1) do
            local x = math.sin(i*angle) * OffsetMod
            local z = math.cos(i*angle) * OffsetMod
            local proj = self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/BasiliskNukeEffect03/BasiliskNukeEffect03_proj.bp', x, HeightOffset, z, x, 0, z)
                :SetVelocity(velocity)
            table.insert(projectiles, proj)
        end   
    
        WaitSeconds(1)
        
        for i = 0, (sides-1) do
            local x = math.sin(i*angle)
            local z = math.cos(i*angle)
            local proj = projectiles[i+1]

            proj:SetVelocityAlign(false)
            proj:SetOrientation(OrientFromDir(Util.Cross( Vector(x,0,z), Vector(0,1,0))),true)
            proj:SetVelocity(0,3,0) 
            proj:SetBallisticAcceleration(-0.05)            
        end   
    end,

}

TypeClass = BasiliskNukeEffectController01
