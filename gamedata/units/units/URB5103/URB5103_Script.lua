
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit

URB5103 = Class(CStructureUnit) {
	FxTransportBeacon = {'/effects/emitters/red_beacon_light_01_emit.bp'},
	FxTransportBeaconScale =1,
	
	OnCreate = function(self)
		CStructureUnit.OnCreate(self)
		for k, v in self.FxTransportBeacon do
			self.Trash:Add(CreateAttachedEmitter(self, 0,self:GetArmy(), v):ScaleEmitter(self.FxTransportBeaconScale))
		end
	end,
}

TypeClass = URB5103