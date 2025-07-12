local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local NanoDart = CybranWeaponsFile.CAANanoDartWeapon
local Laser    = CybranWeaponsFile.CDFParticleCannonWeapon

CybranWeaponsFile = nil

BRLK001 = Class(CWalkingLandUnit) 
{
    Weapons = {

		AAGun = Class(NanoDart) {},
		
		Lazor = Class(Laser) { FxMuzzleFlash = {'/effects/emitters/particle_cannon_muzzle_02_emit.bp'} },
		
		GroundGun = Class(NanoDart) {

			SetOnTransport = function(self, transportstate)
                NanoDart.SetOnTransport(self, transportstate)
                self.unit:SetScriptBit('RULEUTC_WeaponToggle', false)
            end,
		},
    },
	
	OnCreate = function(self)
        CWalkingLandUnit.OnCreate(self)
        self:SetWeaponEnabledByLabel('GroundGun', false)
    end,
    
    OnScriptBitSet = function(self, bit)
        CWalkingLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('GroundGun', true)
            self:SetWeaponEnabledByLabel('AAGun', false)
			self:SetWeaponEnabledByLabel('Lazor', false)
            self:GetWeaponManipulatorByLabel('GroundGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('AAGun'):GetHeadingPitch() )
        end
    end,

    OnScriptBitClear = function(self, bit)
        CWalkingLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('GroundGun', false)
            self:SetWeaponEnabledByLabel('AAGun', true)
			self:SetWeaponEnabledByLabel('Lazor', true)
            self:GetWeaponManipulatorByLabel('AAGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('GroundGun'):GetHeadingPitch() )
        end
    end,
}

TypeClass = BRLK001