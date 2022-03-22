local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SDFUltraChromaticBeamGenerator = import('/lua/seraphimweapons.lua').SDFUltraChromaticBeamGenerator02
local SIFZthuthaamArtilleryCannon = import('/lua/seraphimweapons.lua').SIFZthuthaamArtilleryCannon
local SDFAireauWeapon = import('/lua/seraphimweapons.lua').SDFAireauWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local CleanupEffectBag = import('/lua/EffectUtilities.lua').CleanupEffectBag

BRPEXSHBM = Class( SWalkingLandUnit ) {

    IntelEffects = {
		{
			Bones = {
				'Arm01',
			},
			Offset = {
				0,
				1.6,
				0,
			},
			Scale = 0.8,
			Type = 'Jammer01',
		},
    },

    SpawnEffects = {
		'/effects/emitters/seraphim_othuy_spawn_01_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_02_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_03_emit.bp',
		'/effects/emitters/seraphim_othuy_spawn_04_emit.bp',
	},
	
    Weapons = {

        Topguns = Class(SIFZthuthaamArtilleryCannon){ FxMuzzleFlashScale = 3.0 },		

        Beam = Class(SDFUltraChromaticBeamGenerator) { FxMuzzleFlashScale = 1 },

        NoseGun = Class(SDFAireauWeapon) { },
		
        aa = Class(SDFUltraChromaticBeamGenerator) { FxMuzzleFlashScale = 1.4 },
    },

    OnKilled = function(self, instigator, damagetype, overkillRatio)
        SWalkingLandUnit.OnKilled(self, instigator, damagetype, overkillRatio)
        self:CreatTheEffectsDeath()  
    end,

    CreatTheEffectsDeath = function(self)
	
		local army =  self:GetArmy()
		
		for k, v in EffectTemplate['SLaanseMissleHit'] do
			self.Trash:Add(CreateAttachedEmitter(self, 'Arm01', army, v):ScaleEmitter(3.85))
		end	

    end,

    OnDestroy = function(self)
	
        SWalkingLandUnit.OnDestroy(self)

        -- Don't make the energy being if not built
        if self:GetFractionComplete() ~= 1 then return end
        
        -- Spawn the Energy Being
        local position = self:GetPosition()
        local spiritUnit = CreateUnitHPR('XSL0402', self:GetArmy(), position[1], position[2], position[3], 0, 0, 0)
        local spiritUnit = CreateUnitHPR('XSL0402', self:GetArmy(), position[1], position[2], position[3], 0, 0, 0)

        -- Create effects for spawning of energy being
        for k, v in self.SpawnEffects do
            CreateAttachedEmitter(spiritUnit, -1, self:GetArmy(), v)
        end
    end,
	
    OnIntelEnabled = function(self)
        SWalkingLandUnit.OnIntelEnabled(self)
        if self.IntelEffects then
			self.IntelEffectsBag = {}
			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		end
    end,

    OnIntelDisabled = function(self)
        SWalkingLandUnit.OnIntelDisabled(self)
        CleanupEffectBag(self,'IntelEffectsBag')
    end,       	
}
TypeClass = BRPEXSHBM