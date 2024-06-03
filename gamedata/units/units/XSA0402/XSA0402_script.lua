local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SAALosaareAutoCannonWeapon                = SeraphimWeapons.SAALosaareAutoCannonWeapon
local SB0OhwalliExperimentalStrategicBombWeapon = SeraphimWeapons.SB0OhwalliExperimentalStrategicBombWeapon

SeraphimWeapons = nil

local CreateSeraphimExperimentalBuildBaseThread = import('/lua/EffectUtilities.lua').CreateSeraphimExperimentalBuildBaseThread
local explosion = import('/lua/defaultexplosions.lua')

XSA0402 = Class(SAirUnit) {

    DestroyNoFallRandomChance = 1.1,
    
    Weapons = {
	
        Bomb = Class(SB0OhwalliExperimentalStrategicBombWeapon) {},
        
        Autocannon = Class(SAALosaareAutoCannonWeapon) {},
		
    },
    
    ContrailEffects = {'/effects/emitters/contrail_ser_ohw_polytrail_01_emit.bp',},

    OnKilled = function(self, instigator, type, overkillRatio)
	
        self.detector = CreateCollisionDetector(self)
		
        self.Trash:Add(self.detector)
		
        self.detector:WatchBone('Nose_Extent')
        self.detector:WatchBone('Right_Wing_Extent')
        self.detector:WatchBone('Left_Wing_Extent')
        self.detector:WatchBone('Tail_Extent')
		
        self.detector:EnableTerrainCheck(true)
		
        self.detector:Enable()
        
        SAirUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,

    OnAnimTerrainCollision = function(self, bone,x,y,z)
	
        DamageArea(self, {x,y,z}, 5, 1000, 'Default', true, false)
		
        explosion.CreateDefaultHitExplosionAtBone( self, bone, 5.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})
		
    end,
    
    StartBeingBuiltEffects = function(self, builder, layer)
	
		SAirUnit.StartBeingBuiltEffects(self, builder, layer)
		
		self:ForkThread( CreateSeraphimExperimentalBuildBaseThread, builder, self.OnBeingBuiltEffectsBag )
		
    end,    
	
}

TypeClass = XSA0402