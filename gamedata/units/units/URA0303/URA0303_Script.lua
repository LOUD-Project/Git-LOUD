local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CAAMissileNaniteWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

URA0303 = Class(CAirUnit) {

    ExhaustBones = { 'Exhaust', },
	
    ContrailBones = { 'Contrail_L', 'Contrail_R', },
	
    Weapons = {
        Missiles1 = Class(CAAMissileNaniteWeapon) {},
    },
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
		
        self:RequestRefreshUI()
		
    end,
    
}

TypeClass = URA0303
