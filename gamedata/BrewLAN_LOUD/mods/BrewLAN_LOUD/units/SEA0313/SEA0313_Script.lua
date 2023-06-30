local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare

local TIFCruiseMissileLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileLauncher

local GinsuCollisionBeam = import('/lua/defaultcollisionbeams.lua').ParticleCannonCollisionBeam
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon

SEA0313 = Class(TAirUnit, MissileFlare) {

    Weapons = {
        ParticleCannon = Class(DefaultBeamWeapon) { BeamType = Class(GinsuCollisionBeam) {} },
        Missile = Class(TIFCruiseMissileLauncher) {},
    },

    FlareBones = {'Flare'},

    OnStopBeingBuilt = function(self,builder,layer)

        TAirUnit.OnStopBeingBuilt(self,builder,layer)

        self.WingRotors = {
            CreateRotator(self, 'Wing_001', 'z'),
            CreateRotator(self, 'Wing_002', 'z'),
        }

        self:RotateSet(self.WingRotors, -42.5)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:CreateMissileDetector()
		self:DisableUnitIntel('Stealth')
        self:RequestRefreshUI()
    end,

    RotateSet = function(self, rotors, angle)

        if not rotors then return false end

        for i, rotor in rotors do
            rotor:SetGoal(angle)
            rotor:SetSpeed(45)
        end
    end,

    OnMotionHorzEventChange = function(self, new, old)

        TAirUnit.OnMotionHorzEventChange(self, new, old)
        
        local bp = __blueprints[self.BlueprintID]

        if new == 'TopSpeed' then
            self:RotateSet(self.WingRotors, 0)
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere )

        else
            self:RotateSet(self.WingRotors, -42.5)
            self:SetCollisionShape('Sphere', bp.CollisionSphereOffsetX or 0, bp.CollisionSphereOffsetY or 0, bp.CollisionSphereOffsetZ or 0, bp.SizeSphere * .6 )
        end
    end,

    OnLayerChange = function(self, new, old)

        TAirUnit.OnLayerChange(self, new, old)

        if new == 'Land' then
            self:EnableUnitIntel('Stealth')
        else
		    self:DisableUnitIntel('Stealth')
        end
    end,
}

TypeClass = SEA0313
