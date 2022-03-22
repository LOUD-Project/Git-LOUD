local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SDFHeavyQuarnonCannon = import('/lua/seraphimweapons.lua').SDFHeavyQuarnonCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT3BT = Class(SLandUnit) {

    Weapons = {
        Turret = Class(SDFHeavyQuarnonCannon) { FxMuzzleFlashScale = 0.5 },
    },

    OnStopBeingBuilt = function(self,builder,layer)
        SLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:CreatTheEffects()
    end,

    CreatTheEffects = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'muzzle', army, v):ScaleEmitter(0.12))
        end
		
        for k, v in EffectTemplate['OthuyAmbientEmanation'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'Turret', army, v):ScaleEmitter(0.08))
        end
    end,

}

TypeClass = BRPT3BT