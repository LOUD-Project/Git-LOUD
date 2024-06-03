-- Local Weapon Files --
local WeaponFile = import('/lua/sim/defaultweapons.lua')

-- Projectiles --
local DefaultProjectileWeapon   = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon         = WeaponFile.DefaultBeamWeapon

-- Collision Beams --
local CollisionBeamFile = import('/lua/defaultcollisionbeams.lua')

local DisruptorBeamCollisionBeam        = CollisionBeamFile.DisruptorBeamCollisionBeam
local PhasonLaserCollisionBeam          = CollisionBeamFile.PhasonLaserCollisionBeam
local QuantumBeamGeneratorCollisionBeam = CollisionBeamFile.QuantumBeamGeneratorCollisionBeam
local TractorClawCollisionBeam          = CollisionBeamFile.TractorClawCollisionBeam
local ZapperCollisionBeam               = CollisionBeamFile.ZapperCollisionBeam

WeaponFile = nil
CollisionBeamFile = nil

-- Effects& Explosions Files --
local EffectTemplate = import('/lua/EffectTemplates.lua')

-- Custom Files --
local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')
local BattlePackBeamFile = import('/mods/BattlePack/lua/BattlePackCollisionBeams.lua')



ExWifeMaincannonWeapon01            = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_01_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_02_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_03_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_04_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_05_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_06_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_07_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_cannon_muzzle_08_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_hit_10_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_flash_01_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_flash_02_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_flash_03_emit.bp',
	},
    FxChargeMuzzleFlash = {
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_charge_01_emit.bp',
		'/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_charge_02_emit.bp',
        '/mods/BattlePack/effects/emitters/ExWifeMaincannon_muzzle_charge_05_emit.bp',
    },

	FxMuzzleFlashScale = 3,
	FxChargeMuzzleFlashScale = 5,
}

TDFAlternatePlasmaCannonWeapon      = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TPlasmaCannonHeavyMuzzleFlash,
	FxMuzzleFlashScale = 0.5,
}

BPPPlasmaPPCProj                    = Class(DefaultProjectileWeapon) { FxMuzzleFlash = BattlePackEffectTemplate.BPPPlasmaPPCProjMuzzleFlash ,
    FxChargeMuzzleFlash = BattlePackEffectTemplate.BPPPlasmaPPCProjChargeMuzzleFlash,
}

UDisruptorArtillery01               = Class(DefaultProjectileWeapon) { FxMuzzleFlash = BattlePackEffectTemplate.UDisruptorArtillery01MuzzleFlash}

CybranFlameThrower                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = BattlePackEffectTemplate.CybranFlameThrowerMuzzleFlash,
	FxMuzzleFlashScale = 1, 
}


AAMicrowaveLaserGenerator           = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.AAMicrowaveLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

EXCEMPArrayBeam01                   = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.EXCEMPArrayBeam01CollisionBeam}

StarAdderLaser                      = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.StarAdderLaserCollisionBeam02,

    PlayFxWeaponUnpackSequence = function( self )
        if not self:EconomySupportsBeam() then return end
        local army = self.unit:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in self.FxUpackingChargeEffects do
            for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do 
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)  
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

--[[

MechCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.CElectronBolterMuzzleFlash01,
    FxShellEject  = BattlePackEffectTemplate.CannonGunShells,

    PlayFxMuzzleSequence = function(self, muzzle)
		DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
		for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, self:GetBlueprint().ShellEjection, self.unit:GetArmy(), v)
        end
    end,
}

MechCannonWeapon02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TLandGaussCannonFlash,
    FxShellEject  = BattlePackEffectTemplate.CannonGunShells,

    PlayFxMuzzleSequence = function(self, muzzle)
		DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
		for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, self:GetBlueprint().TurretBoneMuzzle, self.unit:GetArmy(), v)
        end
    end,
}

RagnarokLavaCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BattlePackEffectTemplate.TMagmaCannonMuzzleFlash,
	FxMuzzleFlashScale = 1.25,
}

WyvernLaserWeapon = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.WyvernLaserWeaponCollisionBeam,
    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 0.5,

    PlayFxWeaponUnpackSequence = function( self )
        local army = self.unit:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in self.FxUpackingChargeEffects do
            for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

SC2DisruptorWeapon02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BattlePackEffectTemplate.SC2DisruptorMuzzleFlash02,
	FxMuzzleFlashScale = 0.5, 
    FxChargeMuzzleFlash = BattlePackEffectTemplate.SC2DisruptorChargeMuzzleFlash02,
	FxChargeMuzzleFlashScale = 0.5, 
}

AdaptorZapperWeapon = Class(DefaultBeamWeapon) { BeamType = ZapperCollisionBeam,
    FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp',},

    SphereEffectIdleMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere01_mesh',
    SphereEffectActiveMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere02_mesh',
    SphereEffectBp = '/effects/emitters/zapper_electricity_01_emit.bp',
    SphereEffectBone = 'Turret_Muzzle',
    
    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)

        self.SphereEffectEntity = import('/lua/sim/Entity.lua').Entity()
        self.SphereEffectEntity:AttachBoneTo( -1, self.unit,self:GetBlueprint().RackBones[1].MuzzleBones[1] )
        self.SphereEffectEntity:SetMesh(self.SphereEffectIdleMesh)
        self.SphereEffectEntity:SetDrawScale(0.3)
        self.SphereEffectEntity:SetVizToAllies('Intel')
        self.SphereEffectEntity:SetVizToNeutrals('Intel')
        self.SphereEffectEntity:SetVizToEnemies('Intel')
        
        local emit = CreateAttachedEmitter( self.unit, self:GetBlueprint().RackBones[1].MuzzleBones[1], self.unit:GetArmy(), self.SphereEffectBp )

        self.unit.Trash:Add(self.SphereEffectEntity)
        self.unit.Trash:Add(emit)
    end,

    IdleState = State (DefaultBeamWeapon.IdleState) {
        Main = function(self)
            DefaultBeamWeapon.IdleState.Main(self)
        end,

        OnGotTarget = function(self)
            DefaultBeamWeapon.IdleState.OnGotTarget(self)
            self.SphereEffectEntity:SetMesh(self.SphereEffectActiveMesh)
        end,
    },

    OnLostTarget = function(self)
        DefaultBeamWeapon.OnLostTarget(self)
        self.SphereEffectEntity:SetMesh(self.SphereEffectIdleMesh)
    end,    
}

CybranChronoDampener = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BattlePackEffectTemplate.CChronoDampener,
    FxMuzzleFlashScale = 0.5,

    CreateProjectileAtMuzzle = function(self, muzzle)
    end,
}

GaussCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TGaussCannonFlash,
		FxMuzzleScale = 0.05,
	
}

HeavyMicrowaveLaser = Class(DefaultBeamWeapon) {
    BeamType = BattlePackBeamFile.HeavyMicrowaveLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

SeraphimPhasonLaser = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.SeraphimPhasonLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.33,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

SC2PhasonLaser = Class(DefaultBeamWeapon) {
    BeamType = BattlePackBeamFile.SC2CollosusCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

TWZapperWeapon = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.ZapperCollisionBeam02,
    FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp',},

    SphereEffectIdleMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere01_mesh',
    SphereEffectActiveMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere02_mesh',
    SphereEffectBp = '/effects/emitters/zapper_electricity_01_emit.bp',
    SphereEffectBone = 'Turret_Muzzle',
    
    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)

        self.SphereEffectEntity = import('/lua/sim/Entity.lua').Entity()
        self.SphereEffectEntity:AttachBoneTo( -1, self.unit,self:GetBlueprint().RackBones[1].MuzzleBones[1] )
        self.SphereEffectEntity:SetMesh(self.SphereEffectIdleMesh)
        self.SphereEffectEntity:SetDrawScale(0.3)
        self.SphereEffectEntity:SetVizToAllies('Intel')
        self.SphereEffectEntity:SetVizToNeutrals('Intel')
        self.SphereEffectEntity:SetVizToEnemies('Intel')
        
        local emit = CreateAttachedEmitter( self.unit, self:GetBlueprint().RackBones[1].MuzzleBones[1], self.unit:GetArmy(), self.SphereEffectBp )

        self.unit.Trash:Add(self.SphereEffectEntity)
        self.unit.Trash:Add(emit)
    end,

    IdleState = State (DefaultBeamWeapon.IdleState) {
        Main = function(self)
            DefaultBeamWeapon.IdleState.Main(self)
        end,

        OnGotTarget = function(self)
            DefaultBeamWeapon.IdleState.OnGotTarget(self)
            self.SphereEffectEntity:SetMesh(self.SphereEffectActiveMesh)
        end,
    },

    OnLostTarget = function(self)
        DefaultBeamWeapon.OnLostTarget(self)
        self.SphereEffectEntity:SetMesh(self.SphereEffectIdleMesh)
    end,    
}

ZapperCollisionBeam02 = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.ZapperCollisionBeam02 }

SC2ACUPhasonLaser = Class(DefaultBeamWeapon) {
    BeamType = BattlePackBeamFile.SC2ACUCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

SC2ZephyrCannonWeapon = Class(DefaultProjectileWeapon) { FxMuzzleFlash = BattlePackEffectTemplate.SC2ACUMuzzleFlash,
	FxMuzzleFlashScale = 0.3, 
}

--]]