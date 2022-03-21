local THoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local MortarWeapon = import('/lua/terranweapons.lua').TDFFragmentationGrenadeLauncherWeapon

UEL0107 = Class(THoverLandUnit) {

    Weapons = {
        Mortar = Class(MortarWeapon) {}
    },

    OnStopBeingBuilt = function(self,builder,layer)
        -- After being  built this script sets the units speed multi based 
        -- upon what it is built on as it should be faster on water then land
        local layer = self:GetCurrentLayer()
		
        if(layer == 'Land') then
            #-- Enables Land multi
            self:SetSpeedMult(1.0)
        elseif (layer == 'Water') then
            #-- Enables Sea multi
            self:SetSpeedMult(1.25)
        end
        THoverLandUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    OnLayerChange = function(self, new, old)
        -- Detects the layer trasition and adjusts the units speed accordingly
        THoverLandUnit.OnLayerChange(self, new, old)
        if( new == 'Land' ) then
            -- Enables Land multi
            self:SetSpeedMult(1.0)
        elseif ( new == 'Water' ) then
            -- Enables Sea multi
            self:SetSpeedMult(1.25)
        end
    end,
}
TypeClass = UEL0107