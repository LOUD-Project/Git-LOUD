local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

UEB5103 = Class(TStructureUnit) {
	FxTransportBeacon = {'/effects/emitters/red_beacon_light_01_emit.bp'},
	FxTransportBeaconScale =1,

	OnCreate = function(self)
		TStructureUnit.OnCreate(self)
		
		local CreateAttachedEmitter = CreateAttachedEmitter
		
		for k, v in self.FxTransportBeacon do
            self.Trash:Add(CreateAttachedEmitter(self, 0, -1, v):ScaleEmitter(self.FxTransportBeaconScale))
		end
	end,
}

TypeClass = UEB5103