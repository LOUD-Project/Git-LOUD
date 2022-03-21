local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local CreateDefaultHitExplosionAtBone = import('/lua/defaultexplosions.lua').CreateDefaultHitExplosionAtBone

local util = import('/lua/utilities.lua')

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

UAA0104 = Class(AAirUnit) {

    AirDestructionEffectBones = { 'Exhaust','Wing_Right','Wing_Left','Slots_Left01','Slots_Right01','Right_AttachPoint01','Right_AttachPoint02','Left_AttachPoint01','Left_AttachPoint02' },

    Weapons = {
		SonicPulseBattery = Class(AAASonicPulseBatteryWeapon) {},
    },

    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,
	
}

TypeClass = UAA0104