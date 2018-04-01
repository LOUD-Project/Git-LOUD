local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SDFBombOtheWeapon = import('/lua/seraphimweapons.lua').SDFBombOtheWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPAT2BOMBER = Class(SAirUnit) {
    
    Weapons = {
        Bomb = Class(SDFBombOtheWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        SAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:CreatTheEffects()
    end,

    CreatTheEffects = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'Effect01', army, v):ScaleEmitter(0.15))
        end
		
        for k, v in EffectTemplate['OthuyAmbientEmanation'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'Gauche_Projectile02', army, v):ScaleEmitter(0.05))
        end
		
    end,   
}

TypeClass = BRPAT2BOMBER
