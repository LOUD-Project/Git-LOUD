local TSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')

local TDFIonizedPlasmaCannon = TerranWeaponFile.TDFIonizedPlasmaCannon
local TAMPhalanxWeapon = TerranWeaponFile.TAMPhalanxWeapon
local TSAMLauncher = TerranWeaponFile.TSAMLauncher
local TANTorpedoAngler = TerranWeaponFile.TANTorpedoAngler

WES0303 = Class(TSeaUnit) {

Weapons = {
        
        DeckGun = Class(TDFIonizedPlasmaCannon) {},
        
		AA = Class(TSAMLauncher) {},
        
		Torpedo = Class(TANTorpedoAngler) {},
        
        TMD = Class(TAMPhalanxWeapon) {
        
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'TMD_Turret_Barrel', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500):SetPrecedence(100)
                end
                TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,
        },
    },
}

TypeClass = WES0303