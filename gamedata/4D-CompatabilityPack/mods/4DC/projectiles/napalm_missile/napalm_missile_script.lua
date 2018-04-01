-----------------------------------------------------------------------------
--  File     : /mods/4DC/projectiles/napalm_missile/napalm_missile_script.lua
--
--  Author(s): EbolaSoup, Resin Smoker, Optimus Prime, Vissroid 
--
--  Special Thanks to : Exavier_Macbeth
--
--  Summary  : Terran Napalm Missile
--
--  Copyright © 2010 4DC  All rights reserved.
-----------------------------------------------------------------------------

-- Misc Local files
local NapalmMissileProjectile = import('/mods/4DC/lua/4d_projectiles.lua').NapalmMissileProjectile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

Napalm_Missile = Class(NapalmMissileProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_06_emit.bp',
        
    OnCreate = function(self)   
        NapalmMissileProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        self.Army = self:GetArmy()
        self:ForkThread(self.UpdateMeshThread)
    end,

    UpdateMeshThread = function(self)
        if not self:BeenDestroyed() then
            -- Small delay before allowing fins to activate and to allow the missiles to climb before tracking is enabled
            -- The amount of delay is based upon how close the missile is to the target at the time of launch           
            local delay = 0           
            if self:GetTrackingTarget() then
                local dist = self:GetDistanceToTarget()
                delay = dist * 0.3
            end    
            
            -- Normalize the delay values           
            if delay < 0.5 then
                delay = 0.5
            elseif delay > 5 then
                delay = 5
            end      
            WaitSeconds(delay)
            
            if not self:BeenDestroyed() then
                -- Change mesh so fins show
                self:SetMesh('/mods/4DC/projectiles/napalm_missile/napalm_missile_UnPacked01_mesh')
                -- Polytrails offset to wing tips
                CreateTrail(self, -1, self.Army, self.PolyTrail ):OffsetEmitter(0.075, -0.05, 0.25)
                CreateTrail(self, -1, self.Army, self.PolyTrail ):OffsetEmitter(-0.085, -0.055, 0.25)
                CreateTrail(self, -1, self.Army, self.PolyTrail ):OffsetEmitter(0, 0.09, 0.25)       
                -- Enable Turn Rates
                self:SetTurnRate(120) 
            end
        end 
    end,

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,

    OnImpact = function(self, TargetType, targetEntity)
        if TargetType == 'Terrain' then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(3.0,5.0)
            CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 20, self.Army)
        elseif TargetType == 'Unit' then     
            -- No effects chosen
        elseif TargetType == 'Water' then 
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(2.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/destruction_underwater_explosion_flash_02_emit.bp'):ScaleEmitter(2.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/water_splash_plume_01_emit.bp'):ScaleEmitter(1.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/water_splash_plume_02_emit.bp'):ScaleEmitter(1.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/water_splash_ripples_ring_01_emit.bp'):ScaleEmitter(5.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/water_splash_ripples_ring_02_emit.bp'):ScaleEmitter(5.0)
            CreateAttachedEmitter(self, 'RocketMeson01', self:GetArmy(), '/effects/emitters/underwater_bubbles_01_emit.bp'):ScaleEmitter(2.0)         
        end	 
        NapalmMissileProjectile.OnImpact( self, TargetType, targetEntity )
    end,

}
TypeClass = Napalm_Missile