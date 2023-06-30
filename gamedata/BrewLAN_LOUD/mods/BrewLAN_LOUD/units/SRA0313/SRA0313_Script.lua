local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CDFParticleCannonWeapon = import('/lua/cybranweapons.lua').CDFParticleCannonWeapon

SRA0313 = Class(CAirUnit) {

    ExhaustBones = { 'Exhaust', },
    ContrailBones = { 'Tip_001', 'Tip_009', },
	
    Weapons = {
        Laser = Class(CDFParticleCannonWeapon) {},
    },
	
    OnStopBeingBuilt = function(self,builder,layer)
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
		self:DisableUnitIntel('Cloak')
        self:RequestRefreshUI()
    end,

    OnLayerChange = function(self, new, old)
	
        CAirUnit.OnLayerChange(self, new, old)
		
        if new == 'Land' then
            self:EnableUnitIntel('Cloak')
        else
		    self:DisableUnitIntel('Cloak')
        end
		
    end,

    OnMotionHorzEventChange = function(self, new, old)

        CAirUnit.OnMotionHorzEventChange(self, new, old)
        
        local bp = __blueprints[self.BlueprintID]

        if new == 'TopSpeed' then
            LOG("*AI DEBUG SRA0313 Full Sphere TopSpeed "..bp.SizeSphere)
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere )
        else
            LOG("*AI DEBUG SRA0313 Reduced Sphere "..new.." "..bp.SizeSphere * .65)
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere * .6 )
        end
    end,

}

TypeClass = SRA0313
