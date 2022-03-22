local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT1EXM1 = Class(SWalkingLandUnit) {

    Weapons = {
        TauCannon01 = Class(SDFThauCannon){
            FxMuzzleFlashScale = 0.5,
        },
    },

    OnKilled = function(self, instigator, damagetype, overkillRatio)
        SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
        self:CreatTheEffectsDeath()
    end,

    CreatTheEffectsDeath = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'Turreta', army, v):ScaleEmitter(0.65))
        end
    end,

}

TypeClass = BRPT1EXM1