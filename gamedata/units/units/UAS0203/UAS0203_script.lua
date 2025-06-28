local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

UAS0203 = Class(ASubUnit) {

    Weapons = {
        Torpedo = Class(Torpedo) {
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)

                    self:ForkThread( function() self:ChangeMaxRadius(36) self:ChangeMinRadius(36) WaitTicks(38) self:ChangeMinRadius(8) self:ChangeMaxRadius(34) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        ASubUnit.OnStopBeingBuilt(self,builder,layer)
        
        self.DeathWeaponEnabled = true

    end,

}

TypeClass = UAS0203