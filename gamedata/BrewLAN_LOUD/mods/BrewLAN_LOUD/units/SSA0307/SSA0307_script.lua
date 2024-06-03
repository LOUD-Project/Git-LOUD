local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local SANHeavyCavitationTorpedo = import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo

SSA0307 = Class(SAirUnit) {

    Weapons = {

        ClusterTorpedo = Class(SANHeavyCavitationTorpedo) {

            -- hooking the torpedo firing in the hope of someday diverting
            -- the bomber immediately upon firing rather than breaking off
            -- only after having overflown the target
            OnWeaponFired = function(self)
            
                SANHeavyCavitationTorpedo.OnWeaponFired(self)

            end,
        },

    },

}

TypeClass = SSA0307
