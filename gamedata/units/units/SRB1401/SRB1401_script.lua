
local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local AIFParagonDeathWeapon = import('/lua/aeonweapons.lua').AIFParagonDeathWeapon


SRB1401 = Class(AStructureUnit) {

    Weapons = {
        DeathWeapon = Class(AIFParagonDeathWeapon) {},
    },
	
	#-- prevent construction of a Paragon within 164 of an existing paragon owned by self or 100 owned by ally
	OnStartBeingBuilt = function(self, builder, layer)
	
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
		local aiBrain = self:GetAIBrain()
		
		-- all allied paragons within 120 radius --
		local paragons = GetUnitsAroundPoint( aiBrain, categories.xab1401 + categories.seb1401 + categories.srb1401 + categories.ssb1401, self:GetPosition(), 120, 'Ally')		
		
		-- your own paragons (all of them) --
		local MyParagons = GetListOfUnits( aiBrain, categories.xab1401 + categories.seb1401 + categories.srb1401 + categories.ssb1401, true )
		
		local ParagonTooClose = false
		
		local MyPosition = self:GetPosition()

		-- any paragon is too close --
		-- the greater than 1 accounts for the new one we're trying to put up
		if table.getn(paragons) > 1 then
		
			ParagonTooClose = true
			
		end

		-- check your own paragons now --
		if table.getn(MyParagons) > 0 then
		
			for key, paragon in MyParagons do
			
				if VDist3( MyPosition, paragon:GetPosition() ) < 168 then
					ParagonTooClose = true
					break	-- you have a paragon too close so you don’t need to check any others
				end
				
			end
		end

		-- if ok to build
		if ParagonTooClose == false then
		
			AStructureUnit.OnStartBeingBuilt(self, builder, layer)
			
		else
		
			ForkThread(FloatingEntityText, builder.Sync.id, 'Cannot be built this close to an existing Paragon')
			
			self:Destroy()
			
			AStructureUnit.OnFailedToBuild(builder)
		end
		
	end,

    OnStopBeingBuilt = function(self, builder, layer)
	
        AStructureUnit.OnStopBeingBuilt(self, builder, layer)
		
        --Effects
        local army = self:GetArmy()
        self.Trash:Add(CreateRotator(self, 'Orb', 'y', nil, 0, 15, (80 + Random(0, 20)) * (1 - 2 * Random(0,1))))
        self.Trash:Add(CreateAttachedEmitter(self, 'Orb', army, '/effects/emitters/uef_t3_massfab_ambient_01_emit.bp'):OffsetEmitter(0,-0.5,0) )
		
        for i = 6, 20 do
            self.Trash:Add(CreateAttachedEmitter( self, 'Panel_0' .. i, army, '/effects/emitters/cybran_t2power_ambient_01_emit.bp' ):OffsetEmitter(0,1,-.5):ScaleEmitter(math.random(10,15)*0.15 ) )
        end

    end,

}

TypeClass = SRB1401
