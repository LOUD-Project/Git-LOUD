-----------------------------------------------------------------------------
--  File     : /projectiles/illuminate/itacticalmissile01/itacticalmissile01_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate (SHORT RANGE) Tactical Missile: ITacticalMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SC2MultiPolyTrailProjectile = import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2MultiPolyTrailProjectile
ITacticalMissile01 = Class(import('/mods/BattlePack/lua/BattlePackDefaultProjectiles.lua').SC2MultiPolyTrailProjectile) {

        FxTrails = {
		'/mods/BattlePack/effects/emitters/w_i_mis03_p_02_fxtrail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_mis03_p_03_fxtrail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_mis03_p_05_grit_emit.bp',
        },
        PolyTrails = {
		'/mods/BattlePack/effects/emitters/w_i_mis03_p_01_polytrail_emit.bp',
		'/mods/BattlePack/effects/emitters/w_i_mis03_p_06_polytrail_emit.bp',
        },

    PolyTrailOffset = {0,0},

        FxImpactUnit = {
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_01_flash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_02_groundplasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_04_plasmasmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_07_core_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_09_lightcloud_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_10_sparks_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_11_ring_emit.bp',
        },
        FxImpactLand = {
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_01_flash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_02_groundplasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_04_plasmasmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_07_core_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_09_lightcloud_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_10_sparks_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_11_ring_emit.bp',
        },
        FxImpactWater = {
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_01_flash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_02_groundplasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_04_plasmasmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_07_core_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_09_lightcloud_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_10_sparks_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_11_ring_emit.bp',
        },
        FxImpactProp = {
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_01_flash_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_02_groundplasma_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_04_plasmasmoke_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_07_core_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_09_lightcloud_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_10_sparks_emit.bp',
			'/mods/BattlePack/effects/emitters/w_i_mis03_i_u_11_ring_emit.bp',
        },

    OnCreate = function(self)
        SC2MultiPolyTrailProjectile.OnCreate(self)
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()
        self:SetTurnRate(8)
        WaitSeconds(0.3)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > self.Distance then
        	self:SetTurnRate(75)
        	WaitSeconds(3)
        	self:SetTurnRate(8)
        	self.Distance = self:GetDistanceToTarget()
        end
        #Get the nuke as close to 90 deg as possible
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
            WaitSeconds(2)
            self:SetTurnRate(10)
        elseif dist > 30 and dist <= 50 then
						# Increase check intervals
						self:SetTurnRate(12)
						WaitSeconds(1.5)
            self:SetTurnRate(12)
        elseif dist > 10 and dist <= 25 then
						# Further increase check intervals
            WaitSeconds(0.3)
            self:SetTurnRate(50)
				elseif dist > 0 and dist <= 10 then
						# Further increase check intervals            
            self:SetTurnRate(100)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}
TypeClass = ITacticalMissile01