local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFHvyProtonCannonWeapon = import('/lua/cybranweapons.lua').CDFHvyProtonCannonWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

SRB2402 = Class(CStructureUnit) {
    Weapons = {
        ParticleGun = Class(CDFHvyProtonCannonWeapon) {},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
    
        CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        local bp = self:GetBlueprint().Defense.AntiMissile
        
        local antiMissile = MissileRedirect {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
        
        self.Trash:Add(antiMissile)
    end,
    
}

TypeClass = SRB2402
