local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TAMInterceptorWeapon = import('/lua/terranweapons.lua').TAMInterceptorWeapon
local nukeFiredOnGotTarget = false

UEB4302 = Class(TStructureUnit) {
    Weapons = {

        AntiNuke = Class(TAMInterceptorWeapon) {},
		AntiNuke2 = Class(TAMInterceptorWeapon) {},
    },
}

TypeClass = UEB4302