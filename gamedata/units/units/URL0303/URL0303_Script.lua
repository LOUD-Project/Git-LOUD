local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Weapon = import('/lua/sim/Weapon.lua').Weapon
local cWeapons = import('/lua/cybranweapons.lua')

local CDFLaserDisintegratorWeapon = cWeapons.CDFLaserDisintegratorWeapon01
local CDFElectronBolterWeapon = cWeapons.CDFElectronBolterWeapon
local EMPDeathWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect
--[[
local EMPDeathWeapon = Class(Weapon) {

    OnCreate = function(self)
        Weapon.OnCreate(self)
        self:SetWeaponEnabled(false)
    end,

    OnFire = function(self)
    
        local blueprint = self:GetBlueprint()
        
        DamageArea(self.unit, self.unit:GetPosition(), blueprint.DamageRadius,
                   blueprint.Damage, blueprint.DamageType, blueprint.DamageFriendly)
    end,
}
--]]
URL0303 = Class(CWalkingLandUnit) {

    PlayEndAnimDestructionEffects = false,

    Weapons = {

        Disintigrator = Class(CDFLaserDisintegratorWeapon) {},
        HeavyBolter = Class(CDFElectronBolterWeapon) {},

        EMP = Class(EMPDeathWeapon) {
        
            OnCreate = function(self)
                
                Weapon.OnCreate(self)

                ChangeState( self, self.DeadState)
            end,

            OnFire = function(self)
    
                local blueprint = self:GetBlueprint()
        
                DamageArea(self.unit, self.unit:GetPosition(), blueprint.DamageRadius, blueprint.Damage, blueprint.DamageType, blueprint.DamageFriendly)
            end,
        },
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
    
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        local bp = self:GetBlueprint().Defense.AntiMissile
        
        local antiMissile = MissileRedirect {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
        
        self.Trash:Add(antiMissile)
        self.UnitComplete = true
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
    
        local emp = self:GetWeaponByLabel('EMP')
        local bp
		
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end
		
        --if we find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
			self:AddBuff(bp)
        end
		
		if self.UnitComplete then

            CreateLightParticle( self, -1, -1, 24, 62, 'flare_lens_add_02', 'ramp_red_10' )

            emp:SetWeaponEnabled(true)
            emp:OnFire()
        end
		
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = URL0303