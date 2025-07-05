local TSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local TerranWeaponFile = import('/lua/terranweapons.lua')

local Plasma        = TerranWeaponFile.TDFIonizedPlasmaCannon
local Phalanx       = TerranWeaponFile.TAMPhalanxWeapon
local SAMLauncher   = TerranWeaponFile.TSAMLauncher
local Torpedo       = TerranWeaponFile.TANTorpedoAngler

TerranWeaponFile = nil

WES0303 = Class(TSeaUnit) {

Weapons = {
        
        DeckGunF    = Class(Plasma) {},
        DeckGunFT   = Class(Plasma) {},
        DeckGunB    = Class(Plasma) {},        
		AAF         = Class(SAMLauncher) {},
		AAR         = Class(SAMLauncher) {},
		Torpedo     = Class(Torpedo) { FxMuzzleFlash = false },
        TMD         = Class(Phalanx) {
        
            PlayFxWeaponUnpackSequence = function(self)
            
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'TMD_Turret_Barrel', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                self.SpinManip:SetTargetSpeed(500):SetPrecedence(100)

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