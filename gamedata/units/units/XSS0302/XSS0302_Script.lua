local SSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFHeavyQuarnonCannon = SeraphimWeapons.SDFHeavyQuarnonCannon
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SIFInainoWeapon = import('/lua/seraphimweapons.lua').SIFInainoWeapon

XSS0302 = Class(SSeaUnit) {
    FxDamageScale = 2,
    DestructionTicks = 400,

    Weapons = {
	
        Turret = Class(SDFHeavyQuarnonCannon) {},
		
        AntiMissile = Class(SAMElectrumMissileDefense) {},
		
        AntiAir = Class(SAAOlarisCannonWeapon) {},
		
        InainoMissiles = Class(SIFInainoWeapon) {},
		
    },
	
	OnCreate = function(self)
        SSeaUnit.OnCreate(self)
        if type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'NUKE') then
            self:SetWeaponEnabledByLabel('InainoMissiles', false)
        end
    end,
}

TypeClass = XSS0302