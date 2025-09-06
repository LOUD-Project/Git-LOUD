local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

WEL03041 = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) {}
    },
	
	OnCreate = function(self)
        TLandUnit.OnCreate(self)
        self:HideBone('AATurret_Yaw', true)
    end,
    
    OnLayerChange = function(self,new,old)
    
        TLandUnit.OnLayerChange(self,new,old)
        
        local wep = self:GetWeaponByLabel('MainGun')
        
        if not wep then
            return
        end
        
        if new == 'Land' then
        
            wep:SetWeaponEnabled(true)
            
        else
        
            wep:SetWeaponEnabled(false)
            
        end
    
    end,
	
	OnStopBeingBuilt = function(self,builder,layer)
        TLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:HideBone('AATurret_Yaw', true)
    end,
}

TypeClass = WEL03041