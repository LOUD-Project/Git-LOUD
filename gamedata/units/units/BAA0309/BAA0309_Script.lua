local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local CreateDefaultHitExplosionAtBone = import('/lua/defaultexplosions.lua').CreateDefaultHitExplosionAtBone

local GetRandomInt = import('/lua/utilities.lua').GetRandomInt

local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

BAA0309 = Class(AAirUnit) {

    AirDestructionEffectBones = { 'Exhaust', 'Wing_Right', 'Wing_Left','Slots_Left01', 'Slots_Right01', 'Right_Attachpoint02','Left_Attachpoint02'},

    Weapons = { SonicPulseBattery = Class(AAASonicPulseBatteryWeapon) {},  },

    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
    end,

    AirDestructionEffectsThread = function( self )

        for i = 0, 7 do
            CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[ GetRandomInt( 1,9 ) ], 0.5 )
            WaitTicks(1)
        end
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
    	AAirUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', false)

        self:RequestRefreshUI()
    end,
	
}

TypeClass = BAA0309