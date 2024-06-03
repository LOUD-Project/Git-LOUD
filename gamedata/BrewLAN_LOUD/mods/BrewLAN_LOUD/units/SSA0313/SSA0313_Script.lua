local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SAALosaareAutoCannonWeapon    = SeraphimWeapons.SAALosaareAutoCannonWeaponAirUnit
local SDFUnstablePhasonBeam         = SeraphimWeapons.SDFUltraChromaticBeamGenerator02

SeraphimWeapons = nil

SSA0313 = Class(SAirUnit, MissileFlare) {
    Weapons = {
        AutoCannon = Class(SAALosaareAutoCannonWeapon) {},
        PhasonBeam = Class(SDFUnstablePhasonBeam) {},
    },

    FlareBones = {'Smol_Ring'},

    OnStopBeingBuilt = function(self,builder,layer)
        SAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:CreateMissileDetector()
		self:DisableUnitIntel('Cloak')
        self:RequestRefreshUI()
    end,

    OnLayerChange = function(self, new, old)

        SAirUnit.OnLayerChange(self, new, old)

        if new == 'Land' then
            self:EnableUnitIntel('Cloak')
        else
		    self:DisableUnitIntel('Cloak')
        end
    end,

    OnMotionHorzEventChange = function(self, new, old)

        SAirUnit.OnMotionHorzEventChange(self, new, old)
        
        local bp = __blueprints[self.BlueprintID]

        if new == 'TopSpeed' then
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere )
        else
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere * .6 )
        end
    end,

}

TypeClass = SSA0313
