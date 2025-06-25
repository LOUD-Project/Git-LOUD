local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo    = import('/lua/terranweapons.lua').TANTorpedoAngler
local TDFLightPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFLightPlasmaCannonWeapon

UES0203 = Class(TSubUnit) {

    Weapons = {
        Torpedo = Class(Torpedo) {
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)

                    self:ForkThread( function() self:ChangeMaxRadius(36) self:ChangeMinRadius(36) WaitTicks(28) self:ChangeMinRadius(8) self:ChangeMaxRadius(34) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },

        DeckGun = Class(TDFLightPlasmaCannonWeapon) {}
    },
	
}


TypeClass = UES0203