local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

URS0203 = Class(CSubUnit) {

    Weapons = {
        DeckGun = Class(CDFLaserHeavyWeapon) {},

        Torpedo = Class(Torpedo) {
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)

                    self:ForkThread( function() self:ChangeMaxRadius(36) self:ChangeMinRadius(36) WaitTicks(28) self:ChangeMinRadius(8) self:ChangeMaxRadius(34) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },

}

TypeClass = URS0203