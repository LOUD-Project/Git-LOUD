local SHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SDFOhCannon = import('/lua/seraphimweapons.lua').SDFOhCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT1HT = Class(SHoverLandUnit) {
    
    Weapons = {
        TauCannon01 = Class(SDFOhCannon){
            FxMuzzleFlashScale = 1.5,
        },
    },

    OnKilled = function(self, instigator, damagetype, overkillRatio)
        SHoverLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
        self:CreatTheEffectsDeath()
        end,

    CreatTheEffectsDeath = function(self)
        local army =  self:GetArmy()
        for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'BRPT1HT', army, v):ScaleEmitter(0.5))
        end
    end,
}
TypeClass = BRPT1HT