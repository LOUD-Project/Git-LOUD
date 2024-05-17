local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFProtonCannonWeapon     = CybranWeaponsFile.CDFProtonCannonWeapon
local CAANanoDartWeapon         = CybranWeaponsFile.CAANanoDartWeapon
local CAMZapperWeapon           = CybranWeaponsFile.CAMZapperWeapon
local CANNaniteTorpedoWeapon    = CybranWeaponsFile.CANNaniteTorpedoWeapon

local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

local MicrowaveLaser             = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').MartyrHeavyMicrowaveLaserGenerator

CybranWeaponsFile = nil


BRS0304 = Class(CSeaUnit) {

    Weapons = {
	
        ParticleGun     = Class(CDFProtonCannonWeapon) {},

        RightGun        = Class(MicrowaveLaser) {},
        LeftGun         = Class(MicrowaveLaser) {},
		
        AAGun           = Class(CAANanoDartWeapon) {},
        GroundGun       = Class(CAANanoDartWeapon) {},
		
        Zapper          = Class(CAMZapperWeapon) {},
        Torpedo         = Class(CANNaniteTorpedoWeapon) {},
        AntiTorpedo     = Class(AIFQuasarAntiTorpedoWeapon) {},
		
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
    
    OnKilled = function(self, inst, type, okr)
	
        self.Trash:Destroy()
        self.Trash = TrashBag()
		
		CSeaUnit.OnKilled(self, inst, type, okr)
		
    end,
}

TypeClass = BRS0304