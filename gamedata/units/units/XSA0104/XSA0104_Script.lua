local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')
local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local SAAShleoCannonWeapon = SeraphimWeapons.SAAShleoCannonWeapon
local SDFHeavyPhasicAutoGunWeapon = SeraphimWeapons.SDFHeavyPhasicAutoGunWeapon

XSA0104 = Class(SAirUnit) {

    AirDestructionEffectBones = { 'XSA0104','Left_Attachpoint08','Right_Attachpoint02'},

    Weapons = {
        AutoGun = Class(SDFHeavyPhasicAutoGunWeapon) {},
        AAGun = Class(SAAShleoCannonWeapon) {},
    },

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            explosion.CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,
}

TypeClass = XSA0104