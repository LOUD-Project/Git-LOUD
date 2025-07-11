-- Local Weapon Files --
local WeaponFile = import('/lua/sim/defaultweapons.lua')

-- Projectiles --
local DefaultProjectileWeapon   = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon         = WeaponFile.DefaultBeamWeapon

WeaponFile = nil

-- Effects& Explosions Files --
local EffectTemplate = import('/lua/EffectTemplates.lua')

-- Custom Files --
local BattlePackEffectTemplate = import('/mods/BattlePack/lua/BattlePackEffectTemplates.lua')
local BattlePackBeamFile = import('/mods/BattlePack/lua/BattlePackCollisionBeams.lua')

PlasmaPPC                   = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash       = BattlePackEffectTemplate.BPPPlasmaPPCProjMuzzleFlash ,
    FxChargeMuzzleFlash = BattlePackEffectTemplate.BPPPlasmaPPCProjChargeMuzzleFlash,
}

CybranFlameThrower          = Class(DefaultProjectileWeapon) { 
    FxMuzzleFlash       = BattlePackEffectTemplate.CybranFlameThrowerMuzzleFlash,
	FxMuzzleFlashScale  = 1, 
}

StarAdderLaser              = Class(DefaultBeamWeapon) { BeamType = BattlePackBeamFile.StarAdderLaserCollisionBeam02,

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
