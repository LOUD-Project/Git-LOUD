local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local Cannon    = CybranWeaponsFile.CDFProtonCannonWeapon
local AA        = CybranWeaponsFile.CAANanoDartWeapon
local Zapper    = CybranWeaponsFile.CAMZapperWeapon
local Torpedo   = CybranWeaponsFile.CANNaniteTorpedoWeapon

local AntiTorpedo = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon
local Laser       = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').MartyrHeavyMicrowaveLaserGenerator

CybranWeaponsFile = nil


BRS0304 = Class(CSeaUnit) {

    Weapons = {
	
        ParticleGun     = Class(Cannon) {},

        RightGun        = Class(Laser) {},
        LeftGun         = Class(Laser) {},
		
        AAGun           = Class(AA) {},
        GroundGun       = Class(AA) {},
		
        Zapper          = Class(Zapper) {},
        Torpedo         = Class(Torpedo) { FxMuzzleFlash = false },
        AntiTorpedo     = Class(AntiTorpedo) {},
		
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