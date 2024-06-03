local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFHeavyQuarnonCannon = import('/lua/seraphimweapons.lua').SDFHeavyQuarnonCannon

local SeraLambdaFieldDestroyer = import('/lua/defaultantiprojectile.lua').SeraLambdaFieldDestroyer

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRPEXTANK = Class(SWalkingLandUnit) {
    
    Weapons = {
	
        Turret = Class(SDFHeavyQuarnonCannon) { FxMuzzleFlashScale = 2.0 },
		
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

        local bp = self:GetBlueprint().Defense.LambdaDestroy01

        self.Lambda1 = SeraLambdaFieldDestroyer { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }

        self.Trash:Add(self.Lambda1)   

        self.Lambda1:Enable()        
		
        self:CreatTheEffects()
		
        self.Trash:Add(CreateRotator(self, 'Object05', 'y', nil, 120, 0, 0))
		
	end,

    CreatTheEffects = function(self)
	
        local army =  self:GetArmy()
		
        for k, v in EffectTemplate['SeraphimAirStagePlat01'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'rl01', army, v):ScaleEmitter(0.6))
            self.Trash:Add(CreateAttachedEmitter(self, 'rl01', army, v):ScaleEmitter(1.0))
            self.Trash:Add(CreateAttachedEmitter(self, 'Turret_Barrel_Muzzle01', army, v):ScaleEmitter(1.2))
            self.Trash:Add(CreateAttachedEmitter(self, 'Turret_Barrel_Muzzle', army, v):ScaleEmitter(1.2))
        end

        for k, v in EffectTemplate['UpgradeUnitAmbient'] do
            self.Trash:Add(CreateAttachedEmitter(self, 'rl01', army, v):ScaleEmitter(0.5))
        end

    end,
    
}

TypeClass = BRPEXTANK