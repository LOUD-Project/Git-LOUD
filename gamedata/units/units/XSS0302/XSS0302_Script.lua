local SSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local Cannon    = SeraphimWeapons.SDFHeavyQuarnonCannon
local TMD       = SeraphimWeapons.SAMElectrumMissileDefense
local AA        = SeraphimWeapons.SAAOlarisCannonWeapon
local Nuke      = SeraphimWeapons.SIFInainoWeapon

SeraphimWeapons = nil

local DepthCharge   = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XSS0302 = Class(SSeaUnit) {

    FxDamageScale = 1.6,
    DestructionTicks = 250,

    Weapons = {
        Turret          = Class(Cannon) {},
        AntiMissile     = Class(TMD) {},
        AntiAir         = Class(AA) {},
        InainoMissiles  = Class(Nuke) {},
        DepthCharge     = Class(DepthCharge) { FxMuzzleFlash = false },
    },
	
	OnCreate = function(self)

        SSeaUnit.OnCreate(self)

        if type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'NUKE') then
            self:SetWeaponEnabledByLabel('InainoMissiles', false)
        end

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
        
    end,

}

TypeClass = XSS0302