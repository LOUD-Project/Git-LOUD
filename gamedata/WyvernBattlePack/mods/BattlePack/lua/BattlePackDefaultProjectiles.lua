#****************************************************************************
#**
#**  File     : /lua/defaultprojectiles.lua
#**  Author(s): John Comes, Gordon Duclos
#**
#**  Summary  : Script for default projectiles
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local Projectile = import('/lua/sim/Projectile.lua').Projectile

#---------------------------------------------------------------
# Null Shell
#---------------------------------------------------------------
NullShell = Class(Projectile) {}

#---------------------------------------------------------------
# PROJECTILE WITH ATTACHED EFFECT EMITTERS
#---------------------------------------------------------------
EmitterProjectile = Class(Projectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    FxTrailOffset = 0,

    OnCreate = function(self)
        Projectile.OnCreate(self)
        local army = self:GetArmy()
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}
#---------------------------------------------------------------
# POLY-TRAIL PROJECTILES
#---------------------------------------------------------------
SC2SinglePolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrail = '',
    PolyTrailOffset = 0,
    FxTrails = {},

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrail != '' then
            CreateTrail(self, -1, self:GetArmy(), self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
    end,
}

SC2MultiPolyTrailProjectile = Class(EmitterProjectile) {

    PolyTrails = {'/mods/BattlePack/effects/emitters/excemparraybeam01_emit.bp'},
    PolyTrailOffset = {0},
    FxTrails = {},
    RandomPolyTrails = 0,   # Count of how many are selected randomly for PolyTrail table

    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrails then
            local NumPolyTrails = table.getn( self.PolyTrails )
            local army = self:GetArmy()

            if self.RandomPolyTrails != 0 then
                local index = nil
                for i = 1, self.RandomPolyTrails do
                    index = math.floor( Random( 1, NumPolyTrails))
                    CreateTrail(self, -1, army, self.PolyTrails[index] ):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                end
            else
                for i = 1, NumPolyTrails do
                    CreateTrail(self, -1, army, self.PolyTrails[i] ):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                end
            end
        end
    end,
}
