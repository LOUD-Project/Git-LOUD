local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local WeaponsFile = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon = WeaponsFile.ADFCannonOblivionWeapon
local AAMWillOWisp = WeaponsFile.AAMWillOWisp

UAS0302 = Class(ASeaUnit) {

    FxDamageScale = 2,
    DestructionTicks = 400,

    Weapons = {
        BackTurret = Class(ADFCannonOblivionWeapon) {},
        FrontTurret = Class(ADFCannonOblivionWeapon) {},
        MidTurret = Class(ADFCannonOblivionWeapon) {},
        AntiMissile1 = Class(AAMWillOWisp) {},
        AntiMissile2 = Class(AAMWillOWisp) {},
    },
    
    OnCreate = function(self)
	
        ASeaUnit.OnCreate(self)
        for i = 1, 3 do
            self.Trash:Add(CreateAnimator(self):PlayAnim(self:GetBlueprint().Weapon[i].AnimationOpen))
        end
    end,
}

TypeClass = UAS0302