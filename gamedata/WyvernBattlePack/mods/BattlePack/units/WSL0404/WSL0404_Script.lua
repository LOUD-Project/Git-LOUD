local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/seraphimweapons.lua')

local SDFExperimentalPhasonProj = WeaponsFile.SDFExperimentalPhasonProj
local SDFUltraChromaticBeamGenerator = WeaponsFile.SDFUltraChromaticBeamGenerator
local SAAShleoCannonWeapon = WeaponsFile.SAAShleoCannonWeapon

local EffectUtil = import('/lua/EffectUtilities.lua')

WSL0404 = Class(SLandUnit) {

    Weapons = {
	    MainWeapon = Class(SDFExperimentalPhasonProj) {},
        RightTurret = Class(SDFUltraChromaticBeamGenerator) {},
        AAGun = Class(SAAShleoCannonWeapon) {
            FxMuzzleScale = 2.25,
        },
    },
	
	StartBeingBuiltEffects = function(self, builder, layer)
		SLandUnit.StartBeingBuiltEffects(self, builder, layer)
		self:ForkThread( EffectUtil.CreateSeraphimExperimentalBuildBaseThread, builder, self.OnBeingBuiltEffectsBag )
    end,   
	
	OnStopBeingBuilt = function(self, builder, layer)
        SLandUnit.OnStopBeingBuilt(self, builder, layer)
        self.Trash:Add(CreateAttachedEmitter(self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'))
        self.Trash:Add(AttachBeamEntityToEntity(self, 'Beam_Emitter', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_01_emit.bp'):ScaleEmitter(2.0))
        self.Trash:Add(AttachBeamEntityToEntity(self, 'Beam_Point001', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_02_emit.bp'))
		
		self.Trash:Add(AttachBeamEntityToEntity(self, 'MiniBeam001', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_01_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'MiniBeam002', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_01_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'MiniBeam003', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_01_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'MiniBeam004', self, 'Energy_Sphere', self:GetArmy(), '/effects/emitters/reacton_cannon_beam_01_emit.bp'))
		
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_Left001', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_Left002', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_Right001', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_Right002', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_FrontRight', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))
		self.Trash:Add(CreateAttachedEmitter(self, 'PowerOrb_FrontLeft', self:GetArmy(), '/effects/emitters/quark_bomb2_02_emit.bp'):ScaleEmitter(0.5))

		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb_Left001', self, 'PowerOrb_Left002', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb_Left002', self, 'PowerOrb', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb_Right001', self, 'PowerOrb_Right002', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb_Right002', self, 'PowerOrb', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb', self, 'PowerOrb_FrontRight', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		self.Trash:Add(AttachBeamEntityToEntity(self, 'PowerOrb', self, 'PowerOrb_FrontLeft', self:GetArmy(), '/mods/BattlePack/effects/emitters/seratank_beam_emit.bp'))
		
    end,

    OnDestroy = function(self)
    	if self.Trash then
            self.Trash:Destroy()
        end
    end,
}
TypeClass = WSL0404
