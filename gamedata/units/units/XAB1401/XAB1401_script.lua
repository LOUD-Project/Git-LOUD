
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local FxAmbient = import('/lua/effecttemplates.lua').AResourceGenAmbient
local AIFParagonDeathWeapon = import('/lua/aeonweapons.lua').AIFParagonDeathWeapon

XAB1401 = Class(AStructureUnit) {

    Weapons = {
        DeathWeapon = Class(AIFParagonDeathWeapon) {},
    },

	#-- prevent construction of a Paragon within 164 of an existing paragon owned by self or 90 owned by ally
	OnStartBeingBuilt = function(self, builder, layer)
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
		local aiBrain = self:GetAIBrain()
		local paragons = GetUnitsAroundPoint( aiBrain, categories.xab1401, self:GetPosition(), 100, 'Ally')
		local MyParagons = GetListOfUnits( aiBrain, categories.xab1401, true )
		local ParagonTooClose = false
		local MyPosition = self:GetPosition()

		--LOG("*AI DEBUG There are "..table.getn(MyParagons).." Paragon(s) I own in the area")
		--LOG("*AI DEBUG There are "..table.getn(paragons).." allied Paragon(s) in the area")

		if table.getn(MyParagons) > 0 then
			for key, paragon in MyParagons do
				if VDist3( MyPosition, paragon:GetPosition() ) < 164 then
				ParagonTooClose = true
				break	-- you have a paragon too close so you don’t need to check any others
				end
			end
		end

		if ParagonTooClose == false and table.getn(paragons) < 2 then
			AStructureUnit.OnStartBeingBuilt(self, builder, layer)
		else
			ForkThread(FloatingEntityText, builder.Sync.id, 'Cannot be built this close to an existing Paragon')
			self:Destroy()
			AStructureUnit.OnFailedToBuild(builder)
		end
	end,

    OnStopBeingBuilt = function(self, builder, layer)
        AStructureUnit.OnStopBeingBuilt(self, builder, layer)

        local num = self:GetRandomDir()
		
        self.BallManip = CreateRotator(self, 'Orb', 'y', nil, 0, 15, 45 + Random(0, 20) * num)
        self.Trash:Add(self.BallManip)
        
		for k, v in FxAmbient do
			CreateAttachedEmitter( self, 'Orb', self:GetArmy(), v )
		end
    end,


    GetRandomDir = function(self)
        local num = Random(0, 2)
        if num > 1 then
            return 1
        end
        return -1
    end,
}

TypeClass = XAB1401