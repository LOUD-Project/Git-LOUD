local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFSihEnergyRifleNormalMode = SeraphimWeapons.SDFSniperShotNormalMode
local SDFSihEnergyRifleSniperMode = SeraphimWeapons.SDFSniperShotSniperMode

XSL0305 = Class(SLandUnit) {

    Weapons = {
        MainGun = Class(SDFSihEnergyRifleNormalMode) {},
		
        SniperGun = Class(SDFSihEnergyRifleSniperMode) {
		
            SetOnTransport = function(self, transportstate)
			
                SDFSihEnergyRifleSniperMode.SetOnTransport(self, transportstate)
                self.unit:SetScriptBit('RULEUTC_WeaponToggle', false)
				
            end,
        },
    },

    OnCreate = function(self)
	
        SLandUnit.OnCreate(self)
		
        self:SetWeaponEnabledByLabel('SniperGun', false)
    end,

    OnScriptBitSet = function(self, bit)
	
        SLandUnit.OnScriptBitSet(self, bit)
		
        if bit == 1 then 
		
            local landspeed = self:GetBlueprint().Physics.LandSpeedMultiplier or 1
			
            self:SetSpeedMult( landspeed * 0.66 )

            self:SetWeaponEnabledByLabel('SniperGun', true)
            self:SetWeaponEnabledByLabel('MainGun', false)
			
            self:GetWeaponManipulatorByLabel('SniperGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('MainGun'):GetHeadingPitch() )
        end
    end,

    OnScriptBitClear = function(self, bit)
	
        SLandUnit.OnScriptBitClear(self, bit)
		
        if bit == 1 then 
		
            -- Reset movement speed
            local landspeed = self:GetBlueprint().Physics.LandSpeedMultiplier or 1
			
            self:SetSpeedMult( landspeed )
            
            self:SetWeaponEnabledByLabel('SniperGun', false)
            self:SetWeaponEnabledByLabel('MainGun', true)
			
            self:GetWeaponManipulatorByLabel('MainGun'):SetHeadingPitch( self:GetWeaponManipulatorByLabel('SniperGun'):GetHeadingPitch() )
        end
    end,
}

TypeClass = XSL0305