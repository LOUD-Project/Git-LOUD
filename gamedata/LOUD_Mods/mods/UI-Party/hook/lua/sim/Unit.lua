--function GetEconDataRecord(id)
--	local row = Sync.FixedEcoData[id]
--	if row == nil then
--		row =  { massConsumed=0, energyConsumed=0 }
--		Sync.FixedEcoData[id] = row
--	end
--	return row
--end

--local oldUnit = Unit
--Unit = Class(oldUnit) {
--	SetConsumptionPerSecondMass = function(self, n)
--		oldUnit.SetConsumptionPerSecondMass(self, n)

--		local econData = GetEconDataRecord(self:GetEntityId())
--		LOG(self:GetResourceConsumed())
--		econData.massConsumed = self:GetConsumptionPerSecondMass() * self:GetResourceConsumed()
--	end,

--	SetConsumptionPerSecondEnergy = function(self, n)
--		oldUnit.SetConsumptionPerSecondEnergy(self, n)

--		local econData = GetEconDataRecord(self:GetEntityId())
--		econData.energyConsumed = self:GetConsumptionPerSecondEnergy() * self:GetResourceConsumed()
--	end,
--}