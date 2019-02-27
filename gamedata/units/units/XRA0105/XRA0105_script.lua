local CAirUnit = import('/lua/cybranunits.lua').CAirUnit
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon02

URA0203 = Class(CAirUnit) {
    Weapons = {
        MainGun = Class(CDFLaserHeavyWeapon) {}
    },

    DestructionPartsChassisToss = {'XRA0105',},

    OnStopBeingBuilt = function(self,builder,layer)
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    OnMotionVertEventChange = function(self, new, old)
        CAirUnit.OnMotionVertEventChange(self, new, old)

        if (new == 'Down') then
            # Keep the ambient hover sound going
            self:PlayUnitAmbientSound('AmbientMove')
        end

        if new == 'Bottom' then
            self:StopUnitAmbientSound( 'AmbientMove' )
        end
    end,

}

TypeClass = URA0203