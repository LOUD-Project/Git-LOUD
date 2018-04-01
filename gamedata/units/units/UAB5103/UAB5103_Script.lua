
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

UAB5103 = Class(AStructureUnit) {
	FxTransportBeacon = {'/effects/emitters/red_beacon_light_01_emit.bp'},
	FxTransportBeaconScale =1,
	
	OnCreate = function(self)
		AStructureUnit.OnCreate(self)
		
		local army = self:GetArmy()
		local CreateAttachedEmitter = CreateAttachedEmitter
		
		for k, v in self.FxTransportBeacon do
			self.Trash:Add(CreateAttachedEmitter(self, 0, army, v):ScaleEmitter(self.FxTransportBeaconScale))
		end
	end,
}

TypeClass = UAB5103