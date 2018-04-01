
local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SDFHeavyQuarnonCannon = import('/lua/seraphimweapons.lua').SDFHeavyQuarnonCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPT3ML = Class(SWalkingLandUnit) {
    
    Weapons = {
        FrontTurret = Class(SDFHeavyQuarnonCannon) {
            FxMuzzleFlashScale = 0.5,
        },
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:CreatTheEffects()   
    end,

    CreatTheEffects = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SDFSinnutheWeaponFXTrails01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'eff01', army, v):ScaleEmitter(0.15))
        end
		
        for k, v in EffectTemplate['OthuyAmbientEmanation'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'eff02', army, v):ScaleEmitter(0.12))
        end
    end,

    OnKilled = function(self, instigator, damagetype, overkillRatio)
        self:CreatTheEffectsDeath()  
        SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
    end,

    CreatTheEffectsDeath = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SDFExperimentalPhasonProjHit01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'BRPT3ML', army, v):ScaleEmitter(0.7))
        end
    end,
    
}

TypeClass = BRPT3ML