local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon
local CAANanoDartWeapon = CybranWeaponsFile.CAANanoDartWeapon
local CAMZapperWeapon02 = CybranWeaponsFile.CAMZapperWeapon02

CybranWeaponsFile = nil


URS0202 = Class(CSeaUnit) {

    Weapons = {
        ParticleGun = Class(CDFProtonCannonWeapon) {},
        AAGun = Class(CAANanoDartWeapon) {},
        GroundGun = Class(CAANanoDartWeapon) {},
        Zapper = Class(CAMZapperWeapon02) {},
    },
    
    OnCreate = function(self)
	
        CSeaUnit.OnCreate(self)
		
        self:SetWeaponEnabledByLabel('GroundGun', false)
		
    end,
    
    OnScriptBitSet = function(self, bit)
	
        CSeaUnit.OnScriptBitSet(self, bit)
		
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('GroundGun', true)
            self:SetWeaponEnabledByLabel('AAGun', false)
            self:GetWeaponManipulatorByLabel('GroundGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('AAGun'):GetHeadingPitch() )
        end
		
    end,

    OnScriptBitClear = function(self, bit)
	
        CSeaUnit.OnScriptBitClear(self, bit)
		
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('GroundGun', false)
            self:SetWeaponEnabledByLabel('AAGun', true)
            self:GetWeaponManipulatorByLabel('AAGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('GroundGun'):GetHeadingPitch() )
        end
		
    end,
}

TypeClass = URS0202