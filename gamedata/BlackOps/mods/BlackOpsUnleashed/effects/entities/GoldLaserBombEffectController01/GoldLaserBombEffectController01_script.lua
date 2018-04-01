#**  File     :  \data\effects\Entities\GoldLaserBombEffectController01\GoldLaserBombEffectController01_script.lua
#**  Author(s):  Greg Kohne
#**  Summary  :  Ohwalli Bomb effect controller script, non-damaging
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local RandomInt = import('/lua/utilities.lua').GetRandomInt
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local BaseRingRiftEffects = {
	'/mods/BlackOpsUnleashed/effects/Entities/GoldLaserBombEffect03/GoldLaserBombEffect03_proj.bp',
	'/mods/BlackOpsUnleashed/effects/Entities/GoldLaserBombEffect04/GoldLaserBombEffect04_proj.bp',
	'/mods/BlackOpsUnleashed/effects/Entities/GoldLaserBombEffect05/GoldLaserBombEffect05_proj.bp',
}         
local GoldLaserBombEffect01 = '/mods/BlackOpsUnleashed/effects/Entities/GoldLaserBombEffect01/GoldLaserBombEffect01_proj.bp'         
local GoldLaserBombEffect06 = '/mods/BlackOpsUnleashed/effects/Entities/GoldLaserBombEffect06/GoldLaserBombEffect06_proj.bp'

GoldLaserBombEffectController01 = Class(NullShell) {
    NukeInnerRingDamage = 2000,
    NukeInnerRingRadius = 2,
    NukeInnerRingTicks = 1,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 650,
    NukeOuterRingRadius = 8,
    NukeOuterRingTicks = 1,
    NukeOuterRingTotalTime = 0,
    
    OnCreate = function( self )  
		NullShell.OnCreate(self)
		local army = self:GetArmy()

        self:ForkThread(self.MainBlast, army)
        self:ForkThread(self.InnerRingDamage)
        self:ForkThread(self.OuterRingDamage)
    end,
	
	PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end

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
                #print('Damage Ring: MaxRadius:' .. 2*i)
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
                #LOG('Damage Ring: MaxRadius:' .. ringWidth * i)
                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,   
    
    MainBlast = function( self, army )
		#WaitSeconds(2.5)
		
        -- Create a light for this thing's flash.
        CreateLightParticle(self, -1, self:GetArmy(), 10, 8, 'flare_lens_add_03', 'ramp_white_07' )
        
        -- Create our decals
        CreateDecal( self:GetPosition(), RandomFloat(0.0,6.28), 'Scorch_012_albedo', '', 'Albedo', 9, 9, 100, 25, self:GetArmy())          

		-- Create explosion effects
        for k, v in BlackOpsEffectTemplate.GoldLaserBombDetonate01 do
            emit = CreateEmitterAtEntity(self,army,v):ScaleEmitter(0.2)
        end
        
        self:CreatePlumes()
        
        ###self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
        --self:ShakeCamera( 7, 2.5, 0, 0.7 )        

		--WaitSeconds(0.3)
		
        --[[
        
        # Create explosion dust ring
        local vx, vy, vz = self:GetVelocity()
        local num_projectiles = 16        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, zVec
        local offsetMultiple = 2.0
        local px, pz

        for i = 0, (num_projectiles -1) do            
            xVec = (math.sin(angleInitial + (i*horizontal_angle)))
            zVec = (math.cos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)
            
            local proj = self:CreateProjectile( GoldLaserBombEffect06, px, 1, pz, xVec, 0, zVec )
            proj:SetLifetime(2.0)
            proj:SetVelocity(5.0)
            proj:SetAcceleration(-5.0)            
        end
		]]--
    end,
    
    CreatePlumes = function(self)
        # Create fireball plumes to accentuate the explosive detonation
        local num_projectiles = 12        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.5        
        local px, py, pz        
     
        for i = 0, (num_projectiles -1) do
		
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.7, 2.8 ) + 2.0
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            px = RandomFloat( 0.5, 1.0 ) * xVec
            py = RandomFloat( 0.5, 1.0 ) * yVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( GoldLaserBombEffect01, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 2, 10  ))
            proj:SetBallisticAcceleration(-4.8)            
        end        
    end,
}
TypeClass = GoldLaserBombEffectController01
