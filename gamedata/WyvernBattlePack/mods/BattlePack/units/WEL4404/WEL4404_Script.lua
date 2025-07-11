local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Plasma    = import('/Mods/BattlePack/lua/BattlePackweapons.lua').PlasmaPPC
local Flamer    = import('/Mods/BattlePack/lua/BattlePackweapons.lua').CybranFlameThrower
local Laser     = import('/Mods/BattlePack/lua/BattlePackweapons.lua').StarAdderLaser
local Torpedo   = import('/lua/terranweapons.lua').TANTorpedoAngler

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

WEL4404 = Class(TWalkingLandUnit) {

    Weapons = {
		FlameThrower    = Class(Flamer) {},
        BeamCannon      = Class(Laser) {},
        PlasmaPPC       = Class(Plasma) {},
        Torpedo         = Class(Torpedo) { FxMuzzleFlash = false },
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
        
        self.DeathWeaponEnabled = true

        -- setup callbacks to engage sonar stealth when not moving
        local StartMoving = function(unit)
            unit:DisableIntel('SonarStealth')
        end
        
        local StopMoving = function(unit)
            unit:EnableIntel('SonarStealth')
        end
        
        self:AddOnHorizontalStartMoveCallback( StartMoving )
        self:AddOnHorizontalStopMoveCallback( StopMoving )
		
        --self:SetScriptBit('RULEUTC_StealthToggle', true)

    end,
    
}

TypeClass = WEL4404